import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'homepage.dart';

void main() {

  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.black, // navigation bar color
  //  statusBarColor: Colors.transparent, // status bar color
  // ));
  runApp(Peeku());
  SystemChrome.setEnabledSystemUIOverlays([]);
  // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
}

class Peeku extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
//        primarySwatch: Colors.yellow,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        accentColor: Colors.yellow,),
      home: HomePage(),
    );
  }
}
