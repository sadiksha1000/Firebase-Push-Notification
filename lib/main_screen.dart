import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class MainScreen extends StatelessWidget {
  final String? args;
  const MainScreen({
    Key? key,
    this.args,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Text(
        'Presenting your notification $args',
        style: TextStyle(fontSize: 25),
      )),
    );
  }
}
