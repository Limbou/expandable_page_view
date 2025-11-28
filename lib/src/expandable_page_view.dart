library expandable_page_view;

import 'dart:math';

import 'package:expandable_page_view/src/size_reporting_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef WidgetBuilder = Widget Function(BuildContext context, int index);

class ExpandablePageView extends StatefulWidget {
  /// List of widgets to display
  ///
  /// Corresponds to Material's PageView's children parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final List<Widget>? children;

  /// Number of widgets to display
  ///
  /// Corresponds to Material PageView's itemCount parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final int? itemCount;

  /// Item builder function
  ///
  /// Corresponds to Material's PageView's itemBuilder parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final WidgetBuilder? itemBuilder;

  /// An object that can be used to control the position to which this page view is scrolled.
  ///
  /// Corresponds to Material's PageView's controller parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final PageController? controller;

  /// Called whenever the page in the center of the viewport changes.
  ///
  /// Corresponds to Material's PageView's onPageChanged parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final ValueChanged<int>? onPageChanged;

  /// Whether the page view scrolls in the reading direction.
  ///
  /// Corresponds to Material's PageView's reverse parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final bool reverse;

  /// Duration of PageView resize animation upon page change
  ///
  /// Defaults to [100 milliseconds]
  final Duration animationDuration;

  /// Curve use for PageView resize animation upon page change
  ///
  /// Defaults to [Curves.easeInOutCubic]
  final Curve animationCurve;

  /// How the page view should respond to user input.
  ///
  /// Corresponds to Material's PageView's physics parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final ScrollPhysics? physics;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  ///
  /// Corresponds to Material's PageView's pageSnapping parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final bool pageSnapping;

  /// Determines the way that drag start behavior is handled.
  ///
  /// Corresponds to Material's PageView's dragStartBehavior parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final DragStartBehavior dragStartBehavior;

  /// Controls whether the widget's pages will respond to [RenderObject.showOnScreen], which will allow for implicit accessibility scrolling.
  ///
  /// Corresponds to Material's PageView's allowImplicitScrolling parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final bool allowImplicitScrolling;

  /// Restoration ID to save and restore the scroll offset of the scrollable.
  ///
  /// Corresponds to Material's PageView's restorationId parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final String? restorationId;

  /// The content will be clipped (or not) according to this option.
  ///
  /// Corresponds to Material's PageView's clipBehavior parameter: https://api.flutter.dev/flutter/widgets/PageView-class.html
  final Clip clipBehavior;

  /// Whether to animate the first page displayed by this widget.
  ///
  /// By default (false) [ExpandablePageView] will resize to the size of it's
  /// initially displayed page without any animation.
  final bool animateFirstPage;

  /// Determines the alignment of the content when animating. Useful when building centered or bottom-aligned PageViews.
  final Alignment alignment;

  /// The estimated size of displayed pages.
  ///
  /// This property can be used to indicate how big a page will be more or less.
  /// By default (0.0) all pages will have their initial sizes set to 0.0
  /// until they report that their size changed, which will result in
  /// [ExpandablePageView] size animation. This can lead to a behaviour
  /// when after changing the page, [ExpandablePageView] will first shrink to 0.0
  /// and then animate to the size of the page.
  ///
  /// For example: If there is certainty that most pages displayed by [ExpandablePageView]
  /// will vary from 200 to 600 in size, then [estimatedPageSize] could be set to some
  /// value in that range, to at least partially remove the "shrink and expand" effect.
  ///
  /// Setting it to a value much bigger than most pages' sizes might result in a
  /// reversed - "expand and shrink" - effect.
  final double estimatedPageSize;

  ///A ScrollBehavior that will be applied to this widget individually.
  //
  // Defaults to null, wherein the inherited ScrollBehavior is copied and modified to alter the viewport decoration, like Scrollbars.
  //
  // ScrollBehaviors also provide ScrollPhysics. If an explicit ScrollPhysics is provided in physics, it will take precedence, followed by scrollBehavior, and then the inherited ancestor ScrollBehavior.
  //
  // The ScrollBehavior of the inherited ScrollConfiguration will be modified by default to not apply a Scrollbar.
  final ScrollBehavior? scrollBehavior;

  ///The axis along which the page view scrolls.
  //
  // Defaults to Axis.horizontal.
  final Axis scrollDirection;

  /// Whether to add padding to both ends of the list.
  ///
  /// If this is set to true and [PageController.viewportFraction] < 1.0, padding will be added
  /// such that the first and last child slivers will be in the center of
  /// the viewport when scrolled all the way to the start or end, respectively.
  ///
  /// If [PageController.viewportFraction] >= 1.0, this property has no effect.
  ///
  /// This property defaults to true and must not be null.
  final bool padEnds;

