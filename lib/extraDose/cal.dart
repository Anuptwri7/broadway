import 'dart:developer';

import 'package:flutter/material.dart';

class MissingIdFinder extends StatefulWidget {
  @override
  _MissingIdFinderState createState() => _MissingIdFinderState();
}

class _MissingIdFinderState extends State<MissingIdFinder> {
  final TextEditingController _controller = TextEditingController();
  int? _result;

  int findSmallestMissingPositive(List<int> userIds) {

    List<int> positiveIds = [];
    for (int id in userIds) {
      if (id > 0) {
        positiveIds.add(id);
      }
    }



    int i = 1;
    while (true) {
      bool found = false;

      for (int id in positiveIds) {
        if (id == i) {
          found = true;
          break;
        }
      }

      if (!found) {
        return i;
      }

      i++;
    }
  }

  void _calculateMissingId() {

    String input = _controller.text;
    List<String> parts = input.split(',');

    List<int> userIds = [];
    for (String part in parts) {
      int? value = int.tryParse(part.trim());
      if (value != null) {
        userIds.add(value);
      }
    }

    int result = findSmallestMissingPositive(userIds);
    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Missing ID Finder")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter ID ",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculateMissingId,
              child: Text("Find Missing ID"),
            ),

            SizedBox(height: 20),

            if (_result != null)
              Text(
                "Smallest missing positive ID: $_result",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
