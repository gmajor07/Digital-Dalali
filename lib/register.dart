import 'package:digital_dalali/profile.dart';
import 'package:digital_dalali/upload.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'login.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void registerUser() {
    if (_formKey.currentState!.validate()) {
      // Hash the password
      String password = _passwordController.text;
      String hashedPassword = hashPassword(password);

      // Create a Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Check if username or email already exists
      String username = _usernameController.text;
      String email = _emailController.text;

      firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get()
          .then((QuerySnapshot usernameSnapshot) {
        if (usernameSnapshot.docs.isNotEmpty) {
          // User with the same username already exists
          final snackBar = SnackBar(
            backgroundColor: Colors.red,
            content: const Column(
              mainAxisSize: MainAxisSize.min, // set column size to minimum
              children: <Widget>[
                Text(
                  'Registration Failed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'User with the same username already exists.',
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
          );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get()
              .then((QuerySnapshot emailSnapshot) {
            if (emailSnapshot.docs.isNotEmpty) {
              // User with the same email already exists

              final snackBar = SnackBar(
                backgroundColor: Colors.red,
                content: const Column(
                  mainAxisSize: MainAxisSize.min, // set column size to minimum
                  children: <Widget>[
                    Text(
                      'Registration Failed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'User with the same email already exists.',
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

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              // Generate a unique user ID
              String userId = firestore.collection('users').doc().id;
              // Send data to Firestore
              firestore.collection('users').doc(userId).set({
                'userId': userId,
                'username': username,
                'password': hashedPassword,
                'email': email,
                'phone': _phoneController.text,
              }).then((value) {
                // Registration successful
                final snackBar = SnackBar(
                  backgroundColor: Colors.green,
                  content: const Column(
                    mainAxisSize: MainAxisSize.min, // set column size to minimum
                    children: <Widget>[
                      Text(
                        'Registration successfully',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'You have registered successfully please continue',
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
                    label: 'Ok',
                    textColor: Colors.white,
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

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                // Clear input fields
                _usernameController.clear();
                _passwordController.clear();
                _emailController.clear();
                _phoneController.clear();

              }).catchError((error) {
                // Error handling
                if (kDebugMode) {
                  print('Registration error: $error');
                }
              });
            }
          });
        }
      });
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
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 230,
                    child: Stack(
                      children: [
                        Image(
                          image: AssetImage('assets/wall.jpg'),
                          fit: BoxFit.cover, // Adjust fit based on your image
                          height: 300, // Increase or decrease the height as needed
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
                  const Text(
                    "Create Your Account to start",
                    style: TextStyle(fontSize: 20,color:Colors.grey,),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.mail, color: Colors.grey),
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                        labelText: 'Phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: 350,
                    child: ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 20,color: Colors.white,),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginForm(),
                        ),
                      );
                    },
                      child:RichText(
                        text: const TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: "I have an account? ",
                              style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                            ),
                            TextSpan(
                              text: "Login",
                              style: TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                          ],
                        ),
                      )

                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    routes: {
      '/': (context) => const RegistrationForm(),
      '/profile': (context) => const UserProfile(),
      '/upload': (context) =>  const UploadPage(),
    },
    initialRoute: '/',
    debugShowCheckedModeBanner: false, // Remove the debug banner

  ));
}
