## 1.0.7

* Added `alignment` property
* Fixed RangeError when children amount decreased

## 1.0.6

* Fixed wrong index displayed if initial index is different from 0
* [Breaking Change] - Added `.builder` constructor, removed `itemBuilder` and `itemCount` parameters from original constructor.
* Improved documentation on all fields.
* Added parameters names in `itemBuilder`  
* Updated README.

## 1.0.5

* Fixed `IndexOutOfBounds` error if children list's length or itemCount was changed to different value from stateful widget.

## 1.0.4

* Added null safety.

## 1.0.3

* Updated README.

## 1.0.2

* Added `animateFirstPage` flag which decided whether `ExpandablePageView` should animate when building the initial page.
* Added `estimatedPageSize` field which helps reduce the problem of "Shrink and expand" for more expensive pages.
* Removed disposing of PageController if it was passed by the parent.

## 1.0.1

* Added missing key for PageView
* Added support for dynamically size changing widgets

## 1.0.0

* Added `ExpandablePageView`.
