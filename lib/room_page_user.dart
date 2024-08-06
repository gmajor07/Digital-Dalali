import 'package:digital_dalali/room.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:digital_dalali/moreimages_user.dart';
import 'package:url_launcher/url_launcher.dart';

class RoomSearchUserPage extends StatelessWidget {
  final String selectedStreet;
  final String? selectedType; // Updated to accept nullable type

  const RoomSearchUserPage(
      {super.key, required this.selectedStreet, required this.selectedType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 60),
          Text(
            '$selectedStreet $selectedType (s)',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('room')
                    .where('street', isEqualTo: selectedStreet)
                    .where('status', isEqualTo: 'Available')
                    .where('type',
                        isEqualTo:
                            selectedType) // Add this line to check 'type'
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> roomSnapshot) {
                  if (roomSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (roomSnapshot.hasError) {
                    return const Center(child: Text('Error fetching data.'));
                  }
                  if (roomSnapshot.hasData && roomSnapshot.data != null) {
                    var roomData = roomSnapshot.data!.docs;
                    if (roomData.isNotEmpty) {
                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (userSnapshot.hasError) {
                            return const Center(
                                child: Text('Error fetching user data.'));
                          }
                          if (userSnapshot.hasData &&
                              userSnapshot.data != null) {
                            var userData = userSnapshot.data!.docs;
                            if (userData.isNotEmpty) {
                              var userMap = {
                                for (var userDoc in userData)
                                  userDoc.id: userDoc.data(),
                              };
                              List<Widget> roomWidgets = [];
                              for (var roomDoc in roomData) {
                                var room =
                                    roomDoc.data() as Map<String, dynamic>;
                                if (room.containsKey('price') &&
                                    room.containsKey('street') &&
                                    room.containsKey('imageURLs') &&
                                    room.containsKey('userId') &&
                                    room.containsKey('description') &&
                                    room.containsKey('type') &&
                                    room.containsKey('uploadTime')) {
                                  String price = room['price'];
                                  String location = room['street'];
                                  String type = room['type'];
                                  String roomUserId = room['userId'];
                                  String description = room['description'];
                                  String uploadTime =
                                      DateFormat('MMM dd, yyyy - HH:mm')
                                          .format(room['uploadTime']!.toDate());

                                  List<String> imageURLs = [];
                                  if (room['imageURLs'] is List<dynamic>) {
                                    imageURLs =
                                        List<String>.from(room['imageURLs']);
                                  }
                                  var user = userMap[roomUserId]
                                      as Map<String, dynamic>;
                                  String username = user['username'] ?? 'N/A';
                                  String phone = user['phone'] ?? 'N/A';

                                  if (imageURLs.isNotEmpty) {
                                    roomWidgets.add(
                                      Container(
                                          margin: const EdgeInsets.only(
                                              right:
                                                  10.0), // Add margin for spacing
                                          width: 350,
                                          height: 380, // Set the desired width
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                12), // Add the border radius
                                            border: Border.all(
                                              color: Colors
                                                  .grey, // Set the border color as needed
                                              width:
                                                  2.0, // Set the border width as needed
                                            ),
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailsPage(
                                                    roomId: roomDoc.id,
                                                    imageURLs: imageURLs,
                                                    price: price,
                                                    location: location,
                                                    username: username,
                                                    phone: phone,
                                                    type: type,
                                                    uploadTime: uploadTime,
                                                    description: description,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.network(
                                                    imageURLs[0],
                                                    height: 300,
                                                    width: 300,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (BuildContext context,
                                                            Object exception,
                                                            StackTrace?
                                                                stackTrace) {
                                                      return Image.asset(
                                                          'assets/post2.png',
                                                          height: 300,
                                                          width: 300);
                                                    },
                                                  ),
                                                ),
                                                ListTile(
                                                  title: Text(
                                                    'Price: Tsh $price/= Per Monthly',
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                    );
                                  } else {
                                    roomWidgets.add(
                                      ListTile(
                                        leading: Image.asset(
                                            'assets/post2.png'), // Replace with your placeholder image asset
                                        title: Text('Price: $price'),
                                      ),
                                    );
                                  }
                                }
                              }
                              if (roomWidgets.isNotEmpty) {
                                return ListView.builder(
                                  scrollDirection:
                                      Axis.horizontal, // Scroll horizontally
                                  itemCount: roomWidgets.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Center(
                                      child: roomWidgets[index],
                                    );
                                  },
                                );
                              } else {
                                return const Center(
                                    child: Text(
                                  'No posts found.',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.blueGrey),
                                ));
                              }
                            }
                          }
                          return const Center(
                              child: Text('Error retrieving user data.'));
                        },
                      );
                    } else {
                      return Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/error1.png',
                              width: 300,
                              height: 300,
                            ),
                            const Text(
                              'Sorry no posts found.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                  return const Center(child: Text('Error retrieving posts.'));
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedImageURLs = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserRoom(),
            ),
          );
        },
        backgroundColor: Colors.yellow, // You can also change the icon color if needed
        // Add semanticLabel for accessibility
        tooltip: 'Go back to user room', // Set the background color to yellow
        child: const Icon(Icons.backspace,
            color: Colors.black),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final String roomId;
  final String price;
  final String location;
  final String type;
  final String description;
  final List<String> imageURLs;
  final String username;
  final String phone;
  final String uploadTime;

