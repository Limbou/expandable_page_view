# ExpandablePageController Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow users to programmatically control an `ExpandablePageView` with `loop: true` via an `ExpandablePageController` that translates between real page indices and virtual indices.

**Architecture:** Create `ExpandablePageController` extending `PageController` that overrides `page`, `jumpToPage`, and `animateToPage` to work with real indices (0 to itemCount-1) while internally managing virtual indices for infinite scrolling. The widget detects when an `ExpandablePageController` is provided and uses it directly instead of creating an internal controller.

**Tech Stack:** Flutter/Dart, flutter_test

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `lib/src/expandable_page_controller.dart` | Create | `ExpandablePageController` class |
| `lib/expandable_page_view.dart` | Modify | Export `ExpandablePageController` |
| `lib/src/expandable_page_view.dart` | Modify | Detect and use `ExpandablePageController` in loop mode |
| `test/expandable_page_controller_test.dart` | Create | Unit tests for the controller |
| `test/expandable_page_view_test.dart` | Modify | Integration tests for controller + widget |

---

### Task 1: Create `ExpandablePageController` with `page` override

**Files:**
- Create: `lib/src/expandable_page_controller.dart`
- Create: `test/expandable_page_controller_test.dart`

- [ ] **Step 1: Write failing tests for construction and `realPage`**

Create `test/expandable_page_controller_test.dart`:

```dart
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test test/expandable_page_controller_test.dart`
Expected: Compilation error — `ExpandablePageController` not found.

- [ ] **Step 3: Implement `ExpandablePageController`**

Create `lib/src/expandable_page_controller.dart`:

```dart
import 'package:flutter/widgets.dart';

/// A [PageController] that supports loop (infinite scroll) mode for
/// [ExpandablePageView].
///
/// When used with [ExpandablePageView] and `loop: true`, this controller
/// allows programmatic navigation via [jumpToPage] and [animateToPage]
/// using real page indices (0 to [itemCount]-1). The virtual index
/// translation required for infinite scrolling is handled internally.
///
/// The [page] getter returns the current real page index (with fractional
/// part for smooth animations), not the internal virtual index.
///
/// Example:
/// ```dart
/// final controller = ExpandablePageController(itemCount: 5);
///
/// ExpandablePageView(
///   controller: controller,
///   loop: true,
///   children: [...],
/// );
///
/// // Navigate programmatically
/// controller.jumpToPage(3);
/// controller.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
///
/// // Read current page
/// print(controller.page); // e.g., 2.0
/// ```
class ExpandablePageController extends PageController {
  int _itemCount;

  /// Large multiplier for initial page offset in loop mode.
  /// This allows scrolling in both directions from the start.
  static const int loopMultiplier = 10000;

  /// Creates a controller for an [ExpandablePageView] with loop support.
  ///
  /// [itemCount] is the number of real pages. It must be greater than 0.
  ///
  /// [initialPage] is the real page index to start on (0 to [itemCount]-1).
  ExpandablePageController({
    required int itemCount,
    int initialPage = 0,
    super.viewportFraction,
    super.keepPage,
  })  : _itemCount = itemCount,
        super(initialPage: loopMultiplier * itemCount + initialPage);

  /// The number of real pages.
  int get itemCount => _itemCount;
  set itemCount(int value) => _itemCount = value;

  /// Converts a virtual index to a real index (0 to [itemCount]-1).
  int _toRealIndex(int virtualIndex) {
    return ((virtualIndex % _itemCount) + _itemCount) % _itemCount;
  }

  /// The current real page as a fraction (e.g., 2.35 means 35% between
  /// page 2 and page 3).
  ///
  /// Returns `null` if the controller is not attached to a scroll view.
  ///
  /// Note: At loop boundaries (e.g., swiping from the last page to the
  /// first), there may be a discontinuity in the fractional value.
  @override
  double? get page {
    final virtualPage = super.page;
    if (virtualPage == null) return null;
    return virtualPage % _itemCount;
  }

  /// The current real page index (rounded).
  ///
  /// If the controller is not yet attached, returns the initial page.
  int get realPage {
    if (!hasClients) return _toRealIndex(initialPage);
    final virtualPage = super.page?.round() ?? initialPage;
    return _toRealIndex(virtualPage);
  }

