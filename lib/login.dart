import 'package:digital_dalali/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'search.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String trimmedUsername = username.trim(); // Trim for database query
      // Hash the password
      String password = _passwordController.text;
      String hashedPassword = hashPassword(password);

      // Create a Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Perform the login check
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection('users')
          .where('username', isEqualTo: trimmedUsername)
          .where('password', isEqualTo: hashedPassword)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Login successful
        String userId = querySnapshot.docs[0].id;
        String username = querySnapshot.docs[0].data()['username'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  LocationSelectionPage(
                    username: username,
                    userId: userId,
                  ),
            ));
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: const Column(
            mainAxisSize: MainAxisSize.min, // set column size to minimum
            children: <Widget>[
              Text(
                'Login Failed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Failed to login please try again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.yellow,
            onPressed: () {
              // Some code to retry the operation.
            },
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.red, width: 1),
            borderRadius: BorderRadius.circular(24),
          ),
          duration: const Duration(seconds: 3), // Set the duration to 3 seconds
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        ;
      }
    }
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var hashedPassword = sha256.convert(bytes).toString();
    return hashedPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 480,
                  child: Stack(
                    children: [
                      Image(
                        image: AssetImage('assets/wall.jpg'),
                        fit: BoxFit.cover, // Adjust fit based on your image
                        height: 500, // Increase or decrease the height as needed
                        width: double.infinity, // Set width to fill the available space
                      ),

                      Center(
                        child: Text(
                          "DIGITAL DALALI,",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'ui-sans-serif',
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black26,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Welcome to dalali digital Platform..",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.grey,
                      ),
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 350,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 350,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Go In',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationForm(),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.blueGrey,
                              fontSize: 16),
                        ),
                        TextSpan(
                          text: "Register",
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/search') {
          final Map<String, dynamic>? arguments =
          settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) =>
                LocationSelectionPage(
                  userId: arguments?['userId'] ?? '',
                  username: arguments?['username'] ?? '',
                ),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const LoginForm(),
      },
    ));
  }
}