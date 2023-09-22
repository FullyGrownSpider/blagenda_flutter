import 'dart:async';
import 'dart:io';

import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Commons/Models/Buttons/deadline.dart';
import '../Screens/adding_screen.dart';
import 'ScreensControllers/common_screen_controller.dart';
import 'dart:math';

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

  MyDateController dateInfo = MyDateController.today;

  String timeInfo = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // defines a timer
    Timer.periodic(const Duration(seconds: 2), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      _timerTick();
    });
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
                              onPressed: makeButton,
                              child: Text(getDataString(),
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

    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);
      var time = findTimeTextInText(recognizedText.text);
      bool set = false;
      if (time.isNotEmpty) {
        timeInfo = time;
        set = true;
      }
      var date = createDateFromText(recognizedText.text);
      if (date != null) {
        dateInfo = date;
        set = true;
      }
      if (set) setState(() {});
    } catch (e) {
      //eh whatever, something went wrong
    }
  }

  DeadlineController createButton() {
    return DeadlineController(
        Deadline('', [timeInfo], -1, usedColors.first, dateInfo, ''));
  }

  void _timerTick() {
    _scanImage();
  }

  String getDataString() {
    String dateText;
    if (dateInfo != MyDateController.today) {
      dateText =
          '${MyDateController.months[dateInfo.month - 1]} ${dateInfo.day}';
    } else {
      dateText = "???";
    }
    return 'D:$dateText\nT:$timeInfo';
  }

  Future<void> makeButton() async {
    final navigator = Navigator.of(context);

    await navigator
        .push(
          MaterialPageRoute(
            builder: (BuildContext context) => AddingScreen(
                createButton(), widget.addingFunction, widget.getNewId),
          ),
        )
        .then((value) => Navigator.pop(context));
  }
}

final RegExp _numericFilter = RegExp(r'[^0-9][0-9]{1,2}[^0-9]');
final RegExp _numeric = RegExp(r'[0-9]{1,2}');
final RegExp _numericNotSafe = RegExp(r'[!.,]');
final RegExp _numericDateMaybeYear =
    RegExp(r'[0-9]{1,4}-[0-9]{1,4}(-[0-9]{1,4})?');

final RegExp _timeReg = RegExp(
    r'( |\b)[0-9]{1,2}:[0-9]{0,2}([a,p]m)? ?-? ?[0-9]{1,2}:[0-9]{0,2}([a,p]m)?');
final RegExp _secondTimeReg = RegExp(r'( |\b)[0-9]{1,2}:[0-9]{2}([a,p]m)?');
final RegExp _timeRegOp =
    RegExp(r'( |\b)[0-9]{1,2}([a,p]m) ?-? ?[0-9]{1,2}([a,p]m)');
final RegExp _secondTimeRegOp = RegExp(r'( |\b)[0-9]{1,2}:[0-9]{2}([a,p]m)?');

String findTimeTextInText(String text) {
  var dayText = _timeReg.firstMatch(text)?[0].toString();
  dayText ??= _secondTimeReg.firstMatch(text)?[0].toString();
  dayText = _timeRegOp.firstMatch(text)?[0].toString();
  dayText ??= _secondTimeRegOp.firstMatch(text)?[0].toString();
  dayText ??= '';
  return dayText;
}

MyDateController? createDateFromText(String text) {
  text = text.toLowerCase();
//august 10
  MyDateController? result = _monthNameToDate(
      text, MyDateController.monthsENFull, MyDateController.monthsNLFull);
//aug 10
  result ??= _monthNameToDate(
      text, MyDateController.months, MyDateController.monthsNL);

//08-10-2020 || 08-10
  if (result == null) {
    var awns = _numericDateMaybeYear.firstMatch(text);
    if (awns == null) return null;
    List<String> newAwns = awns[0]!.split('-');
    List<int> newAwnsInt = newAwns.map((e) => int.parse(e)).toList();
    if (newAwns.where((e) => e.length == 4).length > 1) return null;
    if (newAwns.any((e) => e.length == 3)) return null;
    int year = -1, month, day;
    if (newAwns.length == 3) {
      var yearIndex = newAwns.indexWhere((e) => e.length == 4);
      if (yearIndex == -1) {
        yearIndex = newAwnsInt.indexWhere((e) =>
            e == MyDateController.today.year % 100 ||
            e == (MyDateController.today.year + 1) % 100);
      }
      if (yearIndex == -1) {
        month = newAwnsInt[0];
        day = newAwnsInt[1];
      } else {
        year = newAwnsInt[yearIndex];
        month = newAwnsInt[1];
        day = newAwnsInt[2 - yearIndex];
      }
    } else {
      month = newAwnsInt[0];
      day = newAwnsInt[1];
    }
    if (month > 12) {
      int bak = month;
      month = day;
      day = bak;
    }
    if (year == -1) {
      year = MyDateController.today.year;
    }
    result = MyDateController(year, month, day);
    if (result.isBefore(MyDateController.today)) {
      result = MyDateController(year + 1, month, day);
    }
  }
  return result;
}

MyDateController? _monthNameToDate(
    String text, List<String> monthsEN, List<String> monthsNL) {
  for (int i = 0; i < monthsEN.length; i++) {
    if (text.contains(monthsEN[i]) || text.contains(monthsNL[i])) {
      String newText = monthsEN[i].substring(0, 3);

      int index = text.indexOf(monthsEN[i]);
      int length = monthsEN[i].length;
      if (index == -1) {
        index = text.indexOf(monthsNL[i]);
        length = monthsNL[i].length;
      }
      var subBefore = text.substring(max(index - 6, 0), index);
      RegExpMatch? found;
      if (!subBefore.substring(3, subBefore.length).contains(_numericNotSafe)) {
        found = _numericFilter.firstMatch(subBefore);
      }
      found ??= _numericFilter.firstMatch(
          text.substring(index + length, min(index + length + 4, text.length)));
      if (found != null) {
        var awns = _numeric.firstMatch(found[0].toString());
        int? numb = int.tryParse(awns![0].toString());
        if (numb != null) {
          return MyDateController.translate('$newText $numb')!;
        }
      }
    }
  }
  return null;
}
