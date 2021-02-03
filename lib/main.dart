import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'export.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    Widget app = MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );

    app = Provider(
      create: (_) => Repository(
        baseUrl: 'https://lucy-test1.s3.amazonaws.com/',
      ),
      child: app,
    );

    return app;
  }
}
