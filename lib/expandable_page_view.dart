library expandable_page_view;

import 'package:expandable_page_view/size_reporting_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandablePageView extends StatefulWidget {
  final List<Widget> children;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final bool reverse;
  final Duration animationDuration;
  final Curve animationCurve;
  final ScrollPhysics physics;
  final bool pageSnapping;
  final DragStartBehavior dragStartBehavior;
  final bool allowImplicitScrolling;
  final String restorationId;
  final Clip clipBehavior;

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
    Key key,
  })  : assert(
            (children != null && itemCount == null && itemBuilder == null) ||
                (children == null && itemCount != null && itemBuilder != null),
            "Cannot provide both children and itemBuilder\n"
            "If you need a fixed PageView, use children\n"
            "If you need a dynamically built PageView, use itemBuilder and itemCount"),
        assert(reverse != null),
        assert(animationDuration != null),
        assert(animationCurve != null),
        assert(pageSnapping != null),
        assert(dragStartBehavior != null),
        assert(allowImplicitScrolling != null),
        assert(clipBehavior != null),
        super(key: key);

  @override
  _ExpandablePageViewState createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> {
  PageController _pageController;
  List<double> _heights;
  int _currentPage = 0;
  int _previousPage = 0;

  double get _currentHeight => _heights[_currentPage];

  double get _previousHeight => _heights[_previousPage];

  bool get isBuilder => widget.itemBuilder != null;

  @override
  void initState() {
    _heights = _prepareHeights();
    super.initState();
    _pageController = widget.controller ?? PageController();
    _pageController.addListener(_updatePage);
  }

  @override
  void dispose() {
    _pageController.removeListener(_updatePage);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: widget.animationCurve,
      duration: widget.animationDuration,
      tween: Tween<double>(begin: _previousHeight, end: _currentHeight),
      builder: (context, value, child) => SizedBox(height: value, child: child),
      child: _buildPageView(),
    );
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
    if (!isBuilder) {
      return widget.children.map((child) => 0.0).toList();
    }
    return List.filled(widget.itemCount, 0.0);
  }

  void _updatePage() {
    final newPage = _pageController.page.round();
    if (_currentPage != newPage) {
      setState(() {
        _previousPage = _currentPage;
        _currentPage = newPage;
      });
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final item = widget.itemBuilder(context, index);
    return OverflowPage(
      onSizeChange: (size) => setState(() => _heights[index] = size?.height ?? 0),
      child: item,
    );
  }

  List<Widget> _sizeReportingChildren() => widget.children
      .asMap()
      .map(
        (index, child) => MapEntry(
          index,
          OverflowPage(
            onSizeChange: (size) => setState(() => _heights[index] = size?.height ?? 0),
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

  const OverflowPage({@required this.onSizeChange, @required this.child});

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
