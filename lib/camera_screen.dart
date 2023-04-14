import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _availableCameras;
  late Timer _timer;
  int _secondsLeft = 20;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _initializeCamera() async {
    _availableCameras = await availableCameras();
    _cameraController = CameraController(_availableCameras[0], ResolutionPreset.high);
    await _cameraController.initialize();
    setState(() {});
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (timer) => setState(() {
        if (_secondsLeft < 1) {
          timer.cancel();
          _processVideo();
        } else {
          _secondsLeft--;
        }
      }),
    );
  }

  Future<void> _processVideo() async {
    final String videoPath = '${(await getTemporaryDirectory()).path}/video.mp4';
    await _cameraController.stopVideoRecording();
    final File videoFile = File(videoPath);
    final bytes = await videoFile.readAsBytes();
    final response = await http.post(
      'https://yourbackendurl.com/process-video' as Uri,
      headers: {'Content-Type': 'application/octet-stream'},
      body: bytes,
    );
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: 'Recording Complete',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pop(context);
    }
  }

  void _startRecording() async {
    _startTimer();
    final String videoPath = '${(await getTemporaryDirectory()).path}/video.mp4';
    await _cameraController.startVideoRecording();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController.value.isInitialized) {
      return Container();
    }

    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$_secondsLeft seconds left',
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
          SizedBox(height: 16),
          IconButton(
            icon: Icon(Icons.videocam, size: 64, color: Colors.white),
            onPressed: _startRecording,
          ),
        ],
      ),
    );
  }
}
