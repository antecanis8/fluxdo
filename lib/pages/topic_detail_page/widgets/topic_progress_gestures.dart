import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/preferences_provider.dart';
import 'progress_gesture_action_meta.dart';

/// 滑动触发阈值（手指相对起点的距离 ≥ 此值即视为可触发）
const double _kSwipeTriggerDistance = 56.0;

/// 滑动方向判定的死区（小于此值不判断方向）
const double _kSwipeDeadZone = 6.0;

/// 进度悬浮条手势包装：在 [TopicProgress] 上识别左/右/上滑与长按
///
/// - 左/右/上滑：实时显示预览药丸，距离 ≥ [_kSwipeTriggerDistance] 后可触发；
///   未达阈值则松开取消，可回滑取消
/// - 长按：半圆向上展开菜单，拖动到目标项松开触发；不在项上则取消
/// - tap 由内层 InkWell 处理，本组件只处理 swipe + long press
/// - 总开关关闭时本组件退化为透传
class TopicProgressGestures extends ConsumerStatefulWidget {
  const TopicProgressGestures({
    super.key,
    required this.child,
    required this.onAction,
  });

  final Widget child;
  final ValueChanged<ProgressGestureAction> onAction;

  @override
  ConsumerState<TopicProgressGestures> createState() =>
      _TopicProgressGesturesState();
}

enum _SwipeDirection { left, right, up }

