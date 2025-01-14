import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:linguana/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Linguana',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: FlutterSplashScreen.fadeIn(
          useImmersiveMode: true,
          backgroundColor: Colors.green.shade300,
          childWidget: SizedBox(
            height: 200,
            width: 200,
            child: Image.asset("assets/images/logo.png"),
          ),
          nextScreen: const HomePage(),
        ));
  }
}
