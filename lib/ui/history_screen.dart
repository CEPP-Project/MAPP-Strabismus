import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _fetchData().then((result){
      historyItems=result;
    });
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
    {
      "rate": "80",
      "result": "true",
      "timestamp": "2024-03-23 09:00:00"
    },
    {
      "rate": "70",
      "result": "false",
      "timestamp": "2024-03-22 14:30:00"
    },
    {
      "rate": "70",
      "result": "true",
      "timestamp": "2024-03-21 18:45:00"
    },
    // Add more history items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('History'),
      // ),
      body: ListView.builder(
        itemCount: historyItems.length,
        itemBuilder: (BuildContext context, int index) {
          // Splitting timestamp into date and time
          DateTime dateTime = DateTime.parse(historyItems[index]['timestamp'] ?? '');
          String date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
          String time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

          // Formatting info2
          Color info2Color = historyItems[index]['result'] == "true" ? Colors.green : Colors.red;

          return Column(
            children: [
              ListTile(
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
                    Text('Strabismus Rate: ${historyItems[index]['rate']!}%' ,style: const TextStyle(fontSize: 16.0),),
                    // Item2 on the right bottom
                    Text(
                      historyItems[index]['result'] ?? '',
                      style: TextStyle(fontSize: 16.0,color: info2Color),
                    ),
                  ],
                ),
              ),
              const Divider(), // Add a line between items
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MainMenuScreen()),
                );
              },
              child: const Text('Main Menu',
                  style: TextStyle(fontSize: 24, color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GraphScreen()),
                );
              },
              child: const Text('Graph',
                  style: TextStyle(fontSize: 24, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<List<Map<String, String>>> _fetchData() async{
    String token= '';
    _getToken().then((result){
      token = result;
    });
    List<Map<String,String>> result = [
      {
        "rate": "80",
        "result": "true",
        "timestamp": "2024-03-23 09:00:00"
      }
    ];
    return result;
  }
}
