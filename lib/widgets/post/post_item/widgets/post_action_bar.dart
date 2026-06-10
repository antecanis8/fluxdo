import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../l10n/s.dart';
import '../../../../models/topic.dart';
import '../../../../services/discourse_cache_manager.dart';
import '../../../../services/emoji_handler.dart';
import '../../../../utils/platform_utils.dart';

/// 获取 emoji 图片 URL（未加载完成时返回空字符串，由 errorBuilder 处理）
String _getEmojiUrl(String emojiName) {
  return EmojiHandler().getEmojiUrl(emojiName);
}

/// 帖子底部操作栏
class PostActionBar extends StatefulWidget {
  final Post post;
  final bool isGuest;
  final bool isOwnPost;
  final bool isLiking;
  final List<PostReaction> reactions;
  final PostReaction? currentUserReaction;
  final GlobalKey likeButtonKey;
  final List<Post> replies;
  final ValueNotifier<bool> isLoadingRepliesNotifier;
  final ValueNotifier<bool> showRepliesNotifier;
  final VoidCallback onToggleLike;
  final VoidCallback onShowReactionPicker;
  final void Function(String? reactionId) onShowReactionUsers;
  final VoidCallback? onReply;
  final VoidCallback onShowMoreMenu;
  final VoidCallback onToggleReplies;
  final bool hideRepliesButton;
  final VoidCallback? onAddBoost;
  final bool canBoost;
  final bool hasBoosts;

  /// 弹幕开关：null = 不展示按钮；true/false = 当前显示状态（true=正在显示弹幕）
  final bool? danmakuActive;
  final VoidCallback? onToggleDanmaku;

  const PostActionBar({
    super.key,
    required this.post,
    required this.isGuest,
    required this.isOwnPost,
    required this.isLiking,
    required this.reactions,
    required this.currentUserReaction,
    required this.likeButtonKey,
    required this.replies,
    required this.isLoadingRepliesNotifier,
    required this.showRepliesNotifier,
    required this.onToggleLike,
    required this.onShowReactionPicker,
    required this.onShowReactionUsers,
    this.onReply,
    required this.onShowMoreMenu,
    required this.onToggleReplies,
    this.hideRepliesButton = false,
    this.onAddBoost,
    this.canBoost = false,
    this.hasBoosts = false,
    this.danmakuActive,
    this.onToggleDanmaku,
  });

  @override
  State<PostActionBar> createState() => _PostActionBarState();
}

class _PostActionBarState extends State<PostActionBar> {
  Timer? _hoverTimer;

