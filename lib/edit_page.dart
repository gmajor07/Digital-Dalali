import 'package:digital_dalali/profile.dart';
import 'package:digital_dalali/search.dart';
import 'package:digital_dalali/upload.dart';
import 'package:digital_dalali/view_post.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class EditPage extends StatefulWidget {
  final String roomId;
  final List<String> imageURLs;

  const EditPage({Key? key, required this.roomId, required this.imageURLs})
      : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final ImagePicker _imagePicker = ImagePicker();
  List<File> selectedImages = [];

  Future<void> pickImage(ImageSource source) async {
    try {
      if (selectedImages.length < 10) {
        // Limit to a maximum of 5 images
        final pickedFile = await _imagePicker.pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            selectedImages.add(File(pickedFile.path));
          });
        }
      } else {

        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: const Column(
            mainAxisSize: MainAxisSize.min, // set column size to minimum
            children: <Widget>[
              Text(
                'Upload Failed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'You can only select up to 10 images..',
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
      }
    } catch (e) {
      // Handle image selection error.
      if (kDebugMode) {
        print('Failed to select image: $e');
      }
    }
  }

  bool uploading = false; // Added a flag to track upload progress

  Future<void> uploadImages() async {
    try {
      setState(() {
        uploading = true; // Set the flag to indicate that upload is in progress
      });
      final List<String> uploadedURLs = [];

      for (File imageFile in selectedImages) {
        final String imageFileName =
            DateTime.now().millisecondsSinceEpoch.toString();

        // Use the existing room ID to find the corresponding folder
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('images')
            .child('room_${widget.roomId}') // Use the correct room ID here
            .child('image_$imageFileName.jpg');

        final TaskSnapshot snapshot = await storageRef.putFile(imageFile);
        final String downloadURL = await snapshot.ref.getDownloadURL();
        uploadedURLs.add(downloadURL);

        // Print the image folder path for debugging
        if (kDebugMode) {
          print(' Room Id ${widget.roomId}');
          print('Image folder path: ${storageRef.fullPath}');
        }
      }
      // Update the Firestore document with the new imageURLs
      final DocumentReference roomRef =
          FirebaseFirestore.instance.collection('rooms').doc(widget.roomId);
      final DocumentSnapshot roomSnapshot = await roomRef.get();
      final Map<String, dynamic>? roomData =
          roomSnapshot.data() as Map<String, dynamic>?;

      if (roomData != null && roomData.containsKey('imageURLs')) {
        final List<dynamic> imageURLs =
            List<dynamic>.from(roomData['imageURLs']);
        imageURLs.addAll(uploadedURLs);
        await roomRef.update({'imageURLs': imageURLs});
      } else {
        await roomRef.set({'imageURLs': uploadedURLs}, SetOptions(merge: true));
      }

      // Clear the selected images after successful upload
      setState(() {
        selectedImages.clear();
      });
      // Set uploading to false after completion
      setState(() {
        uploading = false;
      });


      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: const Column(
          mainAxisSize: MainAxisSize.min, // set column size to minimum
          children: <Widget>[
            Text(
              'Upload successfully',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Images uploaded successfully',
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
          side: const BorderSide(color: Colors.green, width: 1),
          borderRadius: BorderRadius.circular(24),
        ),
        duration: const Duration(seconds: 3), // Set the duration to 3 seconds

      );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    } catch (e) {
      if (kDebugMode) {
        print('Failed to upload images: $e');
      }
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: const Column(
          mainAxisSize: MainAxisSize.min, // set column size to minimum
          children: <Widget>[
            Text(
              'Upload Failed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Failed to upload images check for errors',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 195, 13),
        title: const Text(
          'Photos Collection',
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
                        builder: (innerContext) => const LocationSelectionPage(
                            userId: '', username: '')),
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
      body: Column(
        children: [
          // Display the selected images
          Expanded(
            child: ListView.builder(
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.file(selectedImages[index]),
                );
              },
            ),
          ),
          // Show a circular progress indicator if uploading is in progress
          if (uploading)
            const CircularProgressIndicator(
              value: 0.8,
              strokeWidth: 5.0,
              color: Colors.deepOrange,
            ),
          // Add a button to select images
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: () async {
                await pickImage(ImageSource.gallery);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size.fromHeight(70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Selected Photo ",
                    style: TextStyle(fontSize: 20,color: Colors.white),
                  ),
                  Text(
                    "(${selectedImages.length})",
                    style: const TextStyle(fontSize: 16,color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Call the method to upload images and store references in Firestore.
          await uploadImages();
        },
        backgroundColor: Colors.yellow, // Set the background color to yellow
        child: const Icon(Icons.save,
            color:
                Colors.black), // You can also change the icon color if needed
      ),
    );
  }
}
