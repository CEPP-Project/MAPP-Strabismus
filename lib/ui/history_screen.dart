import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:strabismus/ui/graph_screen.dart';

import 'mainmenu_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  List<Map<String, String>> historyItems = [
    {"info1": "History item 1", "info2": "Detail 1", "timestamp": "2024-03-23 09:00:00"},
    {"info1": "History item 2", "info2": "Detail 2", "timestamp": "2024-03-22 14:30:00"},
    {"info1": "History item 3", "info2": "Detail 3", "timestamp": "2024-03-21 18:45:00"},
    // Add more history items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ListView.builder(
        itemCount: historyItems.length,
        itemBuilder: (BuildContext context, int index) {
          // Splitting timestamp into date and time
          DateTime dateTime = DateTime.parse(historyItems[index]['timestamp'] ?? '');
          String date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
          String time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

          return ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Date on the left top
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                // Time on the left bottom
                Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                // Item1 on the right top
                Text(historyItems[index]['info1'] ?? ''),
                // Item2 on the right bottom
                Text(historyItems[index]['info2'] ?? ''),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                );
              },
              child: const Text('Main Menu'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GraphScreen()),
                );
              },
              child: const Text('Graph'),
            ),
          ],
        ),
      ),
    );
  }
}
