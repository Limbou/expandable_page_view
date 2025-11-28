import 'package:expandable_page_view/src/expandable_page_view.dart';
import 'package:flutter_test/flutter_test.dart';

extension PageViewSize on WidgetTester {
  double get pageViewHeight => getSize(find.byType(ExpandablePageView)).height;
  double get pageViewWidth => getSize(find.byType(ExpandablePageView)).width;
}
