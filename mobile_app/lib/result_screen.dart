import 'package:flutter/material.dart';
import 'dart:io';

class ResultScreen extends StatelessWidget {
  // Class variables to store the result, image path, and confidence level
  final String result;
  final String imagePath;
  final double confidence;

  // Constructor to receive the parameters
  const ResultScreen({
    super.key,
    required this.result,
    required this.imagePath,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the result is hazardous (for conditional styling)
    bool isHazardous = result == "Hazardous";

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png',
          height: 60,
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the classification result with color change based on hazard status
            Text(
              'Result:',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isHazardous ? Colors.red : Colors.green, // Red for hazardous, green for non-hazardous
              ),
            ),
            const SizedBox(height: 20),

            // Display the confidence percentage
            Text(
              "Confidence: ${confidence.toStringAsFixed(1)}%",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Display the image with a rounded border
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imagePath),
                height: 250,
                width: 250,
                fit: BoxFit.cover,
              ),
            ),  // Display the image
            const SizedBox(height: 20),

            // Display a message based on the classification result
            Text(
              isHazardous
                  ? "⚠️ This waste is hazardous! Handle with care."
                  : "✅ This waste is non-hazardous.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Button to try again, going back to the home screen
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text("Try Again"),
              onPressed: () {
                Navigator.pop(context); // Pop the current screen (go back to home screen)
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        )
      ),
    );
  }
}
