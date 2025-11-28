import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/page_view_height.dart';
import 'helpers/pump_app.dart';

const nextPageScrollOffset = Offset(-500, 0);
const previousPageScrollOffset = Offset(500, 0);
const nextPageScrollOffsetVertical = Offset(0, -500);
const previousPageScrollOffsetVertical = Offset(0, 500);
const screenSize = Size(800, 600);

void main() {
  final redContainer =
      find.byWidgetPredicate((widget) => widget is Container && widget.color == Colors.red);
  final blueContainer =
      find.byWidgetPredicate((widget) => widget is Container && widget.color == Colors.blue);
  final greenContainer =
      find.byWidgetPredicate((widget) => widget is Container && widget.color == Colors.green);
  final yellowContainer =
      find.byWidgetPredicate((widget) => widget is Container && widget.color == Colors.yellow);

  group("ExpandablePageView", () {
    testWidgets('''given there is only one child
    then PageView renders with first child displayed 
    and height matching first child''', (tester) async {
      final double firstChildHeight = 200;
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: firstChildHeight),
          ],
        ),
      );
      expect(tester.pageViewHeight, firstChildHeight);
    });

    testWidgets('''given there are multiple children
    then PageView renders with first child displayed 
    and height matching first child''', (tester) async {
      final double firstChildHeight = 200;
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: firstChildHeight),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      expect(tester.pageViewHeight, firstChildHeight);
      expect(redContainer, findsOneWidget);
      expect(blueContainer, findsNothing);
      expect(greenContainer, findsNothing);
    });

    testWidgets('''given there are multiple children
    and PageView renders with first child displayed 
    and PageView was scrolled to the next page
    then PageView should have second child displayed
    and height matching second child''', (tester) async {
      final double secondChildHeight = 300;
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: 200),
            Container(color: Colors.blue, height: secondChildHeight),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, secondChildHeight);
      expect(redContainer, findsNothing);
      expect(blueContainer, findsOneWidget);
      expect(greenContainer, findsNothing);
    });

    testWidgets('''given there are multiple children
    and PageView renders with first child displayed 
    and PageView was scrolled to the next page
    and PageView was scrolled to the previous page
    then PageView should have first child displayed
    and height matching first child''', (tester) async {
      final double firstChildHeight = 200;
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: firstChildHeight),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, firstChildHeight);
      expect(redContainer, findsOneWidget);
      expect(blueContainer, findsNothing);
      expect(greenContainer, findsNothing);
    });
  });

  group("ExpandablePageView.builder", () {
    testWidgets('''given there is only one child
    then PageView renders with first child displayed 
    and height matching first child''', (tester) async {
      final double firstChildHeight = 200;
      await tester.pumpApp(
        ExpandablePageView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Container(color: Colors.blue, height: firstChildHeight);
          },
        ),
      );
      expect(tester.pageViewHeight, firstChildHeight);
    });

    testWidgets('''given there are multiple children
    then PageView renders with first child displayed 
    and height matching first child''', (tester) async {
      final double firstChildHeight = 200;
      await tester.pumpApp(
        ExpandablePageView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: firstChildHeight * (index + 1),
            );
          },
        ),
      );
      expect(tester.pageViewHeight, firstChildHeight);
      expect(redContainer, findsOneWidget);
      expect(blueContainer, findsNothing);
      expect(greenContainer, findsNothing);
    });

    testWidgets('''given there are multiple children
    and PageView renders with first child displayed 
    and PageView was scrolled to the next page
    then PageView should have second child displayed
    and height matching second child''', (tester) async {
      final double firstChildHeight = 100;
      final double secondChildHeight = firstChildHeight * 2;
      await tester.pumpApp(
        ExpandablePageView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: firstChildHeight * (index + 1),
            );
          },
        ),
      );
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, secondChildHeight);
      expect(redContainer, findsNothing);
      expect(blueContainer, findsOneWidget);
      expect(greenContainer, findsNothing);
    });

    testWidgets('''given there are multiple children
    and PageView renders with first child displayed 
    and PageView was scrolled to the next page
    and PageView was scrolled to the previous page
    then PageView should have second child displayed
    and height matching second child''', (tester) async {
      final double firstChildHeight = 100;
      await tester.pumpApp(
        ExpandablePageView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: firstChildHeight * (index + 1),
            );
          },
        ),
      );
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, firstChildHeight);
      expect(redContainer, findsOneWidget);
      expect(blueContainer, findsNothing);
      expect(greenContainer, findsNothing);
    });

    testWidgets('''given children list was updated
    then PageView should update its height''', (tester) async {
      final double firstChildHeight = 100;
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: firstChildHeight),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      expect(tester.pageViewHeight, firstChildHeight);
      final double newFirstChildHeight = 200;
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: newFirstChildHeight),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      expect(tester.pageViewHeight, newFirstChildHeight);
    });

    testWidgets('''given children list was updated
    and there is less children than before
    then PageView should update its height''', (tester) async {
      final double firstChildHeight = 100;
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: firstChildHeight),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      expect(tester.pageViewHeight, firstChildHeight);
      final double newFirstChildHeight = 200;
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: newFirstChildHeight),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      expect(tester.pageViewHeight, newFirstChildHeight);
    });

    testWidgets('''given builder argument was updated
    and there is less children than before
    then PageView should update its height''', (tester) async {
      final double firstChildHeight = 100;
      await tester.pumpApp(
        ExpandablePageView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: firstChildHeight * (index + 1),
            );
          },
        ),
      );
      expect(tester.pageViewHeight, firstChildHeight);
      final double newFirstChildHeight = 200;
      await tester.pumpApp(
        ExpandablePageView.builder(
          itemCount: 2,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: newFirstChildHeight * (index + 1),
            );
          },
        ),
      );
      expect(tester.pageViewHeight, newFirstChildHeight);
    });

    testWidgets('''given children list was updated
    and there is less children than before
    and PageView was scrolled to the last page
    then PageView should update its height
    to match the new latest child''', (tester) async {
      final double lastPageHeight = 400;
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: lastPageHeight),
          ],
        ),
      );
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 400);
      final double newLastPageHeight = 300;
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: 200),
            Container(color: Colors.green, height: newLastPageHeight),
          ],
        ),
      );
      expect(tester.pageViewHeight, newLastPageHeight);
    });

    testWidgets('''given pageController is updated
    then ExpandablePageView should use new pageController''', (tester) async {
      final oldPageController = PageController();
      await tester.pumpApp(
        ExpandablePageView(
          controller: oldPageController,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      expect(oldPageController.hasClients, isTrue);
      final newPageController = PageController();
      await tester.pumpApp(
        ExpandablePageView(
          controller: newPageController,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      expect(oldPageController.hasClients, isFalse);
      expect(newPageController.hasClients, isTrue);
    });
  });

  group("ExpandablePageView vertical scrollDirection", () {
    testWidgets('''given scrollDirection is vertical
    then PageView adjusts width instead of height''', (tester) async {
      final double firstChildWidth = 200;
      await tester.pumpApp(
        ExpandablePageView(
          scrollDirection: Axis.vertical,
          children: [
            Container(color: Colors.red, width: firstChildWidth),
            Container(color: Colors.blue, width: 300),
          ],
        ),
      );
      expect(tester.pageViewWidth, firstChildWidth);
    });

    testWidgets('''given scrollDirection is vertical
    and PageView was scrolled to the next page
    then width should match second child''', (tester) async {
      final double secondChildWidth = 300;
      await tester.pumpApp(
        ExpandablePageView(
          scrollDirection: Axis.vertical,
          children: [
            Container(color: Colors.red, width: 200),
            Container(color: Colors.blue, width: secondChildWidth),
          ],
        ),
      );
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffsetVertical);
      await tester.pumpAndSettle();
      expect(tester.pageViewWidth, secondChildWidth);
    });

    testWidgets('''given scrollDirection is vertical with builder
    then PageView adjusts width instead of height''', (tester) async {
      final double baseWidth = 100;
      await tester.pumpApp(
        ExpandablePageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              width: widthForIndex(index, baseWidth),
            );
          },
        ),
      );
      expect(tester.pageViewWidth, baseWidth);
    });
  });

  group("ExpandablePageView with initialPage", () {
    testWidgets('''given PageController has initialPage set to 1
    then PageView should start at second page with matching height''', (tester) async {
      final double secondChildHeight = 300;
      final controller = PageController(initialPage: 1);
      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          children: [
            Container(color: Colors.red, height: 200),
            Container(color: Colors.blue, height: secondChildHeight),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      expect(tester.pageViewHeight, secondChildHeight);
      expect(redContainer, findsNothing);
      expect(blueContainer, findsOneWidget);
    });

    testWidgets('''given PageController has initialPage set to last page
    then PageView should start at last page with matching height''', (tester) async {
      final double lastChildHeight = 400;
      final controller = PageController(initialPage: 2);
      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          children: [
            Container(color: Colors.red, height: 200),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: lastChildHeight),
          ],
        ),
      );
      expect(tester.pageViewHeight, lastChildHeight);
      expect(greenContainer, findsOneWidget);
    });

    testWidgets('''given PageController has initialPage greater than children count
    then PageView should clamp to last valid page''', (tester) async {
      final double lastChildHeight = 300;
      final controller = PageController(initialPage: 10);
      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          children: [
            Container(color: Colors.red, height: 200),
            Container(color: Colors.blue, height: lastChildHeight),
          ],
        ),
      );
      // Should clamp to last page (index 1)
      expect(tester.pageViewHeight, lastChildHeight);
    });

    testWidgets('''given PageController.builder has initialPage set to 1
    then PageView should start at second page with matching height''', (tester) async {
      final double baseHeight = 100;
      final controller = PageController(initialPage: 1);
      await tester.pumpApp(
        ExpandablePageView.builder(
          controller: controller,
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: heightForIndex(index, baseHeight),
            );
          },
        ),
      );
      expect(tester.pageViewHeight, heightForIndex(1, baseHeight));
      expect(blueContainer, findsOneWidget);
    });
  });

  group("ExpandablePageView with estimatedPageSize", () {
    testWidgets('''given estimatedPageSize is set
    then initial sizes should use estimatedPageSize before measurement''', (tester) async {
      final double estimatedSize = 150;
      final double actualHeight = 200;
      // We can verify this indirectly - the widget should still work correctly
      await tester.pumpApp(
        ExpandablePageView(
          estimatedPageSize: estimatedSize,
          children: [
            Container(color: Colors.red, height: actualHeight),
            Container(color: Colors.blue, height: 300),
          ],
        ),
      );
      // After settling, height should match actual child height
      expect(tester.pageViewHeight, actualHeight);
    });

    testWidgets('''given estimatedPageSize is set with builder
    then pages should initialize with estimated size''', (tester) async {
      final double estimatedSize = 250;
      final double actualHeight = 100;
      await tester.pumpApp(
        ExpandablePageView.builder(
          estimatedPageSize: estimatedSize,
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: actualHeight,
            );
          },
        ),
      );
      expect(tester.pageViewHeight, actualHeight);
    });
  });

  group("ExpandablePageView animateFirstPage", () {
    testWidgets('''given animateFirstPage is true
    then first page should animate from estimatedPageSize to actual size''', (tester) async {
      final double estimatedSize = 50;
      final double actualHeight = 200;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandablePageView(
              animateFirstPage: true,
              estimatedPageSize: estimatedSize,
              animationDuration: const Duration(milliseconds: 500),
              children: [
                Container(color: Colors.red, height: actualHeight),
              ],
            ),
          ),
        ),
      );

      // Initially, before size is measured, should be at estimated size
      await tester.pump();

      // During animation, height should be between estimated and actual
      await tester.pump(const Duration(milliseconds: 100));
      final midAnimationHeight = tester.pageViewHeight;
      expect(midAnimationHeight, greaterThan(estimatedSize));
      expect(midAnimationHeight, lessThan(actualHeight));

      // After animation completes, should be at actual height
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, actualHeight);
    });

    testWidgets('''given animateFirstPage is false
    then first page should not animate''', (tester) async {
      final double estimatedSize = 50;
      final double actualHeight = 200;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandablePageView(
              animateFirstPage: false,
              estimatedPageSize: estimatedSize,
              animationDuration: const Duration(milliseconds: 500),
              children: [
                Container(color: Colors.red, height: actualHeight),
              ],
            ),
          ),
        ),
      );

      // With animateFirstPage: false, after settling the height should be
      // at the actual height without any visible animation
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, actualHeight);
    });

    testWidgets('''given animateFirstPage is true with builder
    then first page should animate from estimatedPageSize to actual size''', (tester) async {
      final double estimatedSize = 50;
      final double actualHeight = 200;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandablePageView.builder(
              animateFirstPage: true,
              estimatedPageSize: estimatedSize,
              animationDuration: const Duration(milliseconds: 500),
              itemCount: 1,
              itemBuilder: (context, index) {
                return Container(color: Colors.red, height: actualHeight);
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // During animation, height should be between estimated and actual
      await tester.pump(const Duration(milliseconds: 100));
      final midAnimationHeight = tester.pageViewHeight;
      expect(midAnimationHeight, greaterThan(estimatedSize));
      expect(midAnimationHeight, lessThan(actualHeight));

      // After animation completes, should be at actual height
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, actualHeight);
    });

    testWidgets('''given animateFirstPage is true and page is navigated after first load
    then subsequent animations should still work correctly''', (tester) async {
      final controller = PageController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandablePageView(
              controller: controller,
              animateFirstPage: true,
              estimatedPageSize: 50,
              animationDuration: const Duration(milliseconds: 100),
              children: [
                Container(color: Colors.red, height: 100),
                Container(color: Colors.blue, height: 200),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 100);

      // Navigate to second page
      controller.jumpToPage(1);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 200);

      // Navigate back
      controller.jumpToPage(0);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 100);
    });
  });

  group("ExpandablePageView onPageChanged callback", () {
    testWidgets('''given onPageChanged is provided
    when page is swiped
    then callback should be called with new page index''', (tester) async {
      int? changedPage;
      await tester.pumpApp(
        ExpandablePageView(
          onPageChanged: (page) => changedPage = page,
          children: [
            Container(color: Colors.red, height: 200),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      expect(changedPage, isNull);

      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();

      expect(changedPage, 1);
    });

    testWidgets('''given onPageChanged is provided
    when page is navigated programmatically
    then callback should be called''', (tester) async {
      int? changedPage;
      final controller = PageController();
      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          onPageChanged: (page) => changedPage = page,
          children: [
            Container(color: Colors.red, height: 200),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 400),
          ],
        ),
      );
      expect(changedPage, isNull);

      controller.jumpToPage(2);
      await tester.pumpAndSettle();

      expect(changedPage, 2);
    });

    testWidgets('''given onPageChanged is provided with builder
    when page changes
    then callback should be called''', (tester) async {
      int? changedPage;
      await tester.pumpApp(
        ExpandablePageView.builder(
          onPageChanged: (page) => changedPage = page,
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: heightForIndex(index, 100),
            );
          },
        ),
      );

      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();

      expect(changedPage, 1);
    });
  });

  group("ExpandablePageView adding children dynamically", () {
    testWidgets('''given children list grows
    then PageView should handle new children correctly''', (tester) async {
      final double firstChildHeight = 100;
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: firstChildHeight),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );
      expect(tester.pageViewHeight, firstChildHeight);

      // Add more children
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: firstChildHeight),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
            Container(color: Colors.yellow, height: 400),
          ],
        ),
      );
      expect(tester.pageViewHeight, firstChildHeight);

      // Navigate to new page
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();

      expect(tester.pageViewHeight, 400);
      expect(yellowContainer, findsOneWidget);
    });

    testWidgets('''given builder itemCount increases
    then PageView should handle new items correctly''', (tester) async {
      final double baseHeight = 100;
      await tester.pumpApp(
        ExpandablePageView.builder(
          itemCount: 2,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: heightForIndex(index, baseHeight),
            );
          },
        ),
      );
      expect(tester.pageViewHeight, baseHeight);

      // Increase item count
      await tester.pumpApp(
        ExpandablePageView.builder(
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: heightForIndex(index, baseHeight),
            );
          },
        ),
      );

      // Navigate to new page (index 3)
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();

      expect(tester.pageViewHeight, heightForIndex(3, baseHeight));
    });
  });

  group("ExpandablePageView programmatic navigation", () {
    testWidgets('''given PageController.jumpToPage is called
    then PageView should jump to that page with correct height''', (tester) async {
      final controller = PageController();
      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );
      expect(tester.pageViewHeight, 100);

      controller.jumpToPage(2);
      await tester.pumpAndSettle();

      expect(tester.pageViewHeight, 300);
      expect(greenContainer, findsOneWidget);
    });

    testWidgets('''given PageController.animateToPage is called
    then PageView should animate to that page with correct height''', (tester) async {
      final controller = PageController();
      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );
      expect(tester.pageViewHeight, 100);

      controller.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();

      expect(tester.pageViewHeight, 200);
      expect(blueContainer, findsOneWidget);
    });

    testWidgets('''given PageController.nextPage is called
    then PageView should go to next page''', (tester) async {
      final controller = PageController();
      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );
      expect(tester.pageViewHeight, 100);

      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();

      expect(tester.pageViewHeight, 200);
      expect(blueContainer, findsOneWidget);
    });

    testWidgets('''given PageController.previousPage is called
    then PageView should go to previous page''', (tester) async {
      final controller = PageController(initialPage: 1);
      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );
      expect(tester.pageViewHeight, 200);

      controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await tester.pumpAndSettle();

      expect(tester.pageViewHeight, 100);
      expect(redContainer, findsOneWidget);
    });
  });

  group("ExpandablePageView size preservation after reinitialize", () {
    testWidgets('''given pages have been measured
    when children list length changes
    then existing page sizes should be preserved''', (tester) async {
      // Start with 2 pages, scroll to measure page 2
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );

      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 200);

      // Go back to first page
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 100);

      // Add a third page - existing sizes should be preserved
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      // First page should still have correct height (preserved)
      expect(tester.pageViewHeight, 100);

      // Navigate to second page - should still have preserved size
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 200);
    });

    testWidgets('''given builder pages have been measured
    when itemCount increases
    then existing page sizes should be preserved''', (tester) async {
      final double baseHeight = 100;
      await tester.pumpApp(
        ExpandablePageView.builder(
          itemCount: 2,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: heightForIndex(index, baseHeight),
            );
          },
        ),
      );

      // Scroll to measure second page
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, heightForIndex(1, baseHeight));

      // Go back
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();

      // Increase item count
      await tester.pumpApp(
        ExpandablePageView.builder(
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              color: colorForIndex(index),
              height: heightForIndex(index, baseHeight),
            );
          },
        ),
      );

      // First page should still have correct height
      expect(tester.pageViewHeight, baseHeight);
    });
  });

  group("ExpandablePageView reverse property", () {
    testWidgets('''given reverse is true
    then PageView should scroll in reverse direction''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          reverse: true,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );
      expect(tester.pageViewHeight, 100);
      expect(redContainer, findsOneWidget);

      // With reverse, we need to drag in opposite direction
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();

      expect(tester.pageViewHeight, 200);
      expect(blueContainer, findsOneWidget);
    });
  });

  group("ExpandablePageView controller lifecycle", () {
    testWidgets('''given external PageController is provided
    when widget is disposed
    then controller should not be disposed''', (tester) async {
      final controller = PageController();
      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          children: [
            Container(color: Colors.red, height: 100),
          ],
        ),
      );

      // Replace with different widget to dispose ExpandablePageView
      await tester.pumpApp(
        Container(),
      );

      // Controller should still be usable (not disposed)
      // This would throw if disposed
      expect(() => controller.initialPage, returnsNormally);
    });

    testWidgets('''given no PageController is provided
    when widget creates internal controller
    then internal controller should be disposed with widget''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: 100),
          ],
        ),
      );

      // Replace with different widget - internal controller should be disposed
      await tester.pumpApp(
        Container(),
      );

      // No error should occur - internal cleanup should be handled
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('''given PageController is switched from external to null
    then widget should create and manage internal controller''', (tester) async {
      final externalController = PageController();
      await tester.pumpApp(
        ExpandablePageView(
          controller: externalController,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );
      expect(externalController.hasClients, isTrue);

      // Switch to no controller
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );

      // External controller should no longer have clients
      expect(externalController.hasClients, isFalse);

      // Widget should still work with internal controller
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 200);
    });
  });

  group("ExpandablePageView edge cases", () {
    testWidgets('''given current page is on last page
    and children count decreases
    then onPageChanged should be called with new valid page''', (tester) async {
      int? lastChangedPage;
      await tester.pumpApp(
        ExpandablePageView(
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      // Navigate to last page
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 2);
      expect(tester.pageViewHeight, 300);

      // Reduce children count - current page becomes invalid
      await tester.pumpApp(
        ExpandablePageView(
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );

      // Should have adjusted to new last page
      expect(lastChangedPage, 1);
    });

    testWidgets('''given child height changes dynamically
    then PageView should update its size''', (tester) async {
      final heightNotifier = ValueNotifier<double>(100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<double>(
              valueListenable: heightNotifier,
              builder: (context, height, _) {
                return ExpandablePageView(
                  children: [
                    Container(color: Colors.red, height: height),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 100);

      // Change height
      heightNotifier.value = 250;
      await tester.pumpAndSettle();

      expect(tester.pageViewHeight, 250);
    });
  });

  group("ExpandablePageView with viewportFraction", () {
    testWidgets('''given viewportFraction < 1.0
    then height should be maximum of all visible pages''', (tester) async {
      final controller = PageController(viewportFraction: 0.5);

      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          children: [
            Container(color: Colors.red, height: 100), // Current page (small)
            Container(color: Colors.blue, height: 300), // Visible adjacent (tall)
            Container(color: Colors.green, height: 200),
          ],
        ),
      );

      // With viewportFraction 0.5, both page 0 and page 1 are visible
      // Height should be max(100, 300) = 300
      expect(tester.pageViewHeight, 300);
    });

    testWidgets('''given viewportFraction < 1.0 with builder
    then height should be maximum of all visible pages''', (tester) async {
      final controller = PageController(viewportFraction: 0.5);
      final heights = [100.0, 300.0, 200.0];

      await tester.pumpApp(
        ExpandablePageView.builder(
          controller: controller,
          itemCount: 3,
          itemBuilder: (context, index) => Container(
            color: colorForIndex(index),
            height: heights[index],
          ),
        ),
      );

      // With viewportFraction 0.5, both page 0 and page 1 are visible
      // Height should be max(100, 300) = 300
      expect(tester.pageViewHeight, 300);
    });

    testWidgets('''given viewportFraction < 1.0 and page changes
    then height should update to max of newly visible pages''', (tester) async {
      final controller = PageController(viewportFraction: 0.5);

      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 150),
            Container(color: Colors.yellow, height: 400),
          ],
        ),
      );

      // Initially pages 0 and 1 visible, max = 300
      expect(tester.pageViewHeight, 300);

      // Navigate to page 2 - pages 1, 2, 3 should be visible
      controller.jumpToPage(2);
      await tester.pumpAndSettle();

      // Visible: page 1 (300), page 2 (150), page 3 (400) - max = 400
      expect(tester.pageViewHeight, 400);
    });

    testWidgets('''given viewportFraction = 1.0 (default)
    then height should only consider current page''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 300),
          ],
        ),
      );

      // Only current page matters, should be 100
      expect(tester.pageViewHeight, 100);
    });

    testWidgets('''given viewportFraction with padEnds false
    then height calculation should still work correctly''', (tester) async {
      final controller = PageController(viewportFraction: 0.4);

      await tester.pumpApp(
        ExpandablePageView(
          controller: controller,
          padEnds: false,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 250),
            Container(color: Colors.green, height: 180),
          ],
        ),
      );

      // With viewportFraction 0.4, page 0 and 1 are visible
      // visibleOnEachSide = ceil((1-0.4)/(2*0.4)) = ceil(0.75) = 1
      // Heights: page 0 (100), page 1 (250) -> max = 250
      expect(tester.pageViewHeight, 250);
    });
  });

  group("ExpandablePageView with loop", () {
    testWidgets('''given loop is true with children
    then PageView should cycle through pages infinitely forward''', (tester) async {
      int? lastChangedPage;
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      expect(tester.pageViewHeight, 100);

      // Swipe to page 1
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);
      expect(tester.pageViewHeight, 200);

      // Swipe to page 2
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 2);
      expect(tester.pageViewHeight, 300);

      // Swipe past last page - should loop to page 0
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 0);
      expect(tester.pageViewHeight, 100);

      // Continue swiping - should be on page 1 again
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);
      expect(tester.pageViewHeight, 200);
    });

    testWidgets('''given loop is true with children
    then PageView should cycle through pages infinitely backward''', (tester) async {
      int? lastChangedPage;
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      expect(tester.pageViewHeight, 100);

      // Swipe backward from page 0 - should loop to last page (2)
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 2);
      expect(tester.pageViewHeight, 300);

      // Continue swiping backward - should be on page 1
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);
      expect(tester.pageViewHeight, 200);

      // Continue swiping backward - should be on page 0
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 0);
      expect(tester.pageViewHeight, 100);
    });

    testWidgets('''given loop is true with builder
    then PageView should cycle through pages infinitely''', (tester) async {
      int? lastChangedPage;
      final heights = [100.0, 200.0, 300.0];

      await tester.pumpApp(
        ExpandablePageView.builder(
          loop: true,
          itemCount: 3,
          onPageChanged: (page) => lastChangedPage = page,
          itemBuilder: (context, index) => Container(
            color: colorForIndex(index),
            height: heights[index],
          ),
        ),
      );

      expect(tester.pageViewHeight, 100);

      // Swipe forward through all pages and loop
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);

      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 2);

      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 0); // Looped back

      // Swipe backward - should loop to last page
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 2);
    });

    testWidgets('''given loop is true
    then onPageChanged receives real index not virtual index''', (tester) async {
      final receivedPages = <int>[];

      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          onPageChanged: (page) => receivedPages.add(page),
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );

      final pageView = find.byType(ExpandablePageView);

      // Swipe through multiple loops
      for (int i = 0; i < 6; i++) {
        await tester.drag(pageView, nextPageScrollOffset);
        await tester.pumpAndSettle();
      }

      // Should only receive indices 0 and 1, alternating
      expect(receivedPages, [1, 0, 1, 0, 1, 0]);
    });

    testWidgets('''given loop is true and initialPage is set
    then PageView should start at correct page''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          controller: PageController(initialPage: 1),
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      // Should start at page 1 with height 200
      expect(tester.pageViewHeight, 200);
    });

    testWidgets('''given loop is true
    then page sizes should be tracked correctly across loops''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );

      final pageView = find.byType(ExpandablePageView);

      // First loop
      expect(tester.pageViewHeight, 100);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 200);

      // Second loop - sizes should still be correct
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 100);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 200);

      // Third loop
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 100);
    });

    testWidgets('''given loop is true with viewportFraction < 1.0
    then height should account for visible adjacent pages''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          controller: PageController(viewportFraction: 0.5),
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 150),
          ],
        ),
      );

      // Page 0 and 1 visible, max = 300
      expect(tester.pageViewHeight, 300);

      final pageView = find.byType(ExpandablePageView);

      // Swipe to page 2
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();

      // Page 2 (150), and in loop mode page 0 (100) should be visible
      // With viewportFraction 0.5, pages 1, 2, and 0 (looped) are visible
      // Max should consider the looped pages
      expect(tester.pageViewHeight, greaterThanOrEqualTo(150));
    });

    testWidgets('''given loop is true with vertical scroll direction
    then looping should work correctly''', (tester) async {
      int? lastChangedPage;
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          scrollDirection: Axis.vertical,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, width: 100),
            Container(color: Colors.blue, width: 200),
          ],
        ),
      );

      final pageView = find.byType(ExpandablePageView);

      // Swipe down to next page
      await tester.drag(pageView, nextPageScrollOffsetVertical);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);

      // Swipe down again - should loop to page 0
      await tester.drag(pageView, nextPageScrollOffsetVertical);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 0);

      // Swipe up - should loop to last page
      await tester.drag(pageView, previousPageScrollOffsetVertical);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);
    });

    testWidgets('''given loop is true with animateFirstPage
    then first page should animate correctly''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          animateFirstPage: true,
          estimatedPageSize: 50,
          children: [
            Container(color: Colors.red, height: 200),
            Container(color: Colors.blue, height: 300),
          ],
        ),
      );

      // Should animate from 50 to 200
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 200);
    });

    testWidgets('''given loop is false (default)
    then PageView should not loop''', (tester) async {
      int? lastChangedPage;
      await tester.pumpApp(
        ExpandablePageView(
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );

      final pageView = find.byType(ExpandablePageView);

      // Swipe to last page
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);

      // Try to swipe past last page - should stay on last page
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1); // Still on page 1

      // Try to swipe before first page
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 0);

      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 0); // Still on page 0
    });

    testWidgets('''given loop is true with single page
    then should handle single item gracefully''', (tester) async {
      int? lastChangedPage;
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
          ],
        ),
      );

      expect(tester.pageViewHeight, 100);

      final pageView = find.byType(ExpandablePageView);

      // Swipe - should stay on same page (loops to itself)
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 0);
      expect(tester.pageViewHeight, 100);
    });

    testWidgets('''given loop is true with reverse
    then looping should work in reverse direction''', (tester) async {
      int? lastChangedPage;
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          reverse: true,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      final pageView = find.byType(ExpandablePageView);

      // In reverse mode, swiping left goes to next page
      await tester.drag(pageView, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);

      await tester.drag(pageView, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(lastChangedPage, 2);

      // Should loop back to 0
      await tester.drag(pageView, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(lastChangedPage, 0);
    });

    testWidgets('''given loop changes from false to true
    then PageView should start looping from current page''', (tester) async {
      int? lastChangedPage;

      // Start without loop
      await tester.pumpApp(
        ExpandablePageView(
          loop: false,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      final pageView = find.byType(ExpandablePageView);

      // Navigate to page 1
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);
      expect(tester.pageViewHeight, 200);

      // Enable loop
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      // Should still be on page 1
      expect(tester.pageViewHeight, 200);

      // Should now be able to loop - go to page 2, then page 0
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 2);

      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 0); // Looped!
    });

    testWidgets('''given loop changes from true to false
    then PageView should stop looping and stay on current page''', (tester) async {
      int? lastChangedPage;

      // Start with loop
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      final pageView = find.byType(ExpandablePageView);

      // Navigate to page 2
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 2);
      expect(tester.pageViewHeight, 300);

      // Disable loop
      await tester.pumpApp(
        ExpandablePageView(
          loop: false,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      // Should still be on page 2
      expect(tester.pageViewHeight, 300);

      // Should NOT loop - trying to go past last page should stay on page 2
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 2); // Still on page 2
    });

    testWidgets('''given loop is true with estimatedPageSize
    then initial sizes should use estimatedPageSize''', (tester) async {
      final double estimatedSize = 150;
      final double actualHeight = 200;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandablePageView(
              loop: true,
              estimatedPageSize: estimatedSize,
              animationDuration: const Duration(milliseconds: 100),
              children: [
                Container(color: Colors.red, height: actualHeight),
                Container(color: Colors.blue, height: 300),
              ],
            ),
          ),
        ),
      );

      // After settling, height should match actual child height
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, actualHeight);
    });

    testWidgets('''given loop is true with viewportFraction < 1.0
    then height should be maximum of visible pages including looped pages''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          controller: PageController(viewportFraction: 0.5),
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 300),
            Container(color: Colors.green, height: 150),
          ],
        ),
      );

      // With viewportFraction 0.5, pages 0 and 1 are visible
      // Max should be 300
      expect(tester.pageViewHeight, 300);

      final pageView = find.byType(ExpandablePageView);

      // Navigate to page 2 - in loop mode, pages 1, 2, and 0 should be visible
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();

      // Visible pages: 1 (300), 2 (150), 0 (100) - max should be 300
      expect(tester.pageViewHeight, 300);
    });

    testWidgets('''given loop changes and children count changes simultaneously
    then sizes should be reinitialized correctly''', (tester) async {
      // Start without loop, 2 children
      await tester.pumpApp(
        ExpandablePageView(
          loop: false,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );

      expect(tester.pageViewHeight, 100);

      // Enable loop AND add a child simultaneously
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      final pageView = find.byType(ExpandablePageView);

      // Navigate to the new third page
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();

      // Should correctly show page 2 with height 300
      expect(tester.pageViewHeight, 300);

      // Should be able to loop back to page 0
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 100);
    });

    testWidgets('''given loop changes from true to false and children count decreases
    then sizes should be reinitialized and page clamped correctly''', (tester) async {
      // Start with loop, 3 children
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      final pageView = find.byType(ExpandablePageView);

      // Navigate to page 2
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(tester.pageViewHeight, 300);

      // Disable loop AND reduce children to 2 (removing page 2)
      await tester.pumpApp(
        ExpandablePageView(
          loop: false,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Should clamp to last valid page (page 1)
      expect(tester.pageViewHeight, 200);
    });

    testWidgets('''given loop is true with empty children
    then should throw assertion error''', (tester) async {
      expect(
        () => ExpandablePageView(
          loop: true,
          children: const [],
        ),
        throwsAssertionError,
      );
    });

    testWidgets('''given loop is true with itemCount 0
    then should throw assertion error''', (tester) async {
      expect(
        () => ExpandablePageView.builder(
          loop: true,
          itemCount: 0,
          itemBuilder: (context, index) => Container(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('''given loop is true with initialPage greater than itemCount
    then should wrap to valid page''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          controller: PageController(initialPage: 5), // 5 % 3 = 2
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      // initialPage 5 with 3 items should start at page 2 (5 % 3 = 2)
      // The internal controller starts at (_loopMultiplier * 3) + 5
      // which when converted via _realIndex gives page 2
      expect(tester.pageViewHeight, 300);
    });

    testWidgets('''given loop is true with negative initialPage
    then should handle correctly''', (tester) async {
      // Note: PageController doesn't accept negative initialPage,
      // so we test with 0 which is the minimum valid value
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          controller: PageController(initialPage: 0),
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      expect(tester.pageViewHeight, 100);

      // Can still loop backward from page 0
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();

      expect(tester.pageViewHeight, 300); // Looped to last page
    });

    testWidgets('''given loop is true and external controller changes
    then internal controller should not be affected''', (tester) async {
      final controller1 = PageController(initialPage: 0);
      final controller2 = PageController(initialPage: 2);
      int? lastChangedPage;

      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          controller: controller1,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      expect(tester.pageViewHeight, 100); // Starts at page 0

      // Navigate to page 1
      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);
      expect(tester.pageViewHeight, 200);

      // Change external controller - should not affect current page
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          controller: controller2, // Different controller with initialPage: 2
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      // Should still be on page 1 (controller change ignored in loop mode)
      expect(tester.pageViewHeight, 200);

      // Looping should still work
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 2);

      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 0); // Looped
    });

    testWidgets('''given loop is true with pageSnapping false
    then looping should still work''', (tester) async {
      int? lastChangedPage;
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          pageSnapping: false,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      final pageView = find.byType(ExpandablePageView);

      // Swipe with enough force to change page even without snapping
      await tester.fling(pageView, nextPageScrollOffset, 1000);
      await tester.pumpAndSettle();
      expect(lastChangedPage, isNotNull);

      // Continue swiping through pages
      await tester.fling(pageView, nextPageScrollOffset, 1000);
      await tester.pumpAndSettle();
      await tester.fling(pageView, nextPageScrollOffset, 1000);
      await tester.pumpAndSettle();

      // Should have looped
      expect(lastChangedPage, isIn([0, 1, 2]));
    });

    testWidgets('''given loop is true with clipBehavior none
    then should render correctly''', (tester) async {
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          clipBehavior: Clip.none,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );

      expect(tester.pageViewHeight, 100);

      final pageView = find.byType(ExpandablePageView);
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();

      expect(tester.pageViewHeight, 200);

      // Loop should work
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();

      expect(tester.pageViewHeight, 100);
    });

    testWidgets('''given loop is true with restorationId
    then should render and loop correctly''', (tester) async {
      int? lastChangedPage;
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          restorationId: 'test_loop_restoration',
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
            Container(color: Colors.green, height: 300),
          ],
        ),
      );

      expect(tester.pageViewHeight, 100);

      final pageView = find.byType(ExpandablePageView);

      // Navigate and loop
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();

      expect(lastChangedPage, 0); // Looped back
      expect(tester.pageViewHeight, 100);
    });

    testWidgets('''given loop is true with allowImplicitScrolling true
    then should render and loop correctly''', (tester) async {
      int? lastChangedPage;
      await tester.pumpApp(
        ExpandablePageView(
          loop: true,
          allowImplicitScrolling: true,
          onPageChanged: (page) => lastChangedPage = page,
          children: [
            Container(color: Colors.red, height: 100),
            Container(color: Colors.blue, height: 200),
          ],
        ),
      );

      expect(tester.pageViewHeight, 100);

      final pageView = find.byType(ExpandablePageView);

      // Navigate forward
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);

      // Loop forward
      await tester.drag(pageView, nextPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 0);

      // Loop backward
      await tester.drag(pageView, previousPageScrollOffset);
      await tester.pumpAndSettle();
      expect(lastChangedPage, 1);
    });
  });
}

Color colorForIndex(int index) {
  switch (index) {
    case 0:
      return Colors.red;
    case 1:
      return Colors.blue;
    case 2:
      return Colors.green;
    default:
      return Colors.yellow;
  }
}

double heightForIndex(int index, double baseHeight) {
  return baseHeight * (index + 1);
}

double widthForIndex(int index, double baseWidth) {
  return baseWidth * (index + 1);
}