  /// Whether the page view should loop infinitely.
  ///
  /// When set to true, the page view will cycle through pages infinitely
  /// in both directions. Swiping past the last page will show the first page,
  /// and swiping before the first page will show the last page.
  ///
  /// The [onPageChanged] callback will receive the actual page index (0 to itemCount-1),
  /// not the virtual index used internally for infinite scrolling.
  ///
  /// **Note:** When [loop] is true, [ExpandablePageView] creates its own internal
  /// [PageController] to manage the virtual page indices. Any [controller] provided
  /// will only be used to read [PageController.initialPage], [PageController.viewportFraction],
  /// and [PageController.keepPage]. The provided controller is not attached to the PageView,
  /// so calling methods like [PageController.jumpToPage] or [PageController.animateToPage]
  /// will have no effect on the displayed pages.
  ///
  /// Defaults to false.
  final bool loop;

  ExpandablePageView({
    required List<Widget> children,
    this.controller,
    this.onPageChanged,
    this.reverse = false,
    this.animationDuration = const Duration(milliseconds: 100),
    this.animationCurve = Curves.easeInOutCubic,
    this.physics,
    this.pageSnapping = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.animateFirstPage = false,
    this.estimatedPageSize = 0.0,
    this.alignment = Alignment.topCenter,
    this.scrollBehavior,
    this.scrollDirection = Axis.horizontal,
    this.padEnds = true,
    this.loop = false,
    Key? key,
  })  : assert(estimatedPageSize >= 0.0),
        assert(!loop || children.isNotEmpty, 'children must not be empty when loop is true'),
        children = children,
        itemBuilder = null,
        itemCount = null,
        super(key: key);

  ExpandablePageView.builder({
    required int itemCount,
    required WidgetBuilder itemBuilder,
    this.controller,
    this.onPageChanged,
    this.reverse = false,
    this.animationDuration = const Duration(milliseconds: 100),
    this.animationCurve = Curves.easeInOutCubic,
    this.physics,
    this.pageSnapping = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.animateFirstPage = false,
    this.estimatedPageSize = 0.0,
    this.alignment = Alignment.topCenter,
    this.scrollBehavior,
    this.scrollDirection = Axis.horizontal,
    this.padEnds = true,
    this.loop = false,
    Key? key,
  })  : assert(estimatedPageSize >= 0.0),
        assert(!loop || itemCount > 0, 'itemCount must be greater than 0 when loop is true'),
        children = null,
        itemCount = itemCount,
        itemBuilder = itemBuilder,
        super(key: key);

