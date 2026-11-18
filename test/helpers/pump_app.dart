import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    await pumpAppFrame(widget);
    await pumpAndSettle();
  }

  Future<void> pumpAppFrame(Widget widget) {
    return pumpWidget(
      MediaQuery.fromView(
        view: view,
        child: Directionality(
          textDirection: TextDirection.ltr,
          // Matches the constraints a Scaffold gives its body when there is no app bar
          // or bottom widget: loose up to the screen size, placed at the top left.
          child: Align(alignment: Alignment.topLeft, child: widget),
        ),
      ),
    );
  }
}
