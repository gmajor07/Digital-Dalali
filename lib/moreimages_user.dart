import 'package:digital_dalali/room.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoreImages extends StatefulWidget {
  final String roomId;
  final List<String> imageURLs; // Add the imageURLs list here

  const MoreImages({super.key, required this.roomId, required this.imageURLs});

  @override
  _MoreImagesState createState() => _MoreImagesState();
}

class _MoreImagesState extends State<MoreImages> {
  List<String> imageURLs = [];
// Initialize the ImagePicker

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(26.0),
            child: Text(
              'Photos Collection User', // Your label text
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber),
            ),
          ),
          Expanded(
            child: Visibility(
              visible: imageURLs.isNotEmpty,
              replacement: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 200,
                    ),
                    Image.asset('assets/post2.png',
                        width: 200,
                        height: 200), // Adjust the width and height as needed
                    const Text(
                      'Sorry no more images available!.',
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              child: ListView.builder(
                itemCount: imageURLs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
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
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.asset('assets/post2.png');
                            },
                          ),
                        ),
                      ),
                    ),
                  );
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
          // Update imageURLs with the updated list if it's not null (i.e., the user added new images)
          if (updatedImageURLs != null) {
            setState(() {
              imageURLs = updatedImageURLs;
            });
          }
        },
        backgroundColor: Colors.yellow, // Set the background color to yellow
        child: const Icon(Icons.backspace,
            color:
                Colors.black), // You can also change the icon color if needed
      ),
    );
  }
}

class ImageSwiper extends StatefulWidget {
  final List<String> imageURLs; // Change the data type to List<String>
  final int initialPage;

  const ImageSwiper({Key? key, required this.imageURLs, this.initialPage = 0})
      : super(key: key);

  @override
  _ImageSwiperState createState() => _ImageSwiperState();
}

class _ImageSwiperState extends State<ImageSwiper> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageURLs.length,
        itemBuilder: (context, index) {
          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.imageURLs[index],
                width: 400, // Adjust the width as needed
                height: 700, // Adjust the height as needed
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Image.asset('assets/post2.png',
                      height: 300, width: 300);
                },
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