  @override
  _ExpandablePageViewState createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> {
  late PageController _pageController;
  late List<double> _sizes;
  int _currentPage = 0;
  int _previousPage = 0;
  bool _shouldDisposePageController = false;
  bool _firstPageLoaded = false;
  double? _initialSize;

  /// Large multiplier for initial page offset in loop mode.
  /// This allows scrolling in both directions from the start.
  static const int _loopMultiplier = 10000;

  /// The actual number of items (not virtual).
  int get _itemCount => widget.itemCount ?? widget.children!.length;

  /// Converts a virtual index (used in infinite scroll) to a real index (0 to _itemCount-1).
  int _realIndex(int virtualIndex) {
    if (!widget.loop) return virtualIndex;
    final count = _itemCount;
    // Handle negative indices properly
    return ((virtualIndex % count) + count) % count;
  }

  /// The initial page for the PageController in loop mode.
  /// Starts at a large offset to allow scrolling in both directions.
  int _loopInitialPageFor(int realPage) {
    return (_loopMultiplier * _itemCount) + realPage;
  }

  /// Creates a PageController for loop mode with the given initial page.
  PageController _createLoopController(int initialRealPage) {
    return PageController(
      initialPage: _loopInitialPageFor(initialRealPage),
      viewportFraction: widget.controller?.viewportFraction ?? 1.0,
      keepPage: widget.controller?.keepPage ?? true,
    );
  }

  /// Creates a PageController for non-loop mode.
  PageController _createStandardController(int initialPage) {
    return widget.controller ?? PageController(initialPage: initialPage);
  }

  double get _currentSize {
    final viewportFraction = _pageController.viewportFraction;
    if (viewportFraction >= 1.0) {
      return _sizes[_realIndex(_currentPage)];
    }
    // When viewportFraction < 1.0, multiple pages are visible
    // Calculate the range of visible pages and return the max size
    return _maxVisibleSizeForPage(_currentPage);
  }

  double get _previousSize {
    // For the first page animation, use the initial estimated size
    // so we animate from estimatedPageSize to the actual measured size.
    // Only do this if animateFirstPage is true.
    if (!_firstPageLoaded && _initialSize != null && widget.animateFirstPage) {
      return _initialSize!;
    }
    final viewportFraction = _pageController.viewportFraction;
    if (viewportFraction >= 1.0) {
      return _sizes[_realIndex(_previousPage)];
    }
    // With viewportFraction < 1.0, use max of visible pages for previous state too
    return _maxVisibleSizeForPage(_previousPage);
  }

  /// Returns the maximum size among all visible pages when viewportFraction < 1.0.
  /// Calculates how many pages are visible on each side based on the viewportFraction:
  /// - viewportFraction 0.5: 1 page visible on each side
  /// - viewportFraction 0.33: 2 pages visible on each side
  /// - viewportFraction 0.25: 2 pages visible on each side
  double _maxVisibleSizeForPage(int virtualPage) {
    if (_sizes.isEmpty) return 0;

    final viewportFraction = _pageController.viewportFraction;
    final visibleOnEachSide = ((1 - viewportFraction) / (2 * viewportFraction)).ceil();

    double maxSize = 0;
    for (int i = -visibleOnEachSide; i <= visibleOnEachSide; i++) {
      final adjacentVirtualPage = virtualPage + i;

      // In non-loop mode, skip pages outside valid range
      if (!widget.loop) {
        if (adjacentVirtualPage < 0 || adjacentVirtualPage >= _sizes.length) {
          continue;
        }
      }

      final realIdx = _realIndex(adjacentVirtualPage);
      if (_sizes[realIdx] > maxSize) {
        maxSize = _sizes[realIdx];
      }
    }
    return maxSize;
  }

  bool get isBuilder => widget.itemBuilder != null;

  bool get _isHorizontalScroll => widget.scrollDirection == Axis.horizontal;

  @override
  void initState() {
    super.initState();
    _sizes = _prepareSizes();
    _initializePageController();
    _pageController.addListener(_updatePage);
    _initialSize = widget.estimatedPageSize;
  }

  void _initializePageController() {
    if (widget.loop) {
      final userInitialPage = widget.controller?.initialPage ?? 0;
      _pageController = _createLoopController(userInitialPage);
      _shouldDisposePageController = true;
      _currentPage = _loopInitialPageFor(userInitialPage);
      _previousPage = _currentPage;
    } else {
      _pageController = _createStandardController(0);
      _shouldDisposePageController = widget.controller == null;
      _currentPage = _pageController.initialPage.clamp(0, max(0, _sizes.length - 1));
      _previousPage = max(0, _currentPage - 1);
    }
  }

  @override
  void didUpdateWidget(covariant ExpandablePageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle loop property change
    if (oldWidget.loop != widget.loop) {
      _handleLoopChange(oldWidget);
      // Also check if sizes need reinitialization (children count may have changed too)
      if (_shouldReinitializeHeights(oldWidget)) {
        _reinitializeSizes();
      }
      return;
    }

    if (oldWidget.controller != widget.controller && !widget.loop) {
      // Only handle controller changes in non-loop mode
      // In loop mode, we manage our own internal controller
      oldWidget.controller?.removeListener(_updatePage);
      _pageController = widget.controller ?? PageController();
      _pageController.addListener(_updatePage);
      _shouldDisposePageController = widget.controller == null;
    }
    if (_shouldReinitializeHeights(oldWidget)) {
      _reinitializeSizes();
    }
  }

  /// Handles the transition when loop property changes.
  void _handleLoopChange(ExpandablePageView oldWidget) {
    final currentRealPage = _realIndex(_currentPage);
    _pageController.removeListener(_updatePage);
    if (_shouldDisposePageController) {
      _pageController.dispose();
    }

    if (widget.loop) {
      _pageController = _createLoopController(currentRealPage);
      _shouldDisposePageController = true;
      _currentPage = _loopInitialPageFor(currentRealPage);
      _previousPage = _currentPage;
    } else {
      _pageController = _createStandardController(currentRealPage);
      _shouldDisposePageController = widget.controller == null;
      _currentPage = currentRealPage.clamp(0, max(0, _sizes.length - 1));
      _previousPage = _currentPage;
    }

    _pageController.addListener(_updatePage);
  }

  @override
  void dispose() {
    _pageController.removeListener(_updatePage);
    if (_shouldDisposePageController) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: widget.animationCurve,
      duration: _getDuration(),
      tween: Tween<double>(begin: _previousSize, end: _currentSize),
      builder: (context, value, child) => SizedBox(
        height: _isHorizontalScroll ? value : null,
        width: !_isHorizontalScroll ? value : null,
        child: child,
      ),
      child: _buildPageView(),
    );
  }

  bool _shouldReinitializeHeights(ExpandablePageView oldWidget) {
    if (oldWidget.itemBuilder != null && isBuilder) {
      return oldWidget.itemCount != widget.itemCount;
    }
    return oldWidget.children?.length != widget.children?.length;
  }

