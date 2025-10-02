import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StatisticsScreen();
}

class _StatisticsScreen extends State<StatisticsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              "Statistics Screen"
            )
          ],
        ),
      ),
    );
  }
}