class _TopicProgressGesturesState extends ConsumerState<TopicProgressGestures>
    with TickerProviderStateMixin {
  // 长按菜单状态
  OverlayEntry? _menuEntry;
  Offset? _menuCenter;
  int? _highlightedIndex;
  List<ProgressGestureAction> _menuItems = const [];

  /// 缩短的长按触发阈值。默认 500ms 期间 pan 与 long press 都还在 arena 竞争，
  /// 会出现"模糊已出现但 swipe 还能触发"的视觉冲突。
  /// 200ms 让长按更早胜出：过了 200ms 就不会再被 pan 抢走，
  /// 之后模糊和菜单可以放心渐进，swipe overlay 也不会再弹出。
  static const Duration _longPressTimeout = Duration(milliseconds: 200);

  /// 长按显形进度动画：onLongPressStart 后 forward，模糊和菜单项渐进出现
  late final AnimationController _revealController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  // 滑动预览状态
  OverlayEntry? _swipeEntry;
  Offset? _swipeOrigin; // 悬浮条本体中心（用于定位预览药丸）
  Offset? _swipeStart; // 手指按下的全局坐标
  Offset _swipeCurrent = Offset.zero;
  _SwipeDirection? _swipeDirection;
  ProgressGestureAction? _swipeAction;
  bool _swipeTriggerable = false;

  @override
  void dispose() {
    _disposeMenuOverlay();
    _disposeSwipeOverlay();
    _revealController.dispose();
    super.dispose();
  }

  // ===== 长按菜单 =====

  void _disposeMenuOverlay() {
    _menuEntry?.remove();
    _menuEntry = null;
    _menuCenter = null;
    _highlightedIndex = null;
    _menuItems = const [];
    _revealController.stop();
    _revealController.value = 0;
  }

  double _radiusForCount(int count) {
    if (count <= 4) return 92;
    if (count <= 6) return 108;
    return 128;
  }

  /// 长按确认触发（缩短到 200ms）：创建菜单 overlay 并启动渐进显形动画
  void _handleLongPressStart(
    LongPressStartDetails details,
    AppPreferences prefs,
  ) {
    if (!prefs.progressGesturesEnabled) return;
    final items = prefs.progressGestureMenuActions;
    if (items.isEmpty) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final widgetTopCenter = box.localToGlobal(
      Offset(box.size.width / 2, 0),
    );

    _menuCenter = widgetTopCenter;
    _menuItems = items;
    _highlightedIndex = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    _menuEntry = OverlayEntry(builder: (_) => _buildMenuOverlay());
    overlay.insert(_menuEntry!);
    HapticFeedback.mediumImpact();
    _revealController.forward(from: 0);
    _updateHighlight(details.globalPosition);
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_menuEntry == null) return;
    _updateHighlight(details.globalPosition);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    final idx = _highlightedIndex;
    final items = List<ProgressGestureAction>.from(_menuItems);
    _disposeMenuOverlay();
    if (idx != null && idx >= 0 && idx < items.length) {
      HapticFeedback.mediumImpact();
      widget.onAction(items[idx]);
    }
  }

  void _handleLongPressCancel() {
    _disposeMenuOverlay();
  }

  void _updateHighlight(Offset pointer) {
    final center = _menuCenter;
    if (center == null) return;
    final dx = pointer.dx - center.dx;
    final dy = pointer.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final radius = _radiusForCount(_menuItems.length);
    int? newIndex;
    if (distance < 28 || distance > radius + 48 || dy >= 0) {
      newIndex = null;
    } else {
      final angle = math.atan2(dy, dx);
      if (angle > 0 || angle < -math.pi) {
        newIndex = null;
      } else {
        final n = _menuItems.length;
        if (n == 1) {
          newIndex = 0;
        } else {
          final step = math.pi / (n - 1);
          final normalized = (angle + math.pi) / step;
          newIndex = normalized.round().clamp(0, n - 1);
        }
      }
    }
    final changed = newIndex != _highlightedIndex;
    _highlightedIndex = newIndex;
    if (changed && newIndex != null) {
      HapticFeedback.selectionClick();
    }
    _menuEntry?.markNeedsBuild();
  }

  Widget _buildMenuOverlay() {
    return _RadialMenuOverlay(
      center: _menuCenter ?? Offset.zero,
      items: _menuItems,
      highlightedIndex: _highlightedIndex,
      radius: _radiusForCount(_menuItems.length),
      reveal: _revealController,
    );
  }

  // ===== 滑动预览 =====

  void _disposeSwipeOverlay() {
    _swipeEntry?.remove();
    _swipeEntry = null;
    _swipeOrigin = null;
    _swipeStart = null;
    _swipeCurrent = Offset.zero;
    _swipeDirection = null;
    _swipeAction = null;
    _swipeTriggerable = false;
  }

  void _handlePanStart(DragStartDetails details, AppPreferences prefs) {
    if (!prefs.progressGesturesEnabled) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    _swipeStart = details.globalPosition;
    _swipeCurrent = details.globalPosition;
    _swipeOrigin = box.localToGlobal(
      Offset(box.size.width / 2, box.size.height / 2),
    );
    _swipeDirection = null;
    _swipeAction = null;
    _swipeTriggerable = false;

    final overlay = Overlay.of(context, rootOverlay: true);
    _swipeEntry = OverlayEntry(builder: (_) => _buildSwipeOverlay());
    overlay.insert(_swipeEntry!);
  }

  void _handlePanUpdate(DragUpdateDetails details, AppPreferences prefs) {
    final start = _swipeStart;
    if (start == null) return;
    _swipeCurrent = details.globalPosition;

    final dx = _swipeCurrent.dx - start.dx;
    final dy = _swipeCurrent.dy - start.dy;
    final absDx = dx.abs();
    final absDy = dy.abs();
    final maxDelta = math.max(absDx, absDy);

    _SwipeDirection? direction;
    if (maxDelta >= _kSwipeDeadZone) {
      if (absDx > absDy) {
        direction = dx < 0 ? _SwipeDirection.left : _SwipeDirection.right;
      } else if (dy < 0) {
        direction = _SwipeDirection.up;
      }
    }

    ProgressGestureAction? action;
    switch (direction) {
      case _SwipeDirection.left:
        action = prefs.progressGestureSwipeLeft;
      case _SwipeDirection.right:
        action = prefs.progressGestureSwipeRight;
      case _SwipeDirection.up:
        action = prefs.progressGestureSwipeUp;
      case null:
        action = null;
    }

    final triggerable = action != null && maxDelta >= _kSwipeTriggerDistance;

    final directionChanged = direction != _swipeDirection;
    final triggerChanged = triggerable != _swipeTriggerable;
    if (triggerChanged && triggerable) {
      HapticFeedback.lightImpact();
    } else if (directionChanged && direction != null) {
      HapticFeedback.selectionClick();
    }

    _swipeDirection = direction;
    _swipeAction = action;
    _swipeTriggerable = triggerable;
    _swipeEntry?.markNeedsBuild();
  }

  void _handlePanEnd(DragEndDetails details) {
    final triggered = _swipeTriggerable;
    final action = _swipeAction;
    _disposeSwipeOverlay();
    if (triggered && action != null) {
      HapticFeedback.mediumImpact();
      widget.onAction(action);
    }
  }

  void _handlePanCancel() {
    _disposeSwipeOverlay();
  }

  Widget _buildSwipeOverlay() {
    return _SwipePreviewOverlay(
      origin: _swipeOrigin ?? Offset.zero,
      direction: _swipeDirection,
      action: _swipeAction,
      triggerable: _swipeTriggerable,
      delta: (_swipeStart == null)
          ? Offset.zero
          : _swipeCurrent - _swipeStart!,
      triggerDistance: _kSwipeTriggerDistance,
    );
  }

  // ===== 入口 =====

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    if (!prefs.progressGesturesEnabled) {
      return widget.child;
    }
    return RawGestureDetector(
      behavior: HitTestBehavior.deferToChild,
      gestures: <Type, GestureRecognizerFactory>{
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(duration: _longPressTimeout),
              (instance) {
                instance.onLongPressStart =
                    (d) => _handleLongPressStart(d, prefs);
                instance.onLongPressMoveUpdate = _handleLongPressMoveUpdate;
                instance.onLongPressEnd = _handleLongPressEnd;
                instance.onLongPressCancel = _handleLongPressCancel;
              },
            ),
        PanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
              () => PanGestureRecognizer(),
              (instance) {
                instance.onStart = (d) => _handlePanStart(d, prefs);
                instance.onUpdate = (d) => _handlePanUpdate(d, prefs);
                instance.onEnd = _handlePanEnd;
                instance.onCancel = _handlePanCancel;
              },
            ),
      },
      child: widget.child,
    );
  }
}