  void _reinitializeSizes() {
    final realCurrentPage = _realIndex(_currentPage);
    final currentPageSize = _sizes[realCurrentPage];

    final estimatedSizes = _prepareSizes();
    for (int i = 0; i < estimatedSizes.length; i++) {
      estimatedSizes[i] = _sizes.elementAtOrNull(i) ?? estimatedSizes[i];
    }
    _sizes = estimatedSizes;

    if (!widget.loop && realCurrentPage >= _sizes.length) {
      final differenceFromPreviousToCurrent = _previousPage - _currentPage;
      _currentPage = _sizes.length - 1;
      widget.onPageChanged?.call(_currentPage);

      _previousPage = (_currentPage + differenceFromPreviousToCurrent).clamp(0, _sizes.length - 1);
    }

    if (!widget.loop) {
      _previousPage = _previousPage.clamp(0, _sizes.length - 1);
    }
    _sizes[_realIndex(_currentPage)] = currentPageSize;
  }

  Duration _getDuration() {
    if (_firstPageLoaded) {
      return widget.animationDuration;
    }
    return widget.animateFirstPage ? widget.animationDuration : Duration.zero;
  }

  /// Handles onPageChanged callback, converting virtual index to real index in loop mode.
  void _handlePageChanged(int virtualIndex) {
    final realIndex = _realIndex(virtualIndex);
    widget.onPageChanged?.call(realIndex);
  }

  Widget _buildPageView() {
    if (isBuilder || widget.loop) {
      return PageView.builder(
        controller: _pageController,
        itemBuilder: _itemBuilder,
        itemCount: widget.loop ? null : widget.itemCount,
        onPageChanged: _handlePageChanged,
        reverse: widget.reverse,
        physics: widget.physics,
        pageSnapping: widget.pageSnapping,
        dragStartBehavior: widget.dragStartBehavior,
        allowImplicitScrolling: widget.allowImplicitScrolling,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
        scrollBehavior: widget.scrollBehavior,
        scrollDirection: widget.scrollDirection,
        padEnds: widget.padEnds,
      );
    }
    return PageView(
      controller: _pageController,
      onPageChanged: _handlePageChanged,
      reverse: widget.reverse,
      physics: widget.physics,
      pageSnapping: widget.pageSnapping,
      dragStartBehavior: widget.dragStartBehavior,
      allowImplicitScrolling: widget.allowImplicitScrolling,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      scrollBehavior: widget.scrollBehavior,
      scrollDirection: widget.scrollDirection,
      padEnds: widget.padEnds,
      children: _sizeReportingChildren(),
    );
  }

  List<double> _prepareSizes() {
    return List.filled(_itemCount, widget.estimatedPageSize);
  }

  void _updatePage() {
    final newPage = _pageController.page!.round();
    if (_currentPage != newPage) {
      setState(() {
        _firstPageLoaded = true;
        _previousPage = _currentPage;
        _currentPage = newPage;
      });
    }
  }

  Widget _itemBuilder(BuildContext context, int virtualIndex) {
    final realIndex = _realIndex(virtualIndex);
    final child = widget.loop && !isBuilder
        ? widget.children![realIndex]
        : widget.itemBuilder!(context, realIndex);

    return _wrapWithSizeReporting(child, realIndex, virtualIndex);
  }

  Widget _wrapWithSizeReporting(Widget child, int realIndex, int virtualIndex) {
    return OverflowPage(
      onSizeChange: (size) => setState(() {
        _sizes[realIndex] = _isHorizontalScroll ? size.height : size.width;
        if (virtualIndex == _currentPage && !_firstPageLoaded) {
          _firstPageLoaded = true;
        }
      }),
      alignment: widget.alignment,
      scrollDirection: widget.scrollDirection,
      child: child,
    );
  }

  List<Widget> _sizeReportingChildren() {
    return [
      for (int i = 0; i < widget.children!.length; i++)
        _wrapWithSizeReporting(widget.children![i], i, i),
    ];
  }
}

class OverflowPage extends StatelessWidget {
  final ValueChanged<Size> onSizeChange;
  final Widget child;
  final Alignment alignment;
  final Axis scrollDirection;

  const OverflowPage({
    required this.onSizeChange,
    required this.child,
    required this.alignment,
    required this.scrollDirection,
  });

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      minHeight: scrollDirection == Axis.horizontal ? 0 : null,
      minWidth: scrollDirection == Axis.vertical ? 0 : null,
      maxHeight: scrollDirection == Axis.horizontal ? double.infinity : null,
      maxWidth: scrollDirection == Axis.vertical ? double.infinity : null,
      alignment: alignment,
      child: SizeReportingWidget(
        onSizeChange: onSizeChange,
        child: child,
      ),
    );
  }
}
