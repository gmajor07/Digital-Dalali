import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:digital_dalali/register.dart';
import 'package:digital_dalali/room.dart';
import 'package:digital_dalali/upload.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dalali App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DalaliApp(),
        '/registration': (context) => const RegistrationForm(),
        '/login': (context) => const LoginForm(),
        '/upload': (context) => const UploadPage(),
        '/room': (context) => const UserRoom(),
      },
    );
  }
}

class DalaliApp extends StatelessWidget {
  const DalaliApp({super.key});

  Widget _buildShakeTransition(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(sin(value * pi * 2) * 50.0, 0.0),
          child: child,
        );
      },
      child: const Text(
        "Get Started",
        style: TextStyle(
          fontSize: 37,
          fontWeight: FontWeight.w700,
          color: Colors.blue,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/dalali.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 30.0),
                  const Center(
                    child: Text(
                      'DIGITAL \nDALALI',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 94,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'OpenSans',
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.4), // Adjust the spacing dynamically
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/room');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildShakeTransition(context),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.black45,
                              child: Semantics(
                                button: true,
                                enabled: true,
                                label: 'Continue to user room',
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/room');
                                  },
                                  icon: const Icon(Icons.arrow_forward, color: Colors.blue, size: 50),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.1), // Adjust the spacing dynamically
                  const Center(
                    child: Text(
                      'Do you have a post?',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 170,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/registration');
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: const BorderSide(width: 3, color: Colors.black),
                            ),
                          ),
                          child: const Text('Register', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 170,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color.fromARGB(255, 48, 48, 48),
                            backgroundColor: Colors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: const BorderSide(width: 3, color: Color.fromARGB(255, 48, 48, 48)),
                            ),
                          ),
                          child: const Text('Login', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
