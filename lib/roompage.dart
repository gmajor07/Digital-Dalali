import 'package:digital_dalali/profile.dart';
import 'package:digital_dalali/search.dart';
import 'package:digital_dalali/upload.dart';
import 'package:digital_dalali/view_post.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login.dart';
import 'moreimages.dart';
// Other imports...

class RoomSearchPage extends StatelessWidget {
  final String selectedStreet;
  final String? selectedType; // Updated to accept nullable type

  const RoomSearchPage(
      {super.key, required this.selectedStreet, required this.selectedType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 195, 13),
        title: const Text(
          'Shown Post',
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
                  "DALALI",
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
                    .where('type', isEqualTo: selectedType)
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
                                    room.containsKey('district') &&
                                    room.containsKey('ward') &&
                                    room.containsKey('region') &&
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

                                  roomWidgets.add(
                                    ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailsPage(
                                              roomId: roomDoc.id,
                                              imageURLs: imageURLs,
                                              price: price,
                                              location: location,
                                              username: username,
                                              phone: phone,
                                              type: type,
                                              umeme: room['umeme'],
                                              maji: room['maji'],
                                              toilet: room['toilet'],
                                              board: room['board'],
                                              tails: room['tails'],
                                              houseNumber: room['houseNumber'],
                                              located: room['located'],
                                              district: room['district'],
                                              kodi: room['kodi'],
                                              region: room['region'],
                                              ward: room['ward'],
                                              uploadTime: uploadTime,
                                              description: description,
                                              appBar: AppBar(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 250, 195, 13),
                                                title: const Text('Details'),
                                              ),
                                              drawer: Drawer(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 141, 110, 32),
                                                child: ListView(
                                                  children: [
                                                    const DrawerHeader(
                                                      child: Center(
                                                        child: Text(
                                                          " DALALI",
                                                          style: TextStyle(
                                                            fontSize: 55,
                                                            color:
                                                                Colors.black45,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Divider(
                                                      color: Colors.white,
                                                      thickness: 0,
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.search,
                                                          color: Colors.white),
                                                      title: const Text(
                                                        "Search",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Builder(
                                                              builder:
                                                                  (innerContext) =>
                                                                      const LocationSelectionPage(
                                                                userId: '',
                                                                username: '',
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.post_add,
                                                          color: Colors.white),
                                                      title: const Text(
                                                        "New Post",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const UploadPage(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons
                                                              .panorama_fish_eye_outlined,
                                                          color: Colors.white),
                                                      title: const Text(
                                                        "My Post",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const ViewPostPage(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.person_2,
                                                          color: Colors.white),
                                                      title: const Text(
                                                        "My Profile",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const UserProfile(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      leading: Image.network(
                                        imageURLs.isNotEmpty
                                            ? imageURLs[0]
                                            : 'assets/post2.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return Image.asset(
                                              'assets/post2.png');
                                        },
                                      ),
                                      title: Text('Price: $price /='),
                                      subtitle: Text('Location: $location'),
                                    ),
                                  );
                                }
                              }
                              if (roomWidgets.isNotEmpty) {
                                return ListView(
                                  children: roomWidgets,
                                );
                              } else {
                                return const Center(
                                    child: Text('No posts found here.'));
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
    );
  }
}

bool shouldShowAdditionalFieldsLandAndFrame(String type) {
  return type.toLowerCase() != 'land' &&
      type.toLowerCase() != 'frame' &&
      type.toLowerCase() != 'go down';
}

bool shouldShowAdditionalFieldsLand(String type) {
  return type.toLowerCase() != 'land';
}

class DetailsPage extends StatelessWidget {
  final String roomId;
  final String price;
  final String location;
  final String region;
  final String ward;
  final String type;
  final String description;
  final List<String> imageURLs;
  final String username;
  final String phone;
  final String uploadTime;
  final String? umeme; // Add this line for Umeme
  final String? maji; // Add this line for Maji
  final String? toilet; // Add this line for Toilet
  final String? board; // Add this line for Board
  final String? tails; // Add this line for Tails
  final String? houseNumber; // Add this line for House Number
  final String? located; // Add this line for Located
  final String? district; // Add this line for District
  final String? kodi; // Add this line for Kodi
  final AppBar appBar;
  final Drawer drawer;

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
    required this.umeme, // Add this line for Umeme
    required this.maji, // Add this line for Maji
    required this.toilet, // Add this line for Toilet
    required this.board, // Add this line for Board
    required this.tails, // Add this line for Tails
    required this.houseNumber, // Add this line for House Number
    required this.located, // Add this line for Located
    required this.district, // Add this line for District
    required this.kodi, // Add this line for Kodi
    required this.appBar,
    required this.drawer,
    required this.description,
    required this.region,
    required this.ward,
  }) : super(key: key);

  void _showMoreInfoModal(BuildContext context) {
    final AnimationController controller = AnimationController(
      duration:
          const Duration(milliseconds: 500), // Adjust the duration as needed
      vsync: Navigator.of(context),
    );

    controller.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool showAdditionalFields =
            shouldShowAdditionalFieldsLandAndFrame(type);
        bool showAdditionalFieldsLand = shouldShowAdditionalFieldsLand(type);

        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Opacity(
              opacity: controller.value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                title: const Text(
                  'Full Post Details',
                  style: TextStyle(
                    color: Color.fromARGB(255, 163, 184, 195),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                contentPadding: const EdgeInsets.all(20),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 400,
                    child: Table(
                      // ... (rest of the code remains the same)
                      children: [
                        TableRow(
                          children: [
                            const TableCell(
                                child: Text(
                              'Region:',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )),
                            TableCell(
                                child: Text(
                              region,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )),
                          ],
                        ),
                        TableRow(
                          children: [
                            const TableCell(
                                child: Text(
                              'District:',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )),
                            TableCell(
                                child: Text(
                              district ?? 'N/A',
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )), // Use 'N/A' as a default if district is null
                          ],
                        ),
                        TableRow(
                          children: [
                            const TableCell(
                                child: Text(
                              'Ward:',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )),
                            TableCell(
                                child: Text(
                              ward,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )),
                          ],
                        ),
                        TableRow(
                          children: [
                            const TableCell(
                                child: Text(
                              'Street:',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )),
                            TableCell(
                                child: Text(
                              location,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )),
                          ],
                        ),

                        TableRow(
                          children: [
                            const TableCell(
                                child: Text(
                              'Type:',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )),
                            TableCell(
                                child: Text(
                              type,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )),
                          ],
                        ),
                        if (showAdditionalFields)
                          TableRow(
                            children: [
                              const TableCell(
                                  child: Text(
                                'Umeme:',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                              TableCell(
                                  child: Text(
                                umeme ?? 'N/A',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                            ],
                          ),
                        if (showAdditionalFields)
                          TableRow(
                            children: [
                              const TableCell(
                                  child: Text(
                                'Maji:',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                              TableCell(
                                  child: Text(
                                maji ?? 'N/A',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                            ],
                          ),
                        if (showAdditionalFields)
                          TableRow(
                            children: [
                              const TableCell(
                                  child: Text(
                                'Toilet:',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                              TableCell(
                                  child: Text(
                                toilet ?? 'N/A',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                            ],
                          ),
                        if (showAdditionalFields)
                          TableRow(
                            children: [
                              const TableCell(
                                  child: Text(
                                'Board:',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                              TableCell(
                                  child: Text(
                                board ?? 'N/A',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                            ],
                          ),
                        if (showAdditionalFields)
                          TableRow(
                            children: [
                              const TableCell(
                                  child: Text(
                                'Tails:',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                              TableCell(
                                  child: Text(
                                tails ?? 'N/A',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                            ],
                          ),
                        if (showAdditionalFieldsLand)
                          TableRow(
                            children: [
                              const TableCell(
                                  child: Text(
                                'House No:',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                              TableCell(
                                  child: Text(
                                houseNumber ?? 'N/A',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                            ],
                          ),
                        if (showAdditionalFields)
                          TableRow(
                            children: [
                              const TableCell(
                                  child: Text(
                                'Located:',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                              TableCell(
                                  child: Text(
                                located ?? 'No Description',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                            ],
                          ),
                        if (showAdditionalFields)
                          TableRow(
                            children: [
                              const TableCell(
                                  child: Text(
                                'Kodi:',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                              TableCell(
                                  child: Text(
                                kodi ?? 'N/A',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 85, 146)),
                              )),
                            ],
                          ),

                        TableRow(
                          children: [
                            const TableCell(
                                child: Text(
                              'Price:',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )),
                            TableCell(
                                child: Text(
                              '$price Tsh/=',
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146)),
                            )),
                          ],
                        ),

                        TableRow(
                          children: [
                            const TableCell(
                              child: Text(
                                'Description:',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Text(
                                '${description[0].toUpperCase()}${description.substring(1)}',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 4, 85, 146),
                                ),
                              ),
                            ),
                          ],
                        )
                        // Add more rows for additional details
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 180, 180, 6),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.reverse(); // Trigger the fade-out animation
                    },
                    child: const Text(
                      'Hide',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
                backgroundColor: const Color.fromARGB(255, 244, 247, 249)
                    .withOpacity(
                        0.9), // Set the background color with transparency
                elevation: 10, // Increase the elevation (opacity)
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      body: Center(
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
                      style: const TextStyle(fontSize: 20, color: Colors.amber),
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
              width: 330,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageView.builder(
                  itemCount: imageURLs.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MoreImages(
                                  roomId: roomId,
                                  imageURLs: const [], // Pass additional details if needed
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            imageURLs[index],
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.asset('assets/post2.png',
                                  height: 300, width: 300);
                            },
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
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
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 35),
            Row(
              children: [
                const SizedBox(width: 28),
                Flexible(
                  flex: 2,
                  child: Text(
                    '${description[0].toUpperCase()}${description.substring(1)}',
                    style: const TextStyle(fontSize: 20, color: Colors.amber),
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  flex: 1,
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 20, color: Colors.amber),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      launch('tel:$phone');
                    },
                    child: Row(
                      children: [
                        const SizedBox(width: 50),
                        Text(
                          username.toUpperCase(),
                          style:
                              const TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'Call $phone',
                          style: const TextStyle(
                              color: Colors.blueGrey, fontSize: 20),
                        ),
                        const SizedBox(width: 15),
                        const Icon(
                          Icons.call,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            launch('sms:$phone');
                          },
                          child: const Icon(
                            Icons.message,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 300,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  _showMoreInfoModal(context);
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
                child: const Text(
                  'See More',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
