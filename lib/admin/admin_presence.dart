import 'package:flutter/material.dart';


class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.sync)
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(0.0),
        child: ListView.builder(
            itemBuilder: (context, _) => Placeholder(),
        ),
      ),
    );
  }
}
