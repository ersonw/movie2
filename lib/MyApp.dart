import 'package:flutter/material.dart';
import 'package:movie2/BottomAppBarState.dart';
import 'package:movie2/SplashPage.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      theme: ThemeData(
        primaryColorDark: Colors.white,

        // backgroundColor: Colors.black,
        brightness: Brightness.dark,
      ),
      // home: SplashPage(),
      home: BottomAppBarState(),
    );
  }
}
