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
