import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabetic Retinopathy Classifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: TFLitePage(),
    );
  }
}

class TFLitePage extends StatefulWidget {
  const TFLitePage({Key? key}) : super(key: key);

  @override
  _TFLitePageState createState() => _TFLitePageState();
}

class _TFLitePageState extends State<TFLitePage> {
  bool _loading = true;
  late File _image;
  List? _output;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/efficientnetb0.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
    );
    setState(() {
      _output = output;
      _loading = false;
    });
  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
      _loading = true;
    });
    detectImage(_image);
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
      _loading = true;
    });
    detectImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('Diabetic Retinopathy Classifier'),
      ),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : _output != null && _output!.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.file(_image),
                      SizedBox(height: 20),
                      Text(
                        'Predicted Stage: ${_output![0]['label']}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  )
                : Text('No prediction available'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: pickImage,
            tooltip: 'Take Picture',
            child: Icon(Icons.camera_alt),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: pickGalleryImage,
            tooltip: 'Select Picture',
            child: Icon(Icons.image),
          ),
        ],
      ),
    );
  }
}
