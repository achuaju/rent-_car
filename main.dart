import 'package:Rent_a_car/users_pages/car_booking_main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/bookingviewpage.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/avaliblecar_screen_main.dart';

import 'users_pages/userdetails.dart';

// Assuming ProfilePage is in this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Rental App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => CarListScreen1(), // Update this route as needed
        '/favorites': (context) => DataViewPage(),
        '/profile': (context) => ProfilePage(),
        '/booking': (context) => BookingPage1(),
        // Add other routes as needed
      },
    );
  }
}
