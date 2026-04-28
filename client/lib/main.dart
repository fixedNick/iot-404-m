import 'package:flutter/material.dart';
import 'presentation/screens/weather_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'AppleSanFrancisco'),
      home: const WeatherScreen(),
    );
  }
}