// ============================== 半圆菜单 Overlay ==============================

class _RadialMenuOverlay extends StatelessWidget {
  const _RadialMenuOverlay({
    required this.center,
    required this.items,
    required this.highlightedIndex,
    required this.radius,
    required this.reveal,
  });

  final Offset center;
  final List<ProgressGestureAction> items;
  final int? highlightedIndex;
  final double radius;

  /// 长按显形进度 (0..1)，驱动模糊 / 暗化 / 菜单项与 tooltip 透明度的渐进
  final Animation<double> reveal;

  // 顶部 tooltip 底部到半圆顶部之间的间隙。
  // 顶部项放大时直径 ~58dp，需要预留足够空间避免相互遮挡
  static const double _tooltipGap = 64.0;

  // 模糊与暗化的稳态强度
  static const double _maxBlur = 8.0;
  static const double _maxDim = 0.22;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: reveal,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(reveal.value);
          // 菜单项 / tooltip 在 reveal 中后段才出现，让"模糊在前、菜单跟上"
          final itemOpacity = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
          final highlightedAction = (highlightedIndex != null &&
                  highlightedIndex! >= 0 &&
                  highlightedIndex! < items.length)
              ? items[highlightedIndex!]
              : null;
          return Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _maxBlur * t,
                    sigmaY: _maxBlur * t,
                  ),
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: _maxDim * t),
                  ),
                ),
              ),
              for (int i = 0; i < items.length; i++)
                _buildItem(context, i, items[i], itemOpacity),
              if (highlightedAction != null)
                _buildHeaderTooltip(context, highlightedAction, itemOpacity),
            ],
          );
        },
      ),
    );
  }

  Offset _itemPosition(int index) {
    final n = items.length;
    final double angle;
    if (n == 1) {
      angle = -math.pi / 2;
    } else {
      final step = math.pi / (n - 1);
      angle = -math.pi + index * step;
    }
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    ProgressGestureAction action,
    double opacity,
  ) {
    final theme = Theme.of(context);
    final meta = progressGestureActionMeta(context, action);
    final isHighlighted = highlightedIndex == index;
    const size = 48.0;
    final scale = isHighlighted ? 1.2 : 1.0;
    final pos = _itemPosition(index);

    return AnimatedPositioned(
      key: ValueKey('progress_gesture_item_$index'),
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      left: pos.dx - size * scale / 2,
      top: pos.dy - size * scale / 2,
      width: size * scale,
      height: size * scale,
      child: Opacity(
        opacity: opacity,
        child: Material(
          color: isHighlighted
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          shape: const CircleBorder(),
          elevation: isHighlighted ? 6 : 2,
          shadowColor: isHighlighted
              ? theme.colorScheme.primary.withValues(alpha: 0.4)
              : Colors.black26,
          child: Icon(
            meta.icon,
            size: 24 * scale,
            color: isHighlighted
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTooltip(
    BuildContext context,
    ProgressGestureAction action,
    double opacity,
  ) {
    final theme = Theme.of(context);
    final meta = progressGestureActionMeta(context, action);
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    const margin = 16.0;

    // 基于悬浮条本身（center.dx）居中，而不是基于全屏；
    // 双栏布局下话题面板偏右，仍能正确居中在悬浮条之上
    final clampedX = center.dx.clamp(margin, screenWidth - margin);
    // 底部贴在半圆顶之上 _tooltipGap
    final bottomY = (center.dy - radius - _tooltipGap).clamp(
      mq.padding.top + 56.0,
      mq.size.height,
    );

    return Positioned(
      left: clampedX,
      top: bottomY,
      child: FractionalTranslation(
        // 水平居中 + 把整张卡片抬到 bottomY 之上
        translation: const Offset(-0.5, -1.0),
        child: Opacity(
          opacity: opacity,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth - margin * 2),
            child: Material(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(36),
            elevation: 10,
            shadowColor: Colors.black.withValues(alpha: 0.28),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      meta.icon,
                      size: 24,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Text(
                      meta.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onInverseSurface,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}

// ============================== 滑动预览 Overlay ==============================

class _SwipePreviewOverlay extends StatelessWidget {
  const _SwipePreviewOverlay({
    required this.origin,
    required this.direction,
    required this.action,
    required this.triggerable,
    required this.delta,
    required this.triggerDistance,
  });

  /// 悬浮条本体的全局坐标（中心点）
  final Offset origin;
  final _SwipeDirection? direction;
  final ProgressGestureAction? action;
  final bool triggerable;
  final Offset delta;
  final double triggerDistance;

  static const double _pillBaseOffset = 56;
  static const double _pillFollowFactor = 0.55;
  static const double _pillFollowMax = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (action == null || direction == null) {
      return const IgnorePointer(child: SizedBox.shrink());
    }
    final meta = progressGestureActionMeta(context, action!);
    final progress = (math.max(delta.dx.abs(), delta.dy.abs()) / triggerDistance)
        .clamp(0.0, 1.0);

    // 计算 pill 相对于 origin 的偏移
    Offset pillOffset;
    switch (direction!) {
      case _SwipeDirection.left:
        final dx = (delta.dx * _pillFollowFactor).clamp(-_pillFollowMax, 0.0);
        pillOffset = Offset(dx, -_pillBaseOffset);
      case _SwipeDirection.right:
        final dx = (delta.dx * _pillFollowFactor).clamp(0.0, _pillFollowMax);
        pillOffset = Offset(dx, -_pillBaseOffset);
      case _SwipeDirection.up:
        final dy =
            (delta.dy * _pillFollowFactor).clamp(-_pillFollowMax, 0.0) -
                _pillBaseOffset;
        pillOffset = Offset(0, dy);
    }

    final pillCenter = origin + pillOffset;
    final bgColor = triggerable
        ? theme.colorScheme.primary
        : Color.lerp(
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.primary,
            progress * 0.4,
          )!;
    final fgColor = triggerable
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final shadow = triggerable
        ? theme.colorScheme.primary.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.12);

    final screenSize = MediaQuery.of(context).size;
    final clampedX = pillCenter.dx.clamp(60.0, screenSize.width - 60.0);
    final clampedY = pillCenter.dy.clamp(40.0, screenSize.height - 40.0);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: clampedX,
            top: clampedY,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOutBack,
                scale: triggerable ? 1.04 : 1.0,
                child: Material(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  elevation: triggerable ? 6 : 3,
                  shadowColor: shadow,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(meta.icon, size: 18, color: fgColor),
                        const SizedBox(width: 6),
                        Text(
                          meta.label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: fgColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

