import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> inputFalse = [
  ' amsterdam',
  '02 02 asdofj',
  ' uur',
  '20.20KK',
  '22e',
  '20 pmed',
  '20.90',
  '19.00am',
  '21 00',
  '20',
  '2000',
  '20 000'
];
Map<String, int> inputTrue = {
  '5am': 300,
  '9am': 540,
  '3.00': 900,
  '18.00pm': 1080,
  '18pm': 1080,
  '9.00pm': 1260,
  '9pm': 1260,
  '21.00 how are you doing': 1260,
  'how are you doing 21.00': 1260,
  'how is 21.00 doing': 1260,
  '21.01': 1261,
};

void main() {
  test('found time', tesFoundTime);
  test('not found time', tesNotFoundTime);
}

void tesFoundTime() {
  var but = Deadline();
  but.date = MyDateController.nowDate.addOrRemoveDays(4);
  but.job = '';
  but.id = 1;
  but.color = Colors.black;
  for (var key in inputTrue.keys) {
    but.toDos = key;
    var contr = DeadlineController(but);
    contr.rebuild();
    // print(key);
    expect(inputTrue[key], contr.timeOfDay);
  }
}

void tesNotFoundTime() {
  var but = Deadline();
  but.date = MyDateController.nowDate.addOrRemoveDays(4);
  but.job = '';
  but.id = 1;
  but.color = Colors.black;
  for (var item in inputFalse) {
    but.toDos = item;
    var contr = DeadlineController(but);
    contr.rebuild();
    // print(item);
    expect(-1, contr.timeOfDay);
  }
}
