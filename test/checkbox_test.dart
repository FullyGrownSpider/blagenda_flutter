import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screens/default_buttons.dart';

///test whether the MyDateController.translate works with all input it should work with
void main() {
  test('test checkbox on note', _testNote);
  test('test checkboxes on again', _testAgain);
  test('test checkbox on note job', _testNoteJob);
  test('test checkboxes on again job', _testAgainJob);
}

void _testAgainJob() {
  AgainWeekController but = AgainWeekController(week());
  but.button.toDos =
  'wowowowowow\nnonononon\nwawaweewa\n[]like whaaat?\n[]wwaaawww?\narstoien[][][]';
  but.button.dates = {};
  var x = but.gettingTheStringShort();
  expect(x.contains(BasicButtonController.emptyCheck), true);

  but.checkSwitchLine(3, false);
  but.checkSwitchLine(4, false);
  x = but.gettingTheStringShort();
  expect(x.contains(BasicButtonController.emptyCheck), true);

  but.checkSwitchLine(3, true);
  but.checkSwitchLine(4, true);
  x = but.gettingTheStringShort();
  expect(x.contains(BasicButtonController.check), true);

  but.checkSwitchLine(3, true);
  but.checkSwitchLine(4, false);
  x = but.gettingTheStringShort();
  expect(x.contains(BasicButtonController.halfCheck), true);


  var nextBut = but.createNew(7);
  x = nextBut.gettingTheStringShort();
  expect(x.contains(BasicButtonController.emptyCheck), true);
  x = but.gettingTheStringShort();
  expect(x.contains(BasicButtonController.halfCheck), true);

  nextBut.checkSwitchLine(3, true);
  nextBut.checkSwitchLine(4, false);
  x = nextBut.gettingTheStringShort();
  expect(x.contains(BasicButtonController.halfCheck), true);
}

void _testAgain() {
  //1 today
  AgainWeekController but = AgainWeekController(week());
  but.button.toDos =
      'wowowowowow\nnonononon\nwawaweewa\n[]like whaaat?\n[]wwaaawww?\narstoien[][][]';
  but.button.dates = {MyDateController.nowDate:[0]};
  var x = but.gettingTheStringSelected();
  expect(x.split(BasicButtonController.emptyCheck).length, 2);
  expect(x.split(BasicButtonController.check).length, 2);

  //2 week from now
  var nextBut = but.createNew(7);
  x = nextBut.gettingTheStringSelected();
  expect(x.split(BasicButtonController.emptyCheck).length, 4);
  expect(x.split(BasicButtonController.check).length, 1);
}

void _testNoteJob() {
  BasicButtonController but = NoteController(BasicButton('job',
      'wowowowowow\nnonononon\nwawaweewa\n[]like whaaat?\n[x]wwaaawww?\narstoien[][][]'));
  var x = but.gettingTheStringShort();
  expect(x.contains(BasicButtonController.halfCheck), true);
  but.button.toDos = but.button.toDos!.replaceAll('\n[]', '\n[x]');
  x = but.gettingTheStringShort();
  expect(x.contains(BasicButtonController.check), true);
  but.checkSwitchLine(3, false);
  but.checkSwitchLine(4, false);

  x = but.gettingTheStringShort();
  expect(x.contains(BasicButtonController.emptyCheck), true);
  but.checkSwitchLine(3, true);
  but.checkSwitchLine(4, false);

  x = but.gettingTheStringShort();
  expect(x.contains(BasicButtonController.halfCheck), true);
}

void _testNote() {
  BasicButtonController but = NoteController(BasicButton('job',
      'wowowowowow\nnonononon\nwawaweewa\n[]like whaaat?\n[x]wwaaawww?\narstoien[][][]'));
  var x = but.gettingTheStringSelected();
  expect(x.split(BasicButtonController.emptyCheck).length, 2);
  expect(x.split(BasicButtonController.check).length, 2);
}
