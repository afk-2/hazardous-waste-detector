import 'package:flutter/material.dart';
import 'result_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';  // To handle image file

void main() {
  runApp(HazScanApp());
}

class HazScanApp extends StatelessWidget {
  const HazScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HazScan AI',
      theme: ThemeData(
        primarySwatch: Colors.green, // Main color theme
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); 

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;  // Variable to store the picked image

  // Method to pick image from the gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
      _navigateToResultScreen('Non-Hazardous');  // Simulate result for now
    }
  }

  // Method to take a photo using the camera
  Future<void> _takePhoto() async {
    final XFile? takenPhoto = await _picker.pickImage(source: ImageSource.camera);
    if (takenPhoto != null) {
      setState(() {
        _image = takenPhoto;
      });
      _navigateToResultScreen('Hazardous');  // Simulate result for now
    }
  }

  // Navigate to the ResultScreen
  void _navigateToResultScreen(String result) {
    if (_image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: result, imagePath: _image!.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HazScan AI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Classify Waste as Hazardous or Non-Hazardous',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Take a Photo'),
              onPressed: _takePhoto,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text('Upload a Photo'),
              onPressed: _pickImageFromGallery,
            ),
            if (_image != null) ...[
              SizedBox(height: 20),
              Image.file(File(_image!.path), height: 100, width: 100),  // Display selected image
            ]
          ],
        ),
      ),
    );
  }
}
