import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, int> inputTrue = {
  '5 days': 5,
  '50 long': 50,
  'lasts 90': 90,
  'arostpne': 1,
  '10d': 10,
  'd10': 10,
  'lasts 10 days': 10,
  '10 dagen': 10,
  'duurt 10 dagen': 10,
};

void main() {
  test('found time', tesFoundTime);
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
    expect(contr.extraDays, inputTrue[key]);
    expect(contr.timeOfDay, -1);
    expect(contr.timeOfDayEnd, -1);
  }
}
