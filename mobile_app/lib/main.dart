import 'package:flutter/material.dart';
import 'result_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';  // To handle image file

void main() {
  runApp(HazScanApp());
}

class HazScanApp extends StatelessWidget {
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

class HomeScreen extends StatelessWidget {
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
              onPressed: () {
                // Simulate classification
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(result: 'Hazardous'),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text('Upload a Photo'),
              onPressed: () {
                // Simulate classification
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(result: 'Non-Hazardous'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
