import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_dalali/search.dart';
import 'package:digital_dalali/upload.dart';
import 'package:digital_dalali/view_post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _userIdController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 195, 13),
        title: const Text(
          "My Profile",
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => const LoginForm(),
                ),
                (route) =>
                    false, //if you want to disable back feature set to false
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 141, 110, 32),
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  " DALALI",
                  style: TextStyle(
                    fontSize: 55,
                    color: Colors.black45,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const Divider(
              color: Colors.white,
              thickness: 0,
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.white),
              title: const Text(
                "Search",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Builder(
                      // Use Builder widget here
                      builder: (innerContext) =>
                          const LocationSelectionPage(userId: '', username: ''),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.post_add, color: Colors.white),
              title: const Text(
                "New Post",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UploadPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.ad_units, color: Colors.white),
              title: const Text(
                "Post",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ViewPostPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_2, color: Colors.white),
              title: const Text(
                "My Profile",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UserProfile(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<String?>(
        future: SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('userId')),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator or message
            return const CircularProgressIndicator(); // For example, show a loading spinner
          }

          if (snapshot.hasData && snapshot.data != null) {
            String userId = snapshot.data!;

            return FutureBuilder<DocumentSnapshot>(
              future: firestore.collection('users').doc(userId).get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data != null) {
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>?;

                    if (userData != null) {
                      // Initialize form field values
                      _usernameController.text = userData['username'];
                      _userIdController.text = userData['userId'];
                      _emailController.text = userData['email'];
                      _phoneController.text = userData['phone'];

                      return Form(
                        key: _formKey,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 100,
                                ),
                                const Text(
                                  "Update your details",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 330,
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
                                  width: 330,
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.mail,
                                          color: Colors.grey),
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
                                  width: 330,
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.phone,
                                          color: Colors.grey),
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
                                  width: 330,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        // Perform the update operation here
                                        String updatedUsername =
                                            _usernameController.text;
                                        String updatedEmail =
                                            _emailController.text;
                                        String updatedPhone =
                                            _phoneController.text;

                                        // Update the user profile data in the Firestore collection
                                        firestore
                                            .collection('users')
                                            .doc(userId)
                                            .update({
                                          'username': updatedUsername,
                                          'email': updatedEmail,
                                          'phone': updatedPhone,
                                        });

                                        final snackBar = SnackBar(
                                          backgroundColor: Colors.green,
                                          content: const Column(
                                            mainAxisSize: MainAxisSize.min, // set column size to minimum
                                            children: <Widget>[
                                              Text(
                                                'Success',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'You successfully update you profile!',
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
                                            side: const BorderSide(color: Colors.greenAccent, width: 1),
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          duration: const Duration(seconds: 3), // Set the duration to 3 seconds

                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      minimumSize: const Size.fromHeight(70),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: const Text('Update Profile',style: TextStyle(color: Colors.white),),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }
                }

                return const Text('User profile not found.');
              },
            );
          }

          return const Text('User ID not found.');
        },
      ),
    );
  }
}
