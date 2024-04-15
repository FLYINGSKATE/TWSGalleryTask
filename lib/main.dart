import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TWS Gallery - Task',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageGallery(),
    );
  }
}

class ImageGallery extends StatefulWidget {
  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<dynamic> _images = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    final response = await http.get(Uri.parse('https://pixabay.com/api/?key=43404826-91d2d82a0b771dee209ef8ca4&image_type=photo'));
    if (response.statusCode == 200) {
      setState(() {
        _images = json.decode(response.body)['hits'];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TWS Gallery - Task'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _calculateCrossAxisCount(context),
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImage(imageUrl: _images[index]['largeImageURL']),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    _images[index]['previewURL'],
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.thumb_up_off_alt_sharp),

                      Text('${_images[index]['likes']}'),
                      SizedBox(width: 20,),
                      Icon(Icons.remove_red_eye),

                      Text('${_images[index]['views']}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cellWidth = 150.0;
    final count = screenWidth / cellWidth;
    return count.floor();
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
