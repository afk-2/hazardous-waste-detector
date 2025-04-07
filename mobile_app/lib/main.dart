import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';

import 'result_screen.dart';

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
        scaffoldBackgroundColor: Colors.grey[100],
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
  tfl.Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  /// Load TFLite model from assets
  Future<void> _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset('assets/hazardous_classifier.tflite');
      print("TFLite model loaded successfully");
    } catch (e) {
      print("Failed to load model: $e");
      _interpreter = null; // Mark as null to prevent crashes
    }
  }


  /// Select an image from gallery
  Future<void> _pickImageFromGallery() async {
    var status = await Permission.photos.request();
    if (!status.isGranted) {
      // Fallback for older Android versions
      status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please grant photo/storage access permission")),
        );
        return;
      }
    }

    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
      _classifyAndNavigate(pickedImage.path);
    } else {
      print("No image selected");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image selected")),
      );
    }
  }

  /// Capture image using camera
  Future<void> _takePhoto() async {
    final XFile? takenPhoto = await _picker.pickImage(source: ImageSource.camera);
    if (takenPhoto != null) {
      setState(() {
        _image = takenPhoto;
      });
      _classifyAndNavigate(takenPhoto.path);  // Simulate result for now
    }
  }

  /// Navigate to result screen with prediction and confidence
  void _navigateToResultScreen(String result, String imagePath, double confidence) {
    if (_image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
              result: result,
              imagePath: imagePath,
              confidence: confidence
          ),
        ),
      );
    }
  }

  /// Run the model to classify the image
  Future<void> _classifyAndNavigate(String imagePath) async {
    if (_interpreter == null) {
      print("⚠️ Error: Interpreter is not initialized!");
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Model not loaded. Please restart the app."))
      );
      return;
    }

    // Show loading spinner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

    // Give time to render loading
     await Future.delayed(const Duration(milliseconds: 100));

    // Process and classify the image
    List<List<List<List<double>>>> input = await _processImage(imagePath);
    var inputTensor = input;

    // Create an output buffer for the result
    var outputTensor = List.filled(1, 0.0).reshape([1, 1]);

    // Run inference
    _interpreter!.run(inputTensor, outputTensor);

    double prediction = outputTensor[0][0]; // Model output
    String result = prediction > 0.5 ? "Non-Hazardous" : "Hazardous";
    double confidence = (prediction > 0.5 ? prediction : 1 - prediction) * 100;

    // Close the loading dialog
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
            result: result,
            imagePath: imagePath,
            confidence: confidence
        ),
      ),
    );
  }

  /// Preprocess the image for model input (resize, normalize)
  Future<List<List<List<List<double>>>>> _processImage(String imagePath) async {
  File imageFile = File(imagePath);
  Uint8List imageBytes = await imageFile.readAsBytes();
  img.Image? image = img.decodeImage(imageBytes);

  if (image == null) return [];

  // Resize to model input size (e.g., 224x224)
  img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

  // Normalize RGB values to 0-1
  List<List<List<double>>> inputImage = List.generate(224, (y) =>
    List.generate(224, (x) {
      var pixel = resizedImage.getPixel(x, y);
      return [
        img.getRed(pixel) / 255.0,
        img.getGreen(pixel) / 255.0,
        img.getBlue(pixel) / 255.0
      ];
    })
  );

  return [inputImage];
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png',
          height: 60,
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top section: title and optional preview
              Column(
                children: [
                  Text(
                    'Classify Waste as Hazardous or Non-Hazardous',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 75),

                  // Preview (or reserved space if none)
                  if (_image != null) ...[
                    Text(
                      'Preview:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_image!.path),
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ] else
                    SizedBox(height: 230), // Reserve space when there's no image
                ],
              ),

              // Bottom section: buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.camera_alt),
                      label: Text('Take a Photo'),
                      onPressed: _takePhoto,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.image),
                      label: Text('Upload a Photo'),
                      onPressed: _pickImageFromGallery,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
