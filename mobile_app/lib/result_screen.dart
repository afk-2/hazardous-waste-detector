import 'package:flutter/material.dart';
import 'dart:io';

class ResultScreen extends StatelessWidget {
  final String result;
  final String imagePath;

  const ResultScreen({super.key, required this.result, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Classification Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Result:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              result,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: result == 'Hazardous' ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Image.file(
              File(imagePath),
              height: 200,
              width: 200,
            ),  // Display the image
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
