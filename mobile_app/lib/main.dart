import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
// import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
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

  Future<void> _loadModel() async {
    // Load the TFLite model from assets
    try {
      _interpreter = await tfl.Interpreter.fromAsset('assets/hazardous_classifier.tflite');
      print("TFLite model loaded successfully");
    } catch (e) {
      print("Failed to load model: $e");
      _interpreter = null; // Mark as null to prevent crashes
    }
  }


  // Method to pick image from the gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
      _classifyAndNavigate(filePath);  // Simulate result for now
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

  // Run the model for classification
  Future<void> _classifyAndNavigate(String imagePath) async {
    if (_interpreter == null) {
      print("⚠️ Error: Interpreter is not initialized!");
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Model not loaded. Please restart the app."))
      );
      return;
    }

    // Preprocess the image
    List<List<List<List<double>>>> input = await _processImage(imagePath);
    var inputTensor = input;

    // Create an output buffer for the result
    var outputTensor = List.filled(1, 0.0).reshape([1, 1]);

    // Run inference
    _interpreter!.run(inputTensor, outputTensor);

    // Get the result
    double prediction = outputTensor[0][0]; // Assuming 0 = Non-Hazardous, 1 = Hazardous
    String result = prediction > 0.5 ? "Non-Hazardous" : "Hazardous";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(result: result, imagePath: imagePath),
      ),
    );
  }

  // Process image for model
  Future<List<List<List<List<double>>>>> _processImage(String imagePath) async {
  File imageFile = File(imagePath);
  Uint8List imageBytes = await imageFile.readAsBytes();
  img.Image? image = img.decodeImage(imageBytes);

  if (image == null) return [];

  // Resize the image to 224x224 (Adjust this to match your model input size)
  img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

  // Normalize pixel values (0-1)
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
              onPressed: () async {
                final XFile? takenPhoto = await _picker.pickImage(source: ImageSource.camera);
                if (takenPhoto != null) {
                  _classifyAndNavigate(takenPhoto.path);
                }
              },
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text('Upload a Photo'),
              onPressed: () async {
                final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  _classifyAndNavigate(pickedImage.path);
                }
              },
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


