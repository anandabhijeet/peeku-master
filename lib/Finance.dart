import 'package:flutter/material.dart';

class Finance extends StatefulWidget {
  //const Finance({Key? key}) : super(key: key);

  @override
  _FinanceState createState() => _FinanceState();
}

class _FinanceState extends State<Finance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(Icons.home, color: Colors. yellow,),
      ),
    );
  }
}