  /// 防止 hover 重复触发选择器（选择器显示期间 + 关闭后短暂冷却）
  bool _pickerCooldown = false;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  void _onHoverEnter() {
    if (widget.isOwnPost || _pickerCooldown) return;
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(milliseconds: 300), () {
      _pickerCooldown = true;
      widget.onShowReactionPicker();
    });
  }

  void _onHoverExit() {
    _hoverTimer?.cancel();
    // 鼠标离开后重置冷却，允许下次 hover 重新触发
    _pickerCooldown = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final leftButton = (widget.post.replyCount > 0 && !widget.hideRepliesButton)
        ? _buildRepliesButton(theme)
        : null;
    final rightActions = _buildRightActions(theme);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 估算右侧按钮组宽度：每个 ~36px + 8px gap，再加 likeArea 的额外宽度
        final hasLikeArea = !widget.isGuest &&
            (!widget.isOwnPost || widget.reactions.isNotEmpty);
        final likeAreaWidth = hasLikeArea
            ? 60.0 + widget.reactions.take(3).length * 20
            : 0.0;
        final iconButtonCount = rightActions.length - (hasLikeArea ? 1 : 0);
        final rightWidth = likeAreaWidth +
            iconButtonCount * 36 +
            (rightActions.length - 1).clamp(0, 99) * 8;
        // 估算左侧按钮（回复数）宽度
        final leftWidth = leftButton == null ? 0.0 : 96.0;
        // 总宽不够时让右侧按钮组在自身内部换行（Wrap），左侧保持原位
        final overflow =
            leftWidth + 12 + rightWidth > constraints.maxWidth;

        final rightWidget = overflow
            ? Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: rightActions,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: _interleave(rightActions, const SizedBox(width: 8)),
              );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ?leftButton,
            const Spacer(),
            // Wrap 需要有限宽度
            Flexible(child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: rightWidget,
            )),
          ],
        );
      },
    );
  }

  /// 在 children 之间插入分隔（仅用于已合并好的 actions 列表）
  static List<Widget> _interleave(List<Widget> children, Widget sep) {
    if (children.isEmpty) return const [];
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) out.add(sep);
      out.add(children[i]);
    }
    return out;
  }

  Widget _buildRepliesButton(ThemeData theme) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isLoadingRepliesNotifier,
      builder: (context, isLoadingReplies, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.showRepliesNotifier,
          builder: (context, showReplies, _) {
            return GestureDetector(
              onTap: isLoadingReplies ? null : widget.onToggleReplies,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: showReplies
                      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: showReplies
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoadingReplies && widget.replies.isEmpty)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else ...[
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 15,
                        color: showReplies
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.post.replyCount}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: showReplies
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        showReplies
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: showReplies
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildRightActions(ThemeData theme) {
    final actions = <Widget>[];
    if (!widget.isGuest) {
      if (!widget.isOwnPost || widget.reactions.isNotEmpty) {
        actions.add(_buildLikeReactionArea(theme));
      }
      if (!widget.isOwnPost && widget.canBoost && !widget.hasBoosts) {
        actions.add(_iconCircle(
          theme,
          tooltip: 'Boost',
          icon: Icons.rocket_launch_outlined,
          onTap: widget.onAddBoost,
        ));
      }
      if (widget.danmakuActive != null && widget.onToggleDanmaku != null) {
        actions.add(_DanmakuToggleButton(
          active: widget.danmakuActive!,
          onTap: widget.onToggleDanmaku!,
        ));
      }
      actions.add(_iconCircle(
        theme,
        tooltip: context.l10n.common_reply,
        icon: Icons.reply,
        onTap: widget.onReply,
      ));
    }
    actions.add(_iconCircle(
      theme,
      icon: Icons.more_horiz,
      onTap: widget.onShowMoreMenu,
    ));
    return actions;
  }

  Widget _iconCircle(
    ThemeData theme, {
    String? tooltip,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    Widget child = GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
    if (tooltip != null) {
      child = Tooltip(message: tooltip, child: child);
    }
    return child;
  }

  /// 构建点赞/回应区域，桌面端支持 hover 触发表情选择器
  Widget _buildLikeReactionArea(ThemeData theme) {
    Widget area = Container(
      key: widget.likeButtonKey,
      height: 36,
      decoration: BoxDecoration(
        color: widget.currentUserReaction != null
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.currentUserReaction != null
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 左侧区域：回应表情 + 数量 → 查看回应人
          if (widget.reactions.isNotEmpty)
            GestureDetector(
              onTap: () => widget.onShowReactionUsers(null),
              onLongPress: widget.isOwnPost ? null : widget.onShowReactionPicker,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 36,
                padding: const EdgeInsets.only(left: 12),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!(widget.reactions.length == 1 && widget.reactions.first.id == 'heart'))
                      ...widget.reactions.take(3).map((reaction) => GestureDetector(
                        onTap: () => widget.onShowReactionUsers(reaction.id),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          alignment: Alignment.center,
                          child: Image(
                            image: emojiImageProvider(_getEmojiUrl(reaction.id)),
                            width: 16,
                            height: 16,
                            errorBuilder: (_, _, _) => const SizedBox(width: 16, height: 16),
                          ),
                        ),
                      )),
                    if (!(widget.reactions.length == 1 && widget.reactions.first.id == 'heart'))
                      const SizedBox(width: 4),
                    Text(
                      '${widget.reactions.fold(0, (sum, r) => sum + r.count)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: widget.currentUserReaction != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ),

          // 右侧区域：点赞/回应图标 → 点赞/取消
          GestureDetector(
            onTap: widget.isOwnPost ? null : (widget.isLiking ? null : widget.onToggleLike),
            onLongPress: widget.isOwnPost ? null : widget.onShowReactionPicker,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 36,
              padding: EdgeInsets.only(
                left: widget.reactions.isNotEmpty ? 0 : 12,
                right: 12,
              ),
              alignment: Alignment.center,
              child: widget.currentUserReaction != null
                  ? Image(
                      image: emojiImageProvider(_getEmojiUrl(widget.currentUserReaction!.id)),
                      width: 20,
                      height: 20,
                      errorBuilder: (_, _, _) => const Icon(Icons.favorite, size: 20),
                    )
                  : Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
        ],
      ),
    );

    // 桌面端：hover 延迟触发表情选择器
    if (PlatformUtils.isDesktop && !widget.isOwnPost) {
      area = MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: area,
      );
    }

    return area;
  }
}

/// 弹幕开关：用与点赞/回复同样的圆形按钮风格，激活/关闭通过 IconStyle 区分。
class _DanmakuToggleButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _DanmakuToggleButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = active
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final fg = active
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Tooltip(
      message: active
          ? context.l10n.boost_danmakuDismiss
          : context.l10n.boost_danmakuShow,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: CustomPaint(
            painter: _DanmakuIconPainter(color: fg, off: !active),
          ),
        ),
      ),
    );
  }
}

class _DanmakuIconPainter extends CustomPainter {
  final Color color;
  final bool off;
  _DanmakuIconPainter({required this.color, required this.off});

  @override
  void paint(Canvas canvas, Size size) {
    // 居中绘制一个 18x18 的弹幕屏图标
    const double iconSize = 18;
    final dx = (size.width - iconSize) / 2;
    final dy = (size.height - iconSize) / 2;
    canvas.save();
    canvas.translate(dx, dy);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 弹幕屏外框
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(1.2, 3.6, iconSize - 2.4, iconSize - 7.2),
      const Radius.circular(3.2),
    );
    canvas.drawRRect(rrect, stroke);

    // 两条弹幕线
    canvas.drawLine(const Offset(3.6, 7.6), const Offset(11.2, 7.6), stroke);
    canvas.drawLine(const Offset(5.2, 11.0), const Offset(13.0, 11.0), stroke);

    if (off) {
      // 关闭斜杠（左下→右上）
      canvas.drawLine(
        const Offset(1.5, iconSize - 1.5),
        const Offset(iconSize - 1.5, 1.5),
        stroke,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DanmakuIconPainter old) =>
      old.color != color || old.off != off;
}
