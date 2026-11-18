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

    test('keeps realPage when itemCount increases before being attached', () {
      final controller = ExpandablePageController(itemCount: 3, initialPage: 1);
      controller.itemCount = 7;
      expect(controller.itemCount, 7);
      expect(controller.realPage, 1);
      controller.dispose();
    });

    test('keeps realPage when itemCount decreases and the page still exists', () {
      final controller = ExpandablePageController(itemCount: 4, initialPage: 1);
      controller.itemCount = 3;
      expect(controller.realPage, 1);
      controller.dispose();
    });

    test('moves realPage to the last page when itemCount removes the current page', () {
      final controller = ExpandablePageController(itemCount: 3, initialPage: 2);
      controller.itemCount = 2;
      expect(controller.realPage, 1);
      controller.dispose();
    });

    test('keeps realPage across several itemCount changes', () {
      final controller = ExpandablePageController(itemCount: 2, initialPage: 1);
      controller.itemCount = 3;
      controller.itemCount = 5;
      controller.itemCount = 4;
      expect(controller.realPage, 1);
      controller.dispose();
    });
  });
}
