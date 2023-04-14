import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _latestMeasurement = 0.0;
  double _averageMeasurement = 0.0;

  @override
  void initState() {
    super.initState();
    _getLatestMeasurement();
    _getAverageMeasurement();
  }

  Future<double> getLatestMeasurement() async {
    final response = await http.get(Uri.parse('https://your-backend-api-url.com/latest-measurement'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final latestMeasurement = jsonResponse['latest_measurement'];
      return latestMeasurement;
    } else {
      throw Exception('Failed to load latest measurement data');
    }
  }

  Future<double> getAverageMeasurement() async {
    final response = await http.get(Uri.parse('https://your-backend-api-url.com/average-measurement'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final averageMeasurement = jsonResponse['average_measurement'];
      return averageMeasurement;
    } else {
      throw Exception('Failed to load average measurement data');
    }
  }

  void _getLatestMeasurement() async {
    try {
      final latestMeasurement = await getLatestMeasurement();
      setState(() {
        _latestMeasurement = latestMeasurement;
      });
    } catch (e) {
      print('Error getting latest measurement: $e');
    }
  }

  void _getAverageMeasurement() async {
    try {
      final averageMeasurement = await getAverageMeasurement();
      setState(() {
        _averageMeasurement = averageMeasurement;
      });
    } catch (e) {
      print('Error getting average measurement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 200,
            child: SfCartesianChart(
              // Add your chart data and configuration here
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(width: 1),
            ),
            child: Text('Latest measurement: $_latestMeasurement'),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(width: 1),
            ),
            child: Text('Average measurement: $_averageMeasurement'),
          ),
        ],
      ),
    );
  }
}
