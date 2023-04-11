import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test_jitsi/APIManager/api_manager.dart';
import 'package:test_jitsi/home_page.dart';
import 'package:test_jitsi/main.dart';
import 'package:tflite/tflite.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  LessonPageState createState() => LessonPageState();
}

class LessonPageState extends State<LessonPage> {
  late CameraController cameraController;
  late CameraImage cameraImage;
  late Timer timer;
  late List recognitionsList;
  String output = '';
  bool showCamera = false;

  initCamera() {
    cameraController = CameraController(cameras[1], ResolutionPreset.medium);
    cameraController.initialize().then((value) {
      setState(() {
        cameraController.startImageStream((image) => {
              cameraImage = image,
              runModel(),
            });
      });
    });
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _addRecord());
  }

  runModel() async {
    var prediction = await Tflite.runModelOnFrame(
      bytesList: cameraImage.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: cameraImage.height,
      imageWidth: cameraImage.width,
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90,
      numResults: 1,
      threshold: 0.4,
      asynch: true,
    );
    prediction?.forEach((element) {
      setState(() {
        output = element['label'];
        // print(output);
      });
    });
    showCamera = true;
  }

  _addRecord() {
    if (output == 'Happy' || output == 'Neutral') {
      recognitionsList.add(2);
    } else {
      recognitionsList.add(1);
    }
    print(recognitionsList);
  }

  Future loadModel() async {
    Tflite.close();
    await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/label.txt");
  }

  _leave() {
    String path = '/report/add_record';
    Map<String, dynamic> params = {
      'member_id': member_id,
      'lesson_id': lesson_id,
      'level': recognitionsList,
    };
    ApiManager.instance.post(path, params).then((response) async {
      timer.cancel();
      Tflite.close();
      if (mounted) {
        print(response);
        Map<String, dynamic> data = response;
        if (data['status'] == 1) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const HomePage(),
              ),
            );
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    recognitionsList = [];
    loadModel();
    initCamera();
  }

  @override
  void dispose() {
    super.dispose();

    timer.cancel();
    Tflite.close();
    cameraController.stopImageStream();
  }

  @override
  Widget build(BuildContext context) {
    if (!showCamera) return const Scaffold();

    var camera = cameraController.value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * camera.aspectRatio;

    if (scale < 1) scale = 1 / scale;

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Stack(
            children: [
              SizedBox(
                child: Transform.scale(
                  scale: scale,
                  child: Center(
                    child: CameraPreview(cameraController),
                  ),
                ),
              ),
              Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: (output == 'Happy' || output == 'Neutral')
                      ? ClipOval(
                          child: Container(
                          color: Colors.green,
                          height: 20.0,
                          width: 20.0,
                        ))
                      : ClipOval(
                          child: Container(
                          color: Colors.red,
                          height: 20.0,
                          width: 20.0,
                        ))),
              Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: ElevatedButton(
                    onPressed: () => _leave(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Leave',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
