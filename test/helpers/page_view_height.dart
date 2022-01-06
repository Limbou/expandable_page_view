import 'package:expandable_page_view/src/expandable_page_view.dart';
import 'package:flutter_test/flutter_test.dart';

extension PageViewHeight on WidgetTester {
  double get pageViewHeight => getSize(find.byType(ExpandablePageView)).height;
}
