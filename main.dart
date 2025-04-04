import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

void main() => runApp(SpacemanPredictorApp());

class SpacemanPredictorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spaceman Predictor',
      theme: ThemeData.dark(),
      home: PredictorHomePage(),
    );
  }
}

class PredictorHomePage extends StatefulWidget {
  @override
  _PredictorHomePageState createState() => _PredictorHomePageState();
}

class _PredictorHomePageState extends State<PredictorHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<double> _multipliers = [];

  void _addMultiplier() {
    final text = _controller.text;
    final value = double.tryParse(text);
    if (value != null) {
      setState(() {
        _multipliers.add(value);
        _controller.clear();
      });
    }
  }

  String _analyzePattern() {
    if (_multipliers.length < 3) return "Belum cukup data untuk analisis.";
    final recent = _multipliers.sublist(_multipliers.length - 3);
    final lowCount = recent.where((m) => m < 2.0).length;
    if (lowCount == 3) {
      return "3x berturut-turut rendah, mungkin akan tinggi.";
    } else if (recent.every((m) => m > 3.0)) {
      return "Tren tinggi, hati-hati kemungkinan crash rendah.";
    }
    return "Pola belum jelas.";
  }

  double? _predictNext() {
    if (_multipliers.length < 2) return null;
    int n = _multipliers.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += _multipliers[i];
      sumXY += i * _multipliers[i];
      sumX2 += i * i;
    }

    double denominator = n * sumX2 - sumX * sumX;
    if (denominator == 0) return null;

    double m = (n * sumXY - sumX * sumY) / denominator;
    double b = (sumY - m * sumX) / n;

    return m * n + b;
  }

  List<FlSpot> _generateSpots() {
    return List.generate(_multipliers.length,
        (index) => FlSpot(index.toDouble(), _multipliers[index]));
  }

  @override
  Widget build(BuildContext context) {
    final prediction = _predictNext();

    return Scaffold(
      appBar: AppBar(title: Text('Prediksi Spaceman')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Input multiplier (misal: 1.5)',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addMultiplier,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateSpots(),
                      isCurved: true,
                      colors: [Colors.cyan],
                      barWidth: 2,
                      belowBarData: BarAreaData(show: false),
                    )
                  ],
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              _analyzePattern(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (prediction != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Prediksi multiplier berikutnya: ${prediction.toStringAsFixed(2)}x',
                  style: TextStyle(fontSize: 16, color: Colors.amberAccent),
                ),
              ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _multipliers.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Ronde ${index + 1}: ${_multipliers[index]}x'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}