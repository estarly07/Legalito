import 'package:flutter/material.dart';


class SimulatorScreen extends StatelessWidget {
  const SimulatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulator Screen'),
      ),
      body: const Center(
        child: Text('Simulator Screen'),
      ),
    );
  }
}