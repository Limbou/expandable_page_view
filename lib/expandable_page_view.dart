library expandable_page_view;

import 'package:expandable_page_view/size_reporting_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandablePageView extends StatefulWidget {
  final List<Widget>? children;
  final int? itemCount;
  final Widget Function(BuildContext, int)? itemBuilder;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final bool reverse;
  final Duration animationDuration;
  final Curve animationCurve;
  final ScrollPhysics? physics;
  final bool pageSnapping;
  final DragStartBehavior dragStartBehavior;
  final bool allowImplicitScrolling;
  final String? restorationId;
  final Clip clipBehavior;

  /// Whether to animate the first page displayed by this widget.
  ///
  /// By default (false) [ExpandablePageView] will resize to the size of it's
  /// initially displayed page without any animation.
  final bool animateFirstPage;

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

  ExpandablePageView({
    this.children,
    this.itemCount,
    this.itemBuilder,
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
    Key? key,
  })  : assert(
            (children != null && itemCount == null && itemBuilder == null) ||
                (children == null && itemCount != null && itemBuilder != null),
            "Cannot provide both children and itemBuilder\n"
            "If you need a fixed PageView, use children\n"
            "If you need a dynamically built PageView, use itemBuilder and itemCount"),
        assert(estimatedPageSize >= 0.0),
        super(key: key);

  @override
  _ExpandablePageViewState createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> {
  late PageController _pageController;
  late List<double> _heights;
  int _currentPage = 0;
  int _previousPage = 0;
  bool _shouldDisposePageController = false;
  bool _firstPageLoaded = false;

  double get _currentHeight => _heights[_currentPage];

  double get _previousHeight => _heights[_previousPage];

  bool get isBuilder => widget.itemBuilder != null;

  @override
  void initState() {
    super.initState();
    _heights = _prepareHeights();
    _pageController = widget.controller ?? PageController();
    _pageController.addListener(_updatePage);
    _currentPage = _pageController.initialPage;
    _previousPage = _currentPage - 1 < 0 ? 0 : _currentPage - 1;
    _shouldDisposePageController = widget.controller == null;
  }

  @override
  void didUpdateWidget(covariant ExpandablePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_updatePage);
      _pageController = widget.controller ?? PageController();
      _pageController.addListener(_updatePage);
      _shouldDisposePageController = widget.controller == null;
    }
    if (_shouldReinitializeHeights(oldWidget)) {
      final currentPageHeight = _heights[_currentPage];
      _heights = _prepareHeights();
      _heights[_currentPage] = currentPageHeight;
    }
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
      tween: Tween<double>(begin: _previousHeight, end: _currentHeight),
      builder: (context, value, child) => SizedBox(height: value, child: child),
      child: _buildPageView(),
    );
  }

  bool _shouldReinitializeHeights(ExpandablePageView oldWidget) {
    if (oldWidget.itemBuilder != null && isBuilder) {
      return oldWidget.itemCount != widget.itemCount;
    }
    return oldWidget.children?.length != widget.children?.length;
  }

  Duration _getDuration() {
    if (_firstPageLoaded) {
      return widget.animationDuration;
    }
    return widget.animateFirstPage ? widget.animationDuration : Duration.zero;
  }

  Widget _buildPageView() {
    if (isBuilder) {
      return PageView.builder(
        key: widget.key,
        controller: _pageController,
        itemBuilder: _itemBuilder,
        itemCount: widget.itemCount,
        onPageChanged: widget.onPageChanged,
        reverse: widget.reverse,
        physics: widget.physics,
        pageSnapping: widget.pageSnapping,
        dragStartBehavior: widget.dragStartBehavior,
        allowImplicitScrolling: widget.allowImplicitScrolling,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
      );
    }
    return PageView(
      key: widget.key,
      controller: _pageController,
      children: _sizeReportingChildren(),
      onPageChanged: widget.onPageChanged,
      reverse: widget.reverse,
      physics: widget.physics,
      pageSnapping: widget.pageSnapping,
      dragStartBehavior: widget.dragStartBehavior,
      allowImplicitScrolling: widget.allowImplicitScrolling,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
    );
  }

  List<double> _prepareHeights() {
    if (isBuilder) {
      return List.filled(widget.itemCount!, widget.estimatedPageSize);
    } else {
      return widget.children!.map((child) => widget.estimatedPageSize).toList();
    }
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

  Widget _itemBuilder(BuildContext context, int index) {
    final item = widget.itemBuilder!(context, index);
    return OverflowPage(
      onSizeChange: (size) => setState(() => _heights[index] = size.height),
      child: item,
    );
  }

  List<Widget> _sizeReportingChildren() => widget.children!
      .asMap()
      .map(
        (index, child) => MapEntry(
          index,
          OverflowPage(
            onSizeChange: (size) => setState(() => _heights[index] = size.height),
            child: child,
          ),
        ),
      )
      .values
      .toList();
}

class OverflowPage extends StatelessWidget {
  final ValueChanged<Size> onSizeChange;
  final Widget child;

  const OverflowPage({
    required this.onSizeChange,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      minHeight: 0,
      maxHeight: double.infinity,
      alignment: Alignment.topCenter,
      child: SizeReportingWidget(
        onSizeChange: onSizeChange,
        child: child,
      ),
    );
  }
}