  /// Jumps to the given real page index using the shortest path.
  @override
  void jumpToPage(int page) {
    super.jumpToPage(_closestVirtualPage(page));
  }

  /// Animates to the given real page index using the shortest path.
  @override
  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) {
    return super.animateToPage(
      _closestVirtualPage(page),
      duration: duration,
      curve: curve,
    );
  }

  /// Finds the closest virtual page for the given real page index,
  /// choosing the shortest path (fewest pages to scroll).
  int _closestVirtualPage(int targetRealPage) {
    final currentVirtual =
        hasClients ? super.page?.round() ?? initialPage : initialPage;
    final currentReal = _toRealIndex(currentVirtual);

    // Forward and backward deltas
    int forwardDelta =
        (targetRealPage - currentReal) % _itemCount;
    int backwardDelta = forwardDelta - _itemCount;

    // Choose shortest path
    final delta =
        forwardDelta.abs() <= backwardDelta.abs() ? forwardDelta : backwardDelta;

    return currentVirtual + delta;
  }
}
```

- [ ] **Step 4: Export `ExpandablePageController`**

In `lib/expandable_page_view.dart`, add:

```dart
export 'src/expandable_page_controller.dart' show ExpandablePageController;
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test test/expandable_page_controller_test.dart`
Expected: All 5 tests PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/src/expandable_page_controller.dart lib/expandable_page_view.dart test/expandable_page_controller_test.dart
git commit -m "feat: add ExpandablePageController with virtual index translation"
```

---

### Task 2: Integrate `ExpandablePageController` into the widget

**Files:**
- Modify: `lib/src/expandable_page_view.dart`
- Modify: `test/expandable_page_view_test.dart`

- [ ] **Step 1: Write failing integration test — `jumpToPage` with loop**

Add to `test/expandable_page_view_test.dart`, inside the `"ExpandablePageView with loop"` group:

```dart
testWidgets('''given loop is true and ExpandablePageController is provided
then jumpToPage navigates to the correct real page''', (tester) async {
  final controller = ExpandablePageController(itemCount: 3);
  int? lastChangedPage;
  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller,
      onPageChanged: (page) => lastChangedPage = page,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  expect(tester.pageViewHeight, 100); // Starts at page 0

  controller.jumpToPage(2);
  await tester.pumpAndSettle();

  expect(lastChangedPage, 2);
  expect(tester.pageViewHeight, 300);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test test/expandable_page_view_test.dart --name "given loop is true and ExpandablePageController is provided"`
Expected: FAIL — the widget creates its own internal controller, ignoring the `ExpandablePageController`.

- [ ] **Step 3: Modify widget to detect and use `ExpandablePageController`**

In `lib/src/expandable_page_view.dart`, add this import at the top:

```dart
import 'package:expandable_page_view/src/expandable_page_controller.dart';
```

Then modify `_initializePageController()`:

```dart
void _initializePageController() {
  if (widget.loop) {
    final expandableController = widget.controller is ExpandablePageController
        ? widget.controller as ExpandablePageController
        : null;

    if (expandableController != null) {
      // User provided an ExpandablePageController — use it directly
      expandableController.itemCount = _itemCount;
      _pageController = expandableController;
      _shouldDisposePageController = false;
      _currentPage = _pageController.initialPage;
      _previousPage = _currentPage;
    } else {
      // No controller or regular PageController — create internal one
      final userInitialPage = widget.controller?.initialPage ?? 0;
      _pageController = _createLoopController(userInitialPage);
      _shouldDisposePageController = true;
      _currentPage = _loopInitialPageFor(userInitialPage);
      _previousPage = _currentPage;
    }
  } else {
    _pageController = _createStandardController(0);
    _shouldDisposePageController = widget.controller == null;
    _currentPage =
        _pageController.initialPage.clamp(0, max(0, _sizes.length - 1));
    _previousPage = max(0, _currentPage - 1);
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test test/expandable_page_view_test.dart --name "given loop is true and ExpandablePageController is provided"`
Expected: PASS.

