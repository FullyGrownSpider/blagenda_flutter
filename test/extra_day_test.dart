import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screens/default_buttons.dart';

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

///test weather the regex for days-long works when its supposed to
void main() {
  test('found time', _testFoundTime);
  test('delete time', _testShouldDelete);
}

void _testFoundTime() {
  var but = deadline();
  but.date = MyDateController.nowDate.addOrRemoveDays(4);
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

void _testShouldDelete() {
  var but = deadline();
  but.date = MyDateController.nowDate.addOrRemoveDays(10);
  but.toDos = inputTrue.keys.first;
  var contr = DeadlineController(but);
  contr.rebuild();
  expect(contr.requiresChange, false);
  but = deadline();
  but.date = MyDateController.nowDate.addOrRemoveDays(-8);
  but.toDos = inputTrue.keys.first;
  contr = DeadlineController(but);
  contr.rebuild();
  expect(contr.requiresChange, false);
  but = deadline();
  but.date = MyDateController.nowDate.addOrRemoveDays(-9);
  but.toDos = inputTrue.keys.first;
  contr = DeadlineController(but);
  contr.rebuild();
  expect(contr.requiresChange, true);
}

EndBasedController make<t extends BasicButton>(t button) {
  var controller = dataToController(button) as EndBasedController;
  return controller;
}