  const DetailsPage({
    Key? key,
    required this.roomId,
    required this.price,
    required this.location,
    required this.type,
    required this.imageURLs,
    required this.username,
    required this.phone,
    required this.uploadTime,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text(
                '$type - $price Tsh/=',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Row(
                  children: [
                    const SizedBox(width: 28),
                    Flexible(
                      flex: 1,
                      child: Text(
                        uploadTime,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 400,
                width: 380,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: PageView.builder(
                          itemCount: imageURLs.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MoreImages(
                                      roomId: roomId,
                                      imageURLs: imageURLs,
                                    ),
                                  ),
                                );
                              },
                              child: Image.network(
                                imageURLs[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Handle the error here, and display the default image
                                  return Image.asset(
                                    'assets/post2.png', // Provide the path to your local asset image
                                    width: 300, // Adjust the width as needed
                                    height: 300, // Adjust the height as needed
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        padding: const EdgeInsets.all(10.0),
                        child: const Text(
                          'Tap image to see more\n images',
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
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  const SizedBox(width: 28),
                  Flexible(
                    flex: 2,
                    child: Text(
                      description.toUpperCase(), // Convert to uppercase
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Flexible(
                    flex: 1,
                    child: Text(
                      location.toUpperCase(),
                      style: const TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 70,
                width: 330,
                child: ElevatedButton(
                  onPressed: () {
                    _showPhoneDialog(context, phone);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: const BorderSide(width: 3, color: Colors.amber),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Contact Seller',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedImageURLs = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserRoom(),
            ),
          );
        },
        backgroundColor: Colors.yellow, // Set the background color to yellow
        child: const Icon(Icons.backspace,
            color:
                Colors.black), // You can also change the icon color if needed
      ),
    );
  }
}

void _showPhoneDialog(BuildContext context, String phone) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Contact Seller'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Call: $phone',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40,
                  width: 70,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      launch('tel:$phone');
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.call), // Icon for the "Call" button
                    label: const Text(''),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 40,
                  width: 70,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      launch('sms:$phone');
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                        Icons.message), // Icon for the "Message" button
                    label: const Text(''),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 40,
                  width: 70,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Use the WhatsApp URL scheme
                      launch('whatsapp://send?phone=$phone');
                      Navigator.of(context).pop();
                    },
                    icon: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/WhatsApp.svg/2048px-WhatsApp.svg.png',
                      width: 24,
                      height: 24,
                    ),
                    label: const Text(
                      '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