- [ ] **Step 5: Run all existing tests to verify no regressions**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test`
Expected: All tests PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/src/expandable_page_view.dart test/expandable_page_view_test.dart
git commit -m "feat: integrate ExpandablePageController into widget loop mode"
```

---

### Task 3: Handle `didUpdateWidget` for `ExpandablePageController`

**Files:**
- Modify: `lib/src/expandable_page_view.dart`
- Modify: `test/expandable_page_view_test.dart`

- [ ] **Step 1: Write failing test — controller swap in loop mode with ExpandablePageController**

Add to `test/expandable_page_view_test.dart`, inside the `"ExpandablePageView with loop"` group:

```dart
testWidgets('''given loop is true and ExpandablePageController changes
then widget uses the new controller''', (tester) async {
  final controller1 = ExpandablePageController(itemCount: 3);
  final controller2 = ExpandablePageController(itemCount: 3, initialPage: 2);

  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller1,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  expect(tester.pageViewHeight, 100); // page 0

  // Swap to controller2 which starts at page 2
  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller2,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  expect(tester.pageViewHeight, 300); // page 2
});
```

- [ ] **Step 2: Write failing test — itemCount updates on ExpandablePageController when children change**

Add to `test/expandable_page_view_test.dart`, inside the `"ExpandablePageView with loop"` group:

```dart
testWidgets('''given loop is true with ExpandablePageController
and children count changes
then controller itemCount is updated''', (tester) async {
  final controller = ExpandablePageController(itemCount: 3);

  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  expect(controller.itemCount, 3);

  // Add a child
  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
        Container(color: Colors.yellow, height: 400),
      ],
    ),
  );

  expect(controller.itemCount, 4);
});
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test test/expandable_page_view_test.dart --name "ExpandablePageController changes|controller itemCount is updated"`
Expected: FAIL.

- [ ] **Step 4: Modify `didUpdateWidget` to handle `ExpandablePageController`**

In `lib/src/expandable_page_view.dart`, modify `didUpdateWidget`:

```dart
@override
void didUpdateWidget(covariant ExpandablePageView oldWidget) {
  super.didUpdateWidget(oldWidget);

  // Handle loop property change
  if (oldWidget.loop != widget.loop) {
    _handleLoopChange(oldWidget);
    if (_shouldReinitializeHeights(oldWidget)) {
      _reinitializeSizes();
    }
    return;
  }

  if (oldWidget.controller != widget.controller) {
    if (widget.loop) {
      _handleLoopControllerChange();
    } else {
      _pageController.removeListener(_updatePage);
      if (_shouldDisposePageController) {
        _pageController.dispose();
      }
      _pageController = widget.controller ?? PageController();
      _pageController.addListener(_updatePage);
      _shouldDisposePageController = widget.controller == null;
    }
  }

  // Update itemCount on ExpandablePageController when children change
  if (widget.loop && _pageController is ExpandablePageController) {
    (_pageController as ExpandablePageController).itemCount = _itemCount;
  }

  if (_shouldReinitializeHeights(oldWidget)) {
    _reinitializeSizes();
  }
}
```

Add the `_handleLoopControllerChange` method:

```dart
/// Handles controller change while in loop mode.
void _handleLoopControllerChange() {
  _pageController.removeListener(_updatePage);
  if (_shouldDisposePageController) {
    _pageController.dispose();
  }

  final expandableController = widget.controller is ExpandablePageController
      ? widget.controller as ExpandablePageController
      : null;

  if (expandableController != null) {
    expandableController.itemCount = _itemCount;
    _pageController = expandableController;
    _shouldDisposePageController = false;
    _currentPage = _pageController.initialPage;
    _previousPage = _currentPage;
  } else {
    final userInitialPage = widget.controller?.initialPage ?? 0;
    _pageController = _createLoopController(userInitialPage);
    _shouldDisposePageController = true;
    _currentPage = _loopInitialPageFor(userInitialPage);
    _previousPage = _currentPage;
  }

  _pageController.addListener(_updatePage);
}
```

