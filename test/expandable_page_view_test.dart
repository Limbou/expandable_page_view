import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/page_view_height.dart';
import 'helpers/pump_app.dart';

const nextPageScrollOffset = Offset(-500, 0);
const previousPageScrollOffset = Offset(500, 0);
const screenSize = Size(800, 600);

void main() {
  final redContainer = find.byWidgetPredicate((widget) => widget is Container && widget.color == Colors.red);
  final blueContainer = find.byWidgetPredicate((widget) => widget is Container && widget.color == Colors.blue);
  final greenContainer = find.byWidgetPredicate((widget) => widget is Container && widget.color == Colors.green);

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
