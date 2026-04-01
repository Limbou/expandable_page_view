import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpandablePageController', () {
    test('constructs with required itemCount', () {
      final controller = ExpandablePageController(itemCount: 5);
      expect(controller.itemCount, 5);
      controller.dispose();
    });

    test('sets virtual initialPage based on itemCount and initialPage', () {
      final controller = ExpandablePageController(
        itemCount: 3,
        initialPage: 1,
      );
      // Virtual initial page = 10000 * 3 + 1 = 30001
      expect(controller.initialPage, 30001);
      controller.dispose();
    });

    test('sets virtual initialPage for default initialPage 0', () {
      final controller = ExpandablePageController(itemCount: 5);
      // Virtual initial page = 10000 * 5 + 0 = 50000
      expect(controller.initialPage, 50000);
      controller.dispose();
    });

    test('preserves viewportFraction', () {
      final controller = ExpandablePageController(
        itemCount: 3,
        viewportFraction: 0.8,
      );
      expect(controller.viewportFraction, 0.8);
      controller.dispose();
    });

    test('preserves keepPage', () {
      final controller = ExpandablePageController(
        itemCount: 3,
        keepPage: false,
      );
      expect(controller.keepPage, false);
      controller.dispose();
    });
  });
}
