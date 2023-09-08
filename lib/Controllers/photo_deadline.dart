import 'dart:io';

import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Screens/adding_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Commons/Models/Buttons/deadline.dart';
import 'ScreensControllers/common_screen_controller.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen(this.addingFunction, this.getNewId, {super.key});

  final Function(BasicButtonController) addingFunction;
  final int Function(Type) getNewId;

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;

  late final Future<void> _future;
  CameraController? _cameraController;

  final textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _initCameraController(snapshot.data!);

                    return Center(child: CameraPreview(_cameraController!));
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            Scaffold(
              appBar: AppBar(
                title: const Text('Take Photo'),
              ),
              backgroundColor: _isPermissionGranted ? Colors.transparent : null,
              body: _isPermissionGranted
                  ? Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _scanImage,
                              child: const Text('Scan text',
                                  style: normalTextStyle,
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                        child: const Text(
                          'Camera permission denied',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var desc in cameras) {
      final CameraDescription current = desc;
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;

    final navigator = Navigator.of(context);

    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      await navigator
          .push(
            MaterialPageRoute(
              builder: (BuildContext context) => AddingScreen(
                  createButton(recognizedText.text),
                  widget.addingFunction,
                  widget.getNewId),
            ),
          )
          .then((value) => Navigator.pop(context));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }

  DeadlineController createButton(String text) {
    return DeadlineController(Deadline('Appointment', [_createTime(text)], -1,
        usedColors.first, _createDate(text), '')); //TODO
  }

  final RegExp _dayReg = RegExp(r' [0-9]{1,2}[a-z]+\b');
  final RegExp _secondDayReg = RegExp(r'[0-9]{1,2} [A-z][a-z]{2}\b');
  final RegExp _thirdDayReg = RegExp(r'[A-z][a-z]{2-12} [0-9]{1,2}\b');
  final RegExp _timeReg = RegExp(
      r'( |\b)[0-9]{1,2}:[0-9]{2}([a,p]m)? ?-? ?[0-9]{1,2}:[0-9]{2}([a,p]m)?');
  final RegExp _secondTimeReg = RegExp(
      r'( |\b)[0-9]{1,2}:[0-9]{2}([a,p]m)?');
  final RegExp _firstDateReg = RegExp(r'[A-Z][a-z]{2} [0-9]');
  final RegExp _secondDateReg = RegExp(r'[0-9] [A-Z][a-z]{2}');

  String _createTime(String text) {
    var dayText = _timeReg.firstMatch(text)?[0].toString();
    dayText ??= _secondTimeReg.firstMatch(text)?[0].toString();
    dayText ??= '';
    return dayText;
  }

  MyDateController _createDate(String text) {
    var dayText = _dayReg.firstMatch(text)?[0].toString();
    dayText ??= _secondDayReg.firstMatch(text)?[0].toString();
    dayText ??= _thirdDayReg.firstMatch(text)?[0].toString();
    if (dayText == null) return MyDateController.today;
    var day = int.tryParse(dayText.replaceAll(RegExp("[a-zA-Z]"), ""));
    if (day == null || day > 32) return MyDateController.today;
    for (int i = 0; i < 12; i++) {
      var calc = _firstDateReg.firstMatch(text)?[0].toString();
      if (calc == null) continue;
      calc = _secondDateReg.firstMatch(text)?[0].toString();
      if (calc == null) continue;
      if (calc.contains(MyDateController.months[i]) ||
          calc.contains(MyDateController.monthsNL[i])) {
        var d = MyDateController(MyDateController.nowDate.year, i + 1, day);
        if (d.isBefore(MyDateController.today)) {
          d = MyDateController(MyDateController.nowDate.year + 1, i + 1, day);
        }
        return d;
      }
    }
    return MyDateController.today;
  }
}
