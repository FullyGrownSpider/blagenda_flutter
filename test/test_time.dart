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
  '21 00',
  '20',
  '2000',
  '20 000',
  'pm me the d00t'
];
Map<String, int> inputTrue = {
  '5am': 300,
  '9am': 540,
  '3.00': 900,
  '18.00pm': 1080,
  '18.00am': 1080,
  '18pm': 1080,
  '9.00pm': 1260,
  '9pm': 1260,
  '21.00 how are you doing': 1260,
  'how are you doing 21.00': 1260,
  'how is 21.00 doing': 1260,
  '21.01': 1261,
  '5am amsterdam': 300,
  '9am 02 02 asdofj': 540,
  '3.00 uur': 900,
  '18.00pm 22e': 1080,
  '18.00am 20 pmed': 1080,
  '18pm 20': 1080,
  '9.00pm 2000': 1260,
  '9pm arstinearst': 1260,
  '21.00 how are you doing 1999': 1260,
  'how are you doing 21.00 29.00': 1260,
};

Map<String, List<int>> inputTrueTrue = {
  '5am 6am': [300, 360],
  '9am t 8am': [480, 540],
  '3.00-4am ': [240, 900],
  '18.00pm-18.00pm': [1080, 1080],
  '18.00 tot 18.10': [1080, 1090],
};

void main() {
  test('found time', tesFoundTime);
  test('not found time', tesNotFoundTime);
  test('doubleFound', testDoubleFound);
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
    expect(contr.timeOfDay, inputTrue[key]);
    expect(contr.timeOfDayEnd, -1);
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
    expect(contr.timeOfDay, -1);
  }
}

void testDoubleFound() {
  var but = Deadline();
  but.date = MyDateController.nowDate.addOrRemoveDays(4);
  but.job = '';
  but.id = 1;
  but.color = Colors.black;
  for (var key in inputTrueTrue.keys) {
    but.toDos = key;
    var contr = DeadlineController(but);
    contr.rebuild();
    // print(key);
    expect(contr.timeOfDay, inputTrueTrue[key]?.first);
    expect(contr.timeOfDayEnd, inputTrueTrue[key]?.last);
  }
}
