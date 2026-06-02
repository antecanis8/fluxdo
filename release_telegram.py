from __future__ import annotations

import json
import os
import re
import time
from html import escape as html_escape
from pathlib import Path

import requests


# === Markdown → Telegram HTML 转换 ===

_LINK_RE = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
_BOLD_RE = re.compile(r"\*\*([^*]+)\*\*")
_HEADING_RE = re.compile(r"^(#{1,6})\s+(.+)$", re.MULTILINE)
_INLINE_CODE_RE = re.compile(r"`([^`]+)`")


def md_to_html(md: str) -> str:
    """把 release_notes.md 渲染成 Telegram 支持的 HTML 子集（仅 b / a / code）。"""
    links: list[tuple[str, str]] = []
    codes: list[str] = []

    def _store_link(m: re.Match) -> str:
        links.append((m.group(1), m.group(2)))
        return f"\x00LINK{len(links) - 1}\x00"

    def _store_code(m: re.Match) -> str:
        codes.append(m.group(1))
        return f"\x00CODE{len(codes) - 1}\x00"

    text = _LINK_RE.sub(_store_link, md)
    text = _INLINE_CODE_RE.sub(_store_code, text)

    text = html_escape(text, quote=False)

    text = _BOLD_RE.sub(lambda m: f"<b>{html_escape(m.group(1))}</b>", text)
    text = _HEADING_RE.sub(lambda m: f"<b>{html_escape(m.group(2))}</b>", text)

    for i, (label, url) in enumerate(links):
        anchor = f'<a href="{html_escape(url, quote=True)}">{html_escape(label)}</a>'
        text = text.replace(f"\x00LINK{i}\x00", anchor)
    for i, code in enumerate(codes):
        text = text.replace(f"\x00CODE{i}\x00", f"<code>{html_escape(code)}</code>")

    return text


# === 长文本切分 ===

MESSAGE_LIMIT = 4000  # TG sendMessage 上限 4096，留余量


def split_message(text: str, limit: int = MESSAGE_LIMIT) -> list[str]:
    if len(text) <= limit:
        return [text]
    chunks: list[str] = []
    remaining = text
    while len(remaining) > limit:
        cut = remaining.rfind("\n\n", 0, limit)
        if cut == -1:
            cut = remaining.rfind("\n", 0, limit)
        if cut == -1:
            cut = limit
        chunks.append(remaining[:cut])
        remaining = remaining[cut:].lstrip("\n")
    if remaining:
        chunks.append(remaining)
    return chunks


# === 工具 ===

def chunked(items: list, n: int):
    for i in range(0, len(items), n):
        yield items[i : i + n]


def post_with_retry(url: str, *, max_retries: int = 3, **kwargs) -> requests.Response:
    last_exc: Exception | None = None
    for attempt in range(max_retries):
        try:
            resp = requests.post(url, timeout=300, **kwargs)
            if 500 <= resp.status_code < 600:
                raise requests.HTTPError(f"server {resp.status_code}: {resp.text[:200]}")
            return resp
        except (requests.ConnectionError, requests.Timeout, requests.HTTPError) as e:
            last_exc = e
            if attempt < max_retries - 1:
                wait = 2 ** (attempt + 1)
                print(f"请求失败 ({e})，{wait}s 后重试 ({attempt + 1}/{max_retries})")
                time.sleep(wait)
    raise RuntimeError(f"请求重试 {max_retries} 次仍失败: {last_exc}")


def _check_payload(resp: requests.Response, label: str) -> None:
    try:
        payload = resp.json()
    except ValueError:
        payload = {"ok": False, "error": resp.text}
    if not payload.get("ok"):
        raise RuntimeError(f"{label} 失败: {payload}")


# === TG API ===

