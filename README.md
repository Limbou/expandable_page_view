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

Check out [example project](https://github.com/Limbou/expandable_page_view/tree/main/example) to play with ExpandablePageView.