import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class RobotARScreen extends StatefulWidget {
  @override
  _RobotARScreenState createState() => _RobotARScreenState();
}

class _RobotARScreenState extends State<RobotARScreen> {
  late ARKitController arkitController;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Robot AR View')),
      body: ARKitSceneView(
        onARKitViewCreated: onARKitViewCreated,
      ),
    );
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;


    final node = ARKitReferenceNode(
      url: 'assets/Yeti.usdz',
      position: vector.Vector3(0, 0, -0.5),
      scale: vector.Vector3.all(0.1),
    );

    arkitController.add(node);
  }
}