def send_message(api_base: str, token: str, chat_id: str, html: str) -> None:
    url = f"{api_base}/bot{token}/sendMessage"
    chunks = split_message(html)
    for idx, chunk in enumerate(chunks):
        prefix = "" if idx == 0 else "<i>（续）</i>\n"
        resp = post_with_retry(
            url,
            data={
                "chat_id": chat_id,
                "text": prefix + chunk,
                "parse_mode": "HTML",
                "disable_web_page_preview": "true",
            },
        )
        _check_payload(resp, f"sendMessage chunk {idx + 1}/{len(chunks)}")
        print(f"sendMessage chunk {idx + 1}/{len(chunks)} OK")


def send_files(
    api_base: str,
    token: str,
    chat_id: str,
    files: list[Path],
    version: str,
) -> None:
    url = f"{api_base}/bot{token}/sendMediaGroup"
    batches = list(chunked(files, 10))
    total = len(batches)
    caption = f"FluxDO v{version} - 安装包"[:1024]

    for batch_idx, batch in enumerate(batches):
        media: list[dict] = []
        opened: dict = {}
        try:
            for idx, fp in enumerate(batch, start=1):
                key = f"file{idx}"
                media.append({"type": "document", "media": f"attach://{key}"})
                opened[key] = fp.open("rb")
            if batch_idx == total - 1:
                media[-1]["caption"] = caption
            resp = post_with_retry(
                url,
                data={"chat_id": chat_id, "media": json.dumps(media)},
                files=opened,
            )
            _check_payload(resp, f"sendMediaGroup 批 {batch_idx + 1}/{total}")
            print(f"sendMediaGroup batch {batch_idx + 1}/{total} ({len(batch)} 个文件) OK")
        finally:
            for f in opened.values():
                f.close()


# === 主流程 ===

def main() -> int:
    token = os.getenv("TELEGRAM_BOT_TOKEN")
    chat_id = os.getenv("TELEGRAM_CHAT_ID")
    if not token or not chat_id:
        print("Missing TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID, skipping.")
        return 0

    api_base = os.getenv("TELEGRAM_API_BASE", "http://localhost:8081").rstrip("/")

    repo = os.getenv("GITHUB_REPOSITORY", "")
    run_id = os.getenv("GITHUB_RUN_ID", "")
    version = os.getenv("VERSION") or os.getenv("GITHUB_REF_NAME", "").lstrip("v")
    is_prerelease = os.getenv("IS_PRERELEASE", "false").lower() == "true"

    label = "Pre-release" if is_prerelease else "Release"
    title_html = f"<b>FluxDO {label} v{html_escape(version)}</b>"

    link_html = ""
    if repo and version and not is_prerelease:
        link_url = f"https://github.com/{repo}/releases/tag/v{version}"
        link_html = f'<a href="{html_escape(link_url, quote=True)}">查看 GitHub Release</a>'
    elif repo and run_id:
        link_url = f"https://github.com/{repo}/actions/runs/{run_id}"
        link_html = f'<a href="{html_escape(link_url, quote=True)}">查看构建日志</a>'

    notes_html = ""
    release_notes = Path("release_notes.md")
    if release_notes.exists():
        notes_md = release_notes.read_text(encoding="utf-8").strip()
        if notes_md:
            notes_html = md_to_html(notes_md)

    parts = [title_html]
    if link_html:
        parts.append(link_html)
    if notes_html:
        parts.append(notes_html)
    parts.append("<i>📦 安装包见下方文件</i>")
    text_html = "\n\n".join(parts)

    artifacts_dir = Path("dist")
    package_files: list[Path] = []
    if artifacts_dir.exists():
        package_files = sorted(
            p
            for p in artifacts_dir.iterdir()
            if p.is_file() and p.suffix in {".apk", ".ipa", ".dmg", ".exe", ".flatpak"}
        )

    if not package_files:
        print("No package files found in dist/, sending message only.")
        send_message(api_base, token, chat_id, text_html)
        return 0

    send_message(api_base, token, chat_id, text_html)
    send_files(api_base, token, chat_id, package_files, version)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