- [ ] **Step 5: Run the new tests to verify they pass**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test test/expandable_page_view_test.dart --name "ExpandablePageController changes|controller itemCount is updated"`
Expected: PASS.

- [ ] **Step 6: Run all tests to verify no regressions**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test`
Expected: All tests PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/src/expandable_page_view.dart test/expandable_page_view_test.dart
git commit -m "feat: handle ExpandablePageController swap and itemCount sync"
```

---

### Task 4: Handle `_handleLoopChange` with `ExpandablePageController`

**Files:**
- Modify: `lib/src/expandable_page_view.dart`
- Modify: `test/expandable_page_view_test.dart`

- [ ] **Step 1: Write failing test — loop toggles with ExpandablePageController**

Add to `test/expandable_page_view_test.dart`, inside the `"ExpandablePageView with loop"` group:

```dart
testWidgets('''given ExpandablePageController is provided
and loop changes from true to false
then widget creates internal standard controller at current page''',
    (tester) async {
  final controller = ExpandablePageController(itemCount: 3);
  int? lastChangedPage;

  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller,
      onPageChanged: (page) => lastChangedPage = page,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  controller.jumpToPage(2);
  await tester.pumpAndSettle();
  expect(lastChangedPage, 2);
  expect(tester.pageViewHeight, 300);

  // Toggle loop off — widget should create an internal standard controller
  // at the current real page (2), NOT use the ExpandablePageController
  // (whose initialPage is a virtual index)
  await tester.pumpApp(
    ExpandablePageView(
      loop: false,
      controller: controller,
      onPageChanged: (page) => lastChangedPage = page,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  // Should remain on page 2 after loop toggle
  expect(tester.pageViewHeight, 300);
});

testWidgets('''given ExpandablePageController is provided
and loop changes from false to true
then widget re-uses the ExpandablePageController''', (tester) async {
  final controller = ExpandablePageController(itemCount: 3);
  int? lastChangedPage;

  // Start with loop off — widget creates internal standard controller
  await tester.pumpApp(
    ExpandablePageView(
      loop: false,
      controller: controller,
      onPageChanged: (page) => lastChangedPage = page,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  // Toggle loop on — widget should use the ExpandablePageController
  // Page resets to controller's initialPage (0)
  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller,
      onPageChanged: (page) => lastChangedPage = page,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  expect(tester.pageViewHeight, 100); // page 0 (controller's initialPage)

  // Programmatic navigation should work
  controller.jumpToPage(1);
  await tester.pumpAndSettle();
  expect(lastChangedPage, 1);
  expect(tester.pageViewHeight, 200);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test test/expandable_page_view_test.dart --name "ExpandablePageController is provided.*(loop changes|re-uses)"`
Expected: FAIL.

- [ ] **Step 3: Modify `_handleLoopChange` to support `ExpandablePageController`**

In `lib/src/expandable_page_view.dart`, update `_handleLoopChange`:

```dart
/// Handles the transition when loop property changes.
void _handleLoopChange(ExpandablePageView oldWidget) {
  final currentRealPage = _realIndex(_currentPage);
  _pageController.removeListener(_updatePage);
  if (_shouldDisposePageController) {
    _pageController.dispose();
  }

  if (widget.loop) {
    final expandableController = widget.controller is ExpandablePageController
        ? widget.controller as ExpandablePageController
        : null;

    if (expandableController != null) {
      // Re-use the user's ExpandablePageController.
      // Page resets to controller's initialPage — acceptable for a loop toggle.
      expandableController.itemCount = _itemCount;
      _pageController = expandableController;
      _shouldDisposePageController = false;
      _currentPage = _pageController.initialPage;
      _previousPage = _currentPage;
    } else {
      _pageController = _createLoopController(currentRealPage);
      _shouldDisposePageController = true;
      _currentPage = _loopInitialPageFor(currentRealPage);
      _previousPage = _currentPage;
    }
  } else {
    // When toggling to non-loop mode, always create an internal standard
    // controller. Don't use ExpandablePageController here because its
    // initialPage is a virtual index that doesn't work in non-loop mode.
    _pageController = PageController(initialPage: currentRealPage);
    _shouldDisposePageController = true;
    _currentPage = currentRealPage.clamp(0, max(0, _sizes.length - 1));
    _previousPage = _currentPage;
  }

  _pageController.addListener(_updatePage);
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test test/expandable_page_view_test.dart --name "ExpandablePageController is provided.*(loop changes|re-uses)"`
Expected: PASS.

- [ ] **Step 5: Run all tests to verify no regressions**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test`
Expected: All tests PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/src/expandable_page_view.dart test/expandable_page_view_test.dart
git commit -m "feat: support ExpandablePageController across loop toggles"
```

---

### Task 5: Test `animateToPage` and shortest-path behavior

**Files:**
- Modify: `test/expandable_page_view_test.dart`

- [ ] **Step 1: Write test — `animateToPage` navigates correctly**

Add to `test/expandable_page_view_test.dart`, inside the `"ExpandablePageView with loop"` group:

```dart
testWidgets('''given loop is true and ExpandablePageController is provided
then animateToPage navigates to the correct real page''', (tester) async {
  final controller = ExpandablePageController(itemCount: 3);
  int? lastChangedPage;
  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller,
      onPageChanged: (page) => lastChangedPage = page,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  expect(tester.pageViewHeight, 100); // page 0

  controller.animateToPage(
    2,
    duration: const Duration(milliseconds: 300),
    curve: Curves.ease,
  );
  await tester.pumpAndSettle();

  expect(lastChangedPage, 2);
  expect(tester.pageViewHeight, 300);
});
```

- [ ] **Step 2: Write test — shortest path wraps backward**

```dart
testWidgets('''given loop is true and ExpandablePageController is provided
and current page is 0
then animateToPage to last page takes shortest path (backward)''',
    (tester) async {
  final controller = ExpandablePageController(itemCount: 5);
  int? lastChangedPage;
  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller,
      onPageChanged: (page) => lastChangedPage = page,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
        Container(color: Colors.yellow, height: 400),
        Container(color: Colors.orange, height: 500),
      ],
    ),
  );

  // On page 0, animating to page 4 should go backward (1 step)
  // not forward (4 steps)
  controller.animateToPage(
    4,
    duration: const Duration(milliseconds: 300),
    curve: Curves.ease,
  );
  await tester.pumpAndSettle();

  expect(lastChangedPage, 4);
  expect(tester.pageViewHeight, 500);
});
```

- [ ] **Step 3: Write test — `page` getter returns real fractional value**

```dart
testWidgets('''given loop is true and ExpandablePageController is provided
then page getter returns real page index''', (tester) async {
  final controller = ExpandablePageController(itemCount: 3, initialPage: 1);
  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  // page should report real page, not virtual
  expect(controller.page, closeTo(1.0, 0.01));
  expect(controller.realPage, 1);

  controller.jumpToPage(2);
  await tester.pumpAndSettle();

  expect(controller.page, closeTo(2.0, 0.01));
  expect(controller.realPage, 2);
});
```

- [ ] **Step 4: Write test — loop wrapping with `jumpToPage`**

```dart
testWidgets('''given loop is true and ExpandablePageController is provided
and on last page
then jumpToPage(0) wraps correctly''', (tester) async {
  final controller = ExpandablePageController(itemCount: 3, initialPage: 2);
  int? lastChangedPage;
  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller,
      onPageChanged: (page) => lastChangedPage = page,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  expect(tester.pageViewHeight, 300); // page 2

  controller.jumpToPage(0);
  await tester.pumpAndSettle();

  expect(lastChangedPage, 0);
  expect(tester.pageViewHeight, 100);
});
```

- [ ] **Step 5: Run all new tests**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test test/expandable_page_view_test.dart --name "ExpandablePageController is provided"`
Expected: All PASS.

- [ ] **Step 6: Run full test suite**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test`
Expected: All tests PASS.

- [ ] **Step 7: Commit**

```bash
git add test/expandable_page_view_test.dart
git commit -m "test: add integration tests for ExpandablePageController with loop mode"
```

---

### Task 6: Test with `builder` constructor and edge cases

**Files:**
- Modify: `test/expandable_page_view_test.dart`

- [ ] **Step 1: Write test — ExpandablePageController with builder constructor**

```dart
testWidgets('''given loop is true and ExpandablePageController is provided
with builder constructor
then jumpToPage works correctly''', (tester) async {
  final controller = ExpandablePageController(itemCount: 3);
  final heights = [100.0, 200.0, 300.0];
  final colors = [Colors.red, Colors.blue, Colors.green];
  int? lastChangedPage;

  await tester.pumpApp(
    ExpandablePageView.builder(
      loop: true,
      controller: controller,
      itemCount: 3,
      onPageChanged: (page) => lastChangedPage = page,
      itemBuilder: (context, index) => Container(
        color: colors[index],
        height: heights[index],
      ),
    ),
  );

  expect(tester.pageViewHeight, 100); // page 0

  controller.jumpToPage(2);
  await tester.pumpAndSettle();

  expect(lastChangedPage, 2);
  expect(tester.pageViewHeight, 300);
});
```

- [ ] **Step 2: Write test — ExpandablePageController with viewportFraction < 1.0**

```dart
testWidgets('''given loop is true and ExpandablePageController
with viewportFraction < 1.0
then jumpToPage works correctly''', (tester) async {
  final controller = ExpandablePageController(
    itemCount: 3,
    viewportFraction: 0.8,
  );
  int? lastChangedPage;

  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller,
      onPageChanged: (page) => lastChangedPage = page,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  controller.jumpToPage(1);
  await tester.pumpAndSettle();

  expect(lastChangedPage, 1);
});
```

- [ ] **Step 3: Write test — swiping still works with ExpandablePageController**

```dart
testWidgets('''given loop is true and ExpandablePageController is provided
then manual swiping still works and loops''', (tester) async {
  final controller = ExpandablePageController(itemCount: 3);
  int? lastChangedPage;
  await tester.pumpApp(
    ExpandablePageView(
      loop: true,
      controller: controller,
      onPageChanged: (page) => lastChangedPage = page,
      children: [
        Container(color: Colors.red, height: 100),
        Container(color: Colors.blue, height: 200),
        Container(color: Colors.green, height: 300),
      ],
    ),
  );

  final pageView = find.byType(ExpandablePageView);

  // Swipe forward through all pages and loop
  await tester.drag(pageView, const Offset(-500, 0));
  await tester.pumpAndSettle();
  expect(lastChangedPage, 1);

  await tester.drag(pageView, const Offset(-500, 0));
  await tester.pumpAndSettle();
  expect(lastChangedPage, 2);

  await tester.drag(pageView, const Offset(-500, 0));
  await tester.pumpAndSettle();
  expect(lastChangedPage, 0); // Looped!

  expect(controller.realPage, 0);
});
```

- [ ] **Step 4: Run all tests**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test`
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add test/expandable_page_view_test.dart
git commit -m "test: add builder, viewportFraction, and swipe tests for ExpandablePageController"
```

---

### Task 7: Update `loop` doc comment

**Files:**
- Modify: `lib/src/expandable_page_view.dart`

- [ ] **Step 1: Update the `loop` property doc comment**

Replace the existing `loop` doc comment in `lib/src/expandable_page_view.dart`:

```dart
/// Whether the page view should loop infinitely.
///
/// When set to true, the page view will cycle through pages infinitely
/// in both directions. Swiping past the last page will show the first page,
/// and swiping before the first page will show the last page.
///
/// The [onPageChanged] callback will receive the actual page index (0 to itemCount-1),
/// not the virtual index used internally for infinite scrolling.
///
/// To programmatically control the page view in loop mode, use
/// [ExpandablePageController]:
///
/// ```dart
/// final controller = ExpandablePageController(itemCount: 5);
///
/// ExpandablePageView(
///   controller: controller,
///   loop: true,
///   children: [...],
/// );
///
/// // Navigate programmatically
/// controller.jumpToPage(3);
/// controller.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.ease);
/// ```
///
/// If a regular [PageController] is provided instead, it will only be used
/// to read [PageController.initialPage], [PageController.viewportFraction],
/// and [PageController.keepPage]. The regular controller will not be attached
/// to the PageView.
///
/// Defaults to false.
final bool loop;
```

- [ ] **Step 2: Run all tests to verify nothing broke**

Run: `cd /Users/jakubdanielczyk/Dev/expandable_page_view && flutter test`
Expected: All tests PASS.

- [ ] **Step 3: Commit**

```bash
git add lib/src/expandable_page_view.dart
git commit -m "docs: update loop property documentation with ExpandablePageController usage"
```
