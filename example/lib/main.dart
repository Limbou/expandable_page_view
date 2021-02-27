import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ExpandablePageView(
                children: [
                  ExamplePage(Colors.blue, "1", 100),
                  ExamplePage(Colors.green, "2", 200),
                  ExamplePage(Colors.red, "3", 300),
                ],
              ),
              ExpandablePageView(
                animateFirstPage: true,
                estimatedPageSize: 100,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ExamplePage(Colors.blue, index.toString(), (index + 1) * 100.0);
                },
              ),
              const SizedBox(height: 20),
              Text("UNDER PAGE VIEW WIDGET"),
            ],
          ),
        ));
  }
}

class ExamplePage extends StatelessWidget {
  final Color color;
  final String text;
  final double height;

  const ExamplePage(this.color, this.text, this.height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: color,
      child: Center(
        child: Text(text),
      ),
    );
  }
}
