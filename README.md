# expandable_page_view

A PageView widget adjusting its height to currently displayed page. It accepts the same parameters as classic PageView.


|  Horizontal | Vertical |
|---|---|
|<img height="800" src="https://github.com/Limbou/expandable_page_view/blob/main/assets/appVideo.gif?raw=true">| <img  height="800" src="https://github.com/Limbou/expandable_page_view/blob/main/assets/appVideo2.gif?raw=true">|

## Getting Started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  expandable_page_view: ^1.0.17
```

Import it:

```dart
import 'package:expandable_page_view/expandable_page_view.dart';
```

## Usage Examples

### Fixed Expandable Page View

In order to create a fixed page view just pass a list of widgets to `children` parameter:

```dart
ExpandablePageView(
  children: [
     ExamplePage(Colors.blue, "1", 100),
     ExamplePage(Colors.green, "2", 200),
     ExamplePage(Colors.red, "3", 300),
  ],
),
```

### Dynamically built Expandable Page View

If You have multiple pages to display, and You want to build them dynamically while scrolling, use `.builder`  constructor and pass `itemCount` and `itemBuilder` parameters:

```dart
ExpandablePageView.builder(
  itemCount: 3,
  itemBuilder: (context, index) {
    return ExamplePage(Colors.blue, index.toString(), (index + 1) * 100.0);
  },
),
```

### Loop Mode

To create an infinitely scrolling page view, set `loop: true`:

```dart
ExpandablePageView(
  loop: true,
  children: [
    ExamplePage(Colors.blue, "1", 100),
    ExamplePage(Colors.green, "2", 200),
    ExamplePage(Colors.red, "3", 300),
  ],
),
```

### Programmatic Control in Loop Mode

To programmatically navigate pages in loop mode (e.g., for auto-play carousels or custom indicators), use `ExpandablePageController`:

```dart
final controller = ExpandablePageController(itemCount: 3);

ExpandablePageView(
  controller: controller,
  loop: true,
  children: [
    ExamplePage(Colors.blue, "1", 100),
    ExamplePage(Colors.green, "2", 200),
    ExamplePage(Colors.red, "3", 300),
  ],
),

// Navigate programmatically
controller.jumpToPage(2);
controller.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.ease);

// Read current page
print(controller.page);     // e.g., 1.5 (fractional during scroll)
print(controller.realPage); // e.g., 1 (rounded)
```

> **Note:** `ExpandablePageController` uses shortest-path navigation — animating from page 0 to the last page will scroll backward (1 step) rather than forward through all pages.

Check out [example project](https://github.com/Limbou/expandable_page_view/tree/main/example) to play with ExpandablePageView.