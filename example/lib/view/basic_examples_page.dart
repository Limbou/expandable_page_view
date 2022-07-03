import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';

class BasicExamplesPage extends StatelessWidget {
  const BasicExamplesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ExpandablePageView(
            children: [
              ExamplePage(Colors.blue, "1", height: 100),
              ExamplePage(Colors.green, "2", height: 200),
              ExamplePage(Colors.red, "3", height: 300),
            ],
          ),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                ExpandablePageView(
                  children: [
                    ExamplePage(Colors.blue, "1", width: 50),
                    ExamplePage(Colors.green, "2", width: 100),
                    ExamplePage(Colors.red, "3", width: 300),
                  ],
                  scrollDirection: Axis.vertical,
                  alignment: Alignment.centerLeft,
                ),
                Flexible(child: Text("AFTER PAGE VIEW WIDGET")),
              ],
            ),
          ),
          ExpandablePageView.builder(
            animateFirstPage: true,
            estimatedPageSize: 100,
            itemCount: 3,
            itemBuilder: (context, index) {
              return ExamplePage(
                Colors.blue,
                index.toString(),
                height: (index + 1) * 100.0,
              );
            },
          ),
          const SizedBox(height: 20),
          Text("UNDER PAGE VIEW WIDGET"),
        ],
      ),
    );
  }
}

class ExamplePage extends StatelessWidget {
  final Color color;
  final String text;
  final double? height;
  final double? width;

  const ExamplePage(
    this.color,
    this.text, {
    this.height = 0,
    this.width = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: color,
      child: Center(
        child: Text(text),
      ),
    );
  }
}
