import 'dart:io';
import 'package:digital_dalali/profile.dart';
import 'package:digital_dalali/search.dart';
import 'package:digital_dalali/upload.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_page.dart';
import 'login.dart';

class ViewPostPage extends StatelessWidget {
  const ViewPostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 195, 13),
        title: const Text(
          "My Post",
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
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            String userId = snapshot.data!;
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('room')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data != null) {
                  var roomData = snapshot.data!.docs;
                  if (roomData.isNotEmpty) {
                    return ListView.builder(
                      itemCount: roomData.length,
                      itemBuilder: (BuildContext context, int index) {
                        var room =
                            roomData[index].data() as Map<String, dynamic>;
                        String price = room['price'];
                        String street = room['street'];
                        String roomId = roomData[index].id;

                        return GestureDetector(
                          onTap: () {
                            // Navigate to MoreDetailsPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MoreDetailsPage(
                                    roomData: room, roomId: roomId),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: SizedBox(
                              width: 64, // Set the desired width
                              child: Image.network(
                                room['imageURLs'][0],
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Image.asset('assets/post2.png');
                                },
                              ),
                            ),
                            title: Text('Price: $price'),
                            subtitle: Text('Location: $street'),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        side: const BorderSide(
                                            color: Colors
                                                .grey), // Adding border color
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Confirmation',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amber),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Are you sure you want to remove this Post?',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.blueGrey),
                                            ),
                                            const SizedBox(height: 16),
                                            Container(
                                              margin: const EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                      16.0), // Adjust the margin as needed
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.black,
                                                      ),
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          16.0), // Add space between buttons
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        // Call the function to delete the room document
                                                        deleteRoom(roomId);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color
                                                                .fromARGB(255,
                                                                151, 161, 6),
                                                      ),
                                                      child: const Text(
                                                        'Yes Delete',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No posts found.'));
                  }
                }
                return const Center(child: Text('Error retrieving posts.'));
              },
            );
          }
          return const Center(child: Text('User ID not found.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedImageURLs = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UploadPage(),
            ),
          );
        },
        backgroundColor: Colors.yellow, // Set the background color to yellow
        child: const Icon(Icons.add,
            color:
                Colors.black), // You can also change the icon color if needed
      ),
    );
  }
}

void deleteRoom(String roomId) async {
  await FirebaseFirestore.instance.collection('room').doc(roomId).delete();
}

bool shouldShowAdditionalFieldsInDataTable(String type) {
  return type.toLowerCase() != 'land' &&
      type.toLowerCase() != 'frame' &&
      type.toLowerCase() != 'go down';
}

bool shouldShowAdditionalFieldsLand(String type) {
  return type.toLowerCase() != 'land';
}

class MoreDetailsPage extends StatelessWidget {
  final Map<String, dynamic> roomData;
  final String roomId; // Add the roomId variable
  final TextEditingController priceController;
  final TextEditingController houseNumberController;
  final TextEditingController descriptionController;

  MoreDetailsPage({
    Key? key,
    required this.roomData,
    required this.roomId,
  })  : priceController = TextEditingController(text: roomData['price'] ?? ''),
        houseNumberController =
            TextEditingController(text: roomData['houseNumber'] ?? ''),
        descriptionController =
            TextEditingController(text: roomData['description'] ?? ''),
        super(key: key);

