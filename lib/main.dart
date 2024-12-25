import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraHomePage(),
    );
  }
}

class CameraHomePage extends StatefulWidget {
  @override
  _CameraHomePageState createState() => _CameraHomePageState();
}

class _CameraHomePageState extends State<CameraHomePage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImagePath = image.path;
      });
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  @override
  Widget build(BuildContext context, dynamic colors) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Camera Integration'),
          backgroundColor: Colors.teal,
        ),
        body: Column(
          children: [
            if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              )
            else
              Center(child: CircularProgressIndicator()),
            Expanded(
              child: Center(
                child: _capturedImagePath == null
                    ? Text('No image captured yet.')
                    : DisplayImage(imagePath: _capturedImagePath),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _captureImage,
          child: Icon(Icons.camera_alt),
          backgroundColor: colors.blue,
        ));
  }
}

class DisplayImage extends StatelessWidget {
  final String? imagePath;

  const DisplayImage({Key? key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: imagePath == null
          ? Text("No image selected")
          : kIsWeb
              ? Text(
                  "Image.file is not supported on the Web",
                  style: TextStyle(color: Colors.red),
                )
              : Image.file(File(imagePath!)),
    );
  }
}
