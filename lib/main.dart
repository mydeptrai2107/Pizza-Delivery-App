import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:pizza_delivery_app/core/color_app.dart';
import 'package:pizza_delivery_app/firebase_options.dart';
import 'package:pizza_delivery_app/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      "pk_test_51OIMAyHdpKm7MB8qqvzh6yB053y1lg8vJlUhPZ05Omb93IrEljTl9pC4YAuay0jh1cvxfQfHAkWMnkiGhfB3l92Y00XANULzRX";
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pizza Delivery App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: ColorApp.primary,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: ColorApp.primary,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(width: 2, color: ColorApp.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(width: 1, color: ColorApp.primary),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
