import 'dart:math';

import 'package:flutter/widgets.dart';

/// A [PageController] that supports loop (infinite scroll) mode for
/// [ExpandablePageView].
///
/// When used with [ExpandablePageView] and `loop: true`, this controller
/// allows programmatic navigation via [jumpToPage] and [animateToPage]
/// using real page indices (0 to [itemCount]-1). The virtual index
/// translation required for infinite scrolling is handled internally.
///
/// The [page] getter returns the current real page index (with fractional
/// part for smooth animations), not the internal virtual index.
///
/// Example:
/// ```dart
/// final controller = ExpandablePageController(itemCount: 5);
///
/// ExpandablePageView(
///   controller: controller,
///   loop: true,
///   children: [...],
/// );
///
/// // Navigate programmatically
/// controller.jumpToPage(3);
/// controller.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
///
/// // Read current page
/// print(controller.page); // e.g., 2.0
/// ```
class ExpandablePageController extends PageController {
  int _itemCount;

  /// Virtual page of real page 0; [itemCount] changes shift it to keep the shown page.
  int _loopOrigin = 0;

  /// Large multiplier for initial page offset in loop mode.
  /// This allows scrolling in both directions from the start.
  static const int loopMultiplier = 10000;

  /// Creates a controller for an [ExpandablePageView] with loop support.
  ///
  /// [itemCount] is the number of real pages. It must be greater than 0.
  ///
  /// [initialPage] is the real page index to start on (0 to [itemCount]-1).
  ExpandablePageController({
    required int itemCount,
    int initialPage = 0,
    super.viewportFraction,
    super.keepPage,
  })  : assert(itemCount > 0, 'itemCount must be greater than 0'),
        assert(
          initialPage >= 0 && initialPage < itemCount,
          'initialPage must be >= 0 and < itemCount',
        ),
        _itemCount = itemCount,
        super(initialPage: loopMultiplier * itemCount + initialPage);

  /// The number of real pages.
  ///
  /// Changing it keeps [realPage] without scrolling, or shows the last page if [realPage] is gone.
  int get itemCount => _itemCount;
  set itemCount(int value) {
    assert(value > 0, 'itemCount must be greater than 0');
    if (value == _itemCount) return;
    final currentVirtual = _currentVirtualPage;
    final newRealPage = min(toRealIndex(currentVirtual), value - 1);
    _itemCount = value;
    _loopOrigin = currentVirtual - newRealPage;
  }

  int get _currentVirtualPage => hasClients ? super.page?.round() ?? initialPage : initialPage;

  /// The current real page as a fraction (e.g., 2.35 means 35% between
  /// page 2 and page 3).
  ///
  /// Returns `null` if the controller is not attached to a scroll view.
  ///
  /// Note: At loop boundaries (e.g., swiping from the last page to the
  /// first), there may be a discontinuity in the fractional value.
  @override
  double? get page {
    final virtualPage = super.page;
    if (virtualPage == null) return null;
    final originPage = virtualPage - _loopOrigin;
    return ((originPage % _itemCount) + _itemCount) % _itemCount;
  }

  /// The current real page index (rounded).
  ///
  /// If the controller is not yet attached, returns the initial page.
  int get realPage => toRealIndex(_currentVirtualPage);

  /// Jumps to the given real page index using the shortest path.
  @override
  void jumpToPage(int page) {
    assert(page >= 0 && page < _itemCount, 'page must be in range [0, $_itemCount)');
    super.jumpToPage(_closestVirtualPage(page));
  }

  /// Animates to the given real page index using the shortest path.
  @override
  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) {
    assert(page >= 0 && page < _itemCount, 'page must be in range [0, $_itemCount)');
    return super.animateToPage(
      _closestVirtualPage(page),
      duration: duration,
      curve: curve,
    );
  }

  /// Finds the closest virtual page for the given real page index,
  /// choosing the shortest path (fewest pages to scroll).
  int _closestVirtualPage(int targetRealPage) {
    final currentVirtual = _currentVirtualPage;
    final currentReal = toRealIndex(currentVirtual);

    // Forward and backward deltas
    int forwardDelta = (targetRealPage - currentReal) % _itemCount;
    int backwardDelta = forwardDelta - _itemCount;

    // Choose shortest path
    final delta = forwardDelta.abs() <= backwardDelta.abs() ? forwardDelta : backwardDelta;

    return currentVirtual + delta;
  }
}

/// Shared with [ExpandablePageView]; an extension so it stays out of the exported API.
extension LoopPageMapping on ExpandablePageController {
  int toRealIndex(int virtualIndex) {
    final originIndex = virtualIndex - _loopOrigin;
    return ((originIndex % _itemCount) + _itemCount) % _itemCount;
  }

  /// Remaps instead of scrolling, so the PageView stays mid-range and can loop both ways.
  void startAt(int realPage) {
    assert(realPage >= 0 && realPage < _itemCount, 'realPage must be in range [0, $_itemCount)');
    _loopOrigin = initialPage - realPage;
  }
}