  void _showEditInfoModal(BuildContext context, String roomId, type) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool showAdditionalFieldsLand =
                shouldShowAdditionalFieldsLand(type);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Edit Post',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.money_off, color: Colors.grey),
                          labelText: 'Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          roomData['price'] = value;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      if (showAdditionalFieldsLand)
                        TextFormField(
                          controller: houseNumberController,
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.house, color: Colors.grey),
                            labelText: 'Enter House Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            roomData['houseNumber'] = value;
                          },
                        ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: null,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.message, color: Colors.grey),
                          labelText: 'Add additional Information',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          roomData['description'] = value;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: 300,
                        height: 60,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blueGrey),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: const BorderSide(
                                    width: 3, color: Colors.amber),
                              ),
                            ),
                          ),
                          onPressed: () {
                            _updateFirestoreData(roomId, roomData);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateFirestoreData(
      String roomId, Map<String, dynamic> updatedData) async {
    try {
      // Reference to the document in the 'room' collection
      DocumentReference roomRef =
          FirebaseFirestore.instance.collection('room').doc(roomId);

      // Update the document with the provided data
      await roomRef.update(updatedData);

      // Print a message indicating success
      if (kDebugMode) {
        print('Document updated successfully!');
      }
    } catch (e) {
      // Handle errors here
      if (kDebugMode) {
        print('Error updating document: $e');
      }
    }
  }

  void _updateStatusToZero(BuildContext context, String roomId) async {
    try {
      // Reference to the document in the 'room' collection
      DocumentReference roomRef =
          FirebaseFirestore.instance.collection('room').doc(roomId);

      // Update the status to 'Taken'
      await roomRef.update({'status': 'Taken'});

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: SizedBox(
              height: 300.0, // Set the desired height for the dialog
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 10.0,
                contentPadding: const EdgeInsets.all(10.0),
                title: const AnimatedDefaultTextStyle(
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                  duration: Duration(milliseconds: 300),
                  child: Text(
                    'Status Updated',
                  ),
                ),
                content: AnimatedDefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.normal,
                  ),
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: Image.asset(
                              'assets/tick.png',
                            ),
                          ),
                        ),
                        AnimatedDefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                          ),
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            'The post now is not available, it is taken.',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue[400]!,
                          Colors.blue[600]!,
                        ],
                      ),
                    ),
                    child: TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        // Navigate to the ViewPostPage here
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewPostPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Print a message indicating success (if needed)
      if (kDebugMode) {
        print('Status updated to "Taken" successfully!');
      }
    } catch (e) {
      // Handle errors here
      if (kDebugMode) {
        print('Error updating status: $e');
      }
    }
  }

  void _updateStatusToOne(BuildContext context, String roomId) async {
    try {
      // Reference to the document in the 'room' collection
      DocumentReference roomRef =
          FirebaseFirestore.instance.collection('room').doc(roomId);
      // Update the status to 'Available'
      await roomRef.update({'status': 'Available'});
      // Show a success message to the user in a dialog
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: SizedBox(
              height: 300.0, // Set the desired height for the dialog
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 10.0,
                contentPadding: const EdgeInsets.all(10.0),
                title: const AnimatedDefaultTextStyle(
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                  duration: Duration(milliseconds: 300),
                  child: Text(
                    'Status Updated',
                  ),
                ),
                content: AnimatedDefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.normal,
                  ),
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: Image.asset(
                              'assets/error.png',
                            ),
                          ),
                        ),
                        AnimatedDefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                          ),
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            'The post now is available, it can be booked.',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue[400]!,
                          Colors.blue[600]!,
                        ],
                      ),
                    ),
                    child: TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        // Navigate to the ViewPostPage here
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewPostPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      // Print a message indicating success (if needed)
      if (kDebugMode) {
        print('Status updated to "Available" successfully!');
      }
    } catch (e) {
      // Handle errors here
      if (kDebugMode) {
        print('Error updating status: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract all the details from roomData and display them here
    String description = roomData['description'] ?? 'No description available';
    String district = roomData['district'] ?? 'No description available';
    String houseNumber = roomData['houseNumber'] ?? 'No description available';
    String kodi = roomData['kodi'] ?? 'No description available';
    String ward = roomData['ward'] ?? 'No description available';
    String maji = roomData['maji'] ?? 'No description available';
    String umeme = roomData['umeme'] ?? 'No description available';
    String street = roomData['street'] ?? 'No description available';
    String region = roomData['region'] ?? 'No description available';
    String type = roomData['type'] ?? 'No description available';
    String board = roomData['board'] ?? 'No description available';
    String toilet = roomData['toilet'] ?? 'No description available';
    String tails = roomData['tails'] ?? 'No description available';
    String price = roomData['price'] ?? 'No description available';
    String status = roomData['status'] ?? 'No description available';
    // ... Extract other details similarly
    if (kDebugMode) {
      print(roomData);
    }

    List<String> imageURLs = List<String>.from(roomData['imageURLs']);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 195, 13),
        title: const Text(
          "My Post",
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Display the images using a ListView.builder
          Center(
            child: SizedBox(
              height: 250, // Adjust the height as needed
              width: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageURLs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.all(8.0), // Adjust image padding
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(12.0), // Rounded corners
                      color: Colors.grey[200], // Background color
                    ),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  roomId: roomId,
                                  imageURLs: const [], // Pass additional details if needed
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            imageURLs[index],
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              if (exception is SocketException) {
                                // Handle network errors
                                return Image.asset(
                                    'assets/post2.png'); // Display placeholder image
                              } else {
                                return Image.asset(
                                    'assets/post2.png'); // Handle other exceptions
                              }
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.all(10.0),
                            child: const Text(
                              'Tap image to see more \n images',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          const Center(
              child: Text(
            'Full Post Details',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey),
          )),
          const SizedBox(
            height: 10,
          ),
          // Create a DataTable to display the room details in a table format
          DataTable(
            columns: const [
              DataColumn(label: Text('Field')),
              DataColumn(label: Text('Value')),
            ],
            rows: [
              DataRow(
                cells: [
                  const DataCell(Text('Description')),
                  DataCell(Text(description)),
                ],
              ),
              DataRow(
                cells: [
                  const DataCell(Text('House Number')),
                  DataCell(Text(houseNumber)),
                ],
              ),
              DataRow(cells: [
                const DataCell(Text('Region')),
                DataCell(Text(region)),
              ]),
              DataRow(cells: [
                const DataCell(Text('District')),
                DataCell(Text(district)),
              ]),
              DataRow(cells: [
                const DataCell(Text('Ward')),
                DataCell(Text(ward)),
              ]),
              DataRow(cells: [
                const DataCell(Text('Street')),
                DataCell(Text(street)),
              ]),
              DataRow(cells: [
                const DataCell(Text('Type')),
                DataCell(Text(type)),
              ]),

              if (shouldShowAdditionalFieldsInDataTable(type))
                DataRow(cells: [
                  const DataCell(Text('Kodi')),
                  DataCell(Text(kodi)),
                ]),
              if (shouldShowAdditionalFieldsInDataTable(type))
                DataRow(cells: [
                  const DataCell(Text('Maji')),
                  DataCell(Text(maji)),
                ]),
              if (shouldShowAdditionalFieldsInDataTable(type))
                DataRow(cells: [
                  const DataCell(Text('Umeme')),
                  DataCell(Text(umeme)),
                ]),
              if (shouldShowAdditionalFieldsInDataTable(type))
                DataRow(cells: [
                  const DataCell(Text('Tails')),
                  DataCell(Text(tails)),
                ]),
              if (shouldShowAdditionalFieldsInDataTable(type))
                DataRow(cells: [
                  const DataCell(Text('Board')),
                  DataCell(Text(board)),
                ]),
              if (shouldShowAdditionalFieldsInDataTable(type))
                DataRow(cells: [
                  const DataCell(Text('Toilet')),
                  DataCell(Text(toilet)),
                ]),
              DataRow(cells: [
                const DataCell(Text('Price')),
                DataCell(Text('$price Tsh/=')),
              ]),
              DataRow(cells: [
                const DataCell(Text('Status')),
                DataCell(Text(status)),
              ]),
              // Add more rows for other details as needed
            ],
          ),

          const SizedBox(
            height: 16.0,
          ),
          SizedBox(
            width: 300,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                _showEditInfoModal(context, roomId, type); // Pass the roomId
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(width: 3, color: Colors.amber),
                  ),
                ),
              ),
              child: const Center(
                child: Row(
                  children: [
                    SizedBox(
                        width: 128), // Add some space between the icon and text
                    Text(
                      'Edit Post',
                      style: TextStyle(fontSize: 17),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.edit, // You can use a different icon if needed
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16.0,
          ),

          Row(
            children: [
              SizedBox(
                width: 186,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    _updateStatusToZero(context, roomId);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.lightGreen),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: const BorderSide(width: 3, color: Colors.amber),
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check, // You can use a different icon if needed
                        color: Colors.white,
                      ),
                      SizedBox(
                          width: 8), // Add some space between the icon and text
                      Text(
                        'Taken',
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 186,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    _updateStatusToOne(context, roomId);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: const BorderSide(width: 3, color: Colors.amber),
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.close, // You can use a different icon if needed
                        color: Colors.white,
                      ),
                      SizedBox(
                          width: 8), // Add some space between the icon and text
                      Text(
                        'Free Now',
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
