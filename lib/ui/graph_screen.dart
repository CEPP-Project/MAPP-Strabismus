import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strabismus/ui/history_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});
  @override
  State<GraphScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<GraphScreen> {
  List<DateTime> timestamps = [
     DateTime(2023, 3, 25, 0, 0), // default for loading
    // DateTime(2024, 3, 26, 1, 0),
    // DateTime(2024, 3, 27, 2, 0),
    // DateTime(2024, 3, 29, 3, 0),
    // DateTime(2024, 4, 1, 3, 0),
    // Add more timestamps as needed
  ];

  List<double> values = [
     30, // Example values corresponding to timestamps
    // 50,
    // 80,
    // 60,
    // 50,
    // Add more values as needed
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _fetchData().then((result){
      setState(() {
        timestamps=result[0] as List<DateTime>;
        values=result[1] as List<double>;
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
    if (timestamps[0] == DateTime(2023, 3, 25, 0, 0)) {
      return const Scaffold(
        // appBar: AppBar(
        //   title: const Text('Loading Screen'),
        // ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    else {
      return Scaffold(
        // appBar: AppBar(
        //   title: const Text('History'),
        // ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              minX: (timestamps.first.millisecondsSinceEpoch.toDouble() /
                  86400000.0).floorToDouble(),
              maxX: (timestamps.last.millisecondsSinceEpoch.toDouble() /
                  86400000.0).floorToDouble(),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    timestamps.length,
                        (index) =>
                        FlSpot(
                          (timestamps[index].millisecondsSinceEpoch.toDouble() /
                              86400000).floorToDouble(),
                          values[index],
                        ),
                  ),
                  isCurved: false,
                  color: Colors.blue,
                  barWidth: 4,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: bottomTitleWidgets,
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: leftTitleWidgets,
                    reservedSize: 42,
                    interval: 1,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black, width: 1),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.grey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryScreen()),
                  );
                },
                child: const Text('Go back to History',
                    style: TextStyle(fontSize: 24, color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    text = const Text('', style: style);
    for(var i in timestamps){
      if (value == (i.millisecondsSinceEpoch.toDouble()/86400000.0).floorToDouble()){
        text = Text('${i.day.toInt()}/${i.month.toInt()}/${i.year.toInt()}', style: style);
        break;
      }
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<List<List>> _fetchData() async{
    String token= '';
    await _getToken().then((result){
      token = result;
    });
    List<dynamic> jsonList = [];
    try{
      final response = await http.get(
        Uri.parse('https://mapp-api.redaxn.com/user/graph'),
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
    List<DateTime>  timestamps=[];
    List<double>  rates=[];
    for(var jsonMap in jsonList) {
      // Extract timestamp
      String timestampString = jsonMap['timestamp'].substring(0, 19).replaceAll('T', ' ');
      DateTime timestamp = DateTime.parse(timestampString);
      timestamps.add(timestamp);

      // Extract rate
     // Map<String, dynamic> rateMap = jsonMap['result'][1];
      double rateValue = jsonMap['result'][1][1] * 100; // Convert to percentage
      rates.add(rateValue);
    }
    return [timestamps,rates];
  }
}
