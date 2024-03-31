import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strabismus/ui/graph_screen.dart';
import 'package:http/http.dart' as http;
import 'mainmenu_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, String>> historyItems = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _fetchData().then((result){
      setState(() {
        historyItems=result;
      });
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

  @override
  Widget build(BuildContext context) {
    if(historyItems==[]){
      return const Scaffold(
        // appBar: AppBar(
        //   title: const Text('Loading Screen'),
        // ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
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
          Color info2Color = historyItems[index]['result'] == "true" ? Colors.red : Colors.green;

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
                    Text('Strabismus Rate: ${historyItems[index]['rate']!}' ,style: const TextStyle(fontSize: 16.0),),
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
    await _getToken().then((result){
      token = result;
    });

    List<Map<String,String>> result = [];
    List<dynamic> jsonList = [];

    try{
      final response = await http.get(
          Uri.parse('https://mapp-api.redaxn.com/user/history'),
          headers: {
            'Content-Type':'application/json',
            'Authorization':'Bearer $token'
          },
      );
      //print(response.body);
      jsonList = await jsonDecode(response.body);
    }catch(e) {
      // Handle other errors
      // print('Error : $e');
    }
    for(var jsonMap in jsonList) {
      //print(jsonMap);
      bool res = jsonMap['result'][0];
      //Map<double, double> rateMap = jsonMap['result'][1];
      double rateValue = jsonMap['result'][1][1] * 100;
      String rate = '${rateValue.toStringAsFixed(0)}%';
      String timestamp = jsonMap['timestamp'].substring(0,19).replaceAll('T',' ');

      result.add({
        'rate': rate,
        'result': res.toString(),
        'timestamp': timestamp,
      });
    }
    return result;
  }
}
