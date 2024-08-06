import 'package:digital_dalali/profile.dart';
import 'package:digital_dalali/search.dart';
import 'package:digital_dalali/upload.dart';
import 'package:digital_dalali/view_post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_page.dart';
import 'login.dart';

class DetailPage extends StatefulWidget {
  final String roomId;
  final List<String> imageURLs; // Add the imageURLs list here

  const DetailPage({super.key, required this.roomId, required this.imageURLs});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<String> imageURLs = [];
  String? description = ''; // Initialize with empty value
  String? district = '';

  @override
  void initState() {
    super.initState();
    _fetchRoomImages();
  }

  Future<void> _fetchRoomImages() async {
    try {
      final roomDocument = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .get();
      if (roomDocument.exists) {
        final data = roomDocument.data();
        if (data != null && data.containsKey('imageURLs')) {
          setState(() {
            imageURLs = List<String>.from(data['imageURLs']);
          });
        } else {
          setState(() {
            imageURLs = [];
          });
        }
      } else {
        setState(() {
          imageURLs = [];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching room images: $e');
      }
      setState(() {
        imageURLs = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 195, 13),
        title: const Text(
          'Photos Collection Owner ',
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
      body: imageURLs.isEmpty
          ? Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  Image.asset('assets/post2.png',
                      width: 200,
                      height: 200), // Adjust the width and height as needed
                  const Text(
                    'Sorry, no more images available!',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: imageURLs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageSwiper(
                            imageURLs: imageURLs,
                            initialPage: index,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageURLs[index],
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          if (exception is NetworkImageLoadException) {
                            return Image.asset(
                              'assets/post2.png', // Replace 'assets/placeholder.png' with your placeholder image path
                              width: 50,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          } else {
                            return Image.asset(
                              'assets/error2.png', // Optionally, display a different image for other types of errors
                              width: 50,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedImageURLs = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  EditPage(roomId:widget.roomId , imageURLs: const [],

              ),
            ),
          );
        },
        backgroundColor: Colors.yellow, // Set the background color to yellow
        child: const Icon(Icons.add_a_photo_rounded,
            color:
                Colors.black), // You can also change the icon color if needed
      ),
    );
  }
}

class ImageSwiper extends StatefulWidget {
  final List<String> imageURLs;
  final int initialPage;

  const ImageSwiper({Key? key, required this.imageURLs, this.initialPage = 0})
      : super(key: key);
  @override
  _ImageSwiperState createState() => _ImageSwiperState();
}

class _ImageSwiperState extends State<ImageSwiper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 195, 13),
        title: const Text(
          'Photos Collection to',
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
      body: ListView.builder(
        itemCount: widget.imageURLs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Image.network(widget.imageURLs[index]),
          );
        },
      ),
      // Other widgets in your Scaffold
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          MaterialPageRoute(
            builder: (context) => const ViewPostPage(),
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
