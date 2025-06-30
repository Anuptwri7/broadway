import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DicePage extends StatefulWidget {
  @override
  _DicePageState createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  int _diceNumber = 1;
  bool isRolling = false;

  Timer? _dotsTimer;
  int _dotsCount = 1;

  void _rollDice() async {
    setState(() {
      isRolling = true;
      _dotsCount = 1;
    });

    _dotsTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotsCount = _dotsCount % 3 + 1;
      });
    });

    await Future.delayed(Duration(seconds: 3));

    _dotsTimer?.cancel();

    setState(() {
      _diceNumber = Random().nextInt(6) + 1;
      isRolling = false;
    });
  }

  @override
  void dispose() {
    _dotsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String rollingText = "Rolling" + "." * _dotsCount;

    return Scaffold(
      appBar: AppBar(title: Text('Dice Roller')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You rolled:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            if(isRolling)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_dotsCount, (index) => Icon(Icons.downloading)),
            ),

            Text(
              isRolling ? rollingText : '$_diceNumber',
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: isRolling ? null : _rollDice,
              child: Text('Roll Dice'),
            ),
          ],
        ),
      ),
    );
  }
}
