import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/weird_again.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/weird_again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/adding_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/blagenda_uniform_button.dart';
import 'package:blagenda_flutter_simple/Controllers/color_buttons.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'overview4test.dart';

///test both searching and the adding_screen
void main() {
  test('buttons testing', _addButtons);
  test('buttons switch', _switchButtonType);
}

void _addButtons() {
  BasicButtonController b1 = makeController(note(1).button).getButton()!;
  expect(BasicButtonController.equals(b1.button, note(1).button), true);

  b1 = makeController(dead(1).button).getButton()!;
  expect(BasicButtonController.equals(b1.button, dead(1).button), true);

  b1 = makeController(week(1).button).getButton()!;
  expect(BasicButtonController.equals(b1.button, week(1).button), true);

  b1 = makeController(weird(1).button).getButton()!;
  expect(BasicButtonController.equals(b1.button, weird(1).button), true);

  b1 = makeController(year(1).button).getButton()!;
  expect(BasicButtonController.equals(b1.button, year(1).button), true);

  b1 = makeController(month(1).button).getButton()!;
  expect(BasicButtonController.equals(b1.button, month(1).button), true);

  b1 = makeController(amount(1).button).getButton()!;
  expect(BasicButtonController.equals(b1.button, amount(1).button), true);
}

AddingScreenController makeController(BasicButton but) {
  final FakeEntityNotifier entityNotifier = FakeEntityNotifier();
  final FakeButtonNotifier notifier = FakeButtonNotifier(entityNotifier);
  return AddingScreenController(but, notifier, true);
}

void goToNote(AddingScreenController controller) {
  controller.buttonType.value = BasicButton;
  controller.switchButtonType(controller.buttonType.value);
}

NoteController note(int numb) => NoteController(
    BasicButton("job$numb", "asfd\nasdf\nhaha\n", numb, usedColors.first));

DeadlineController dead(int numb) => DeadlineController(Deadline("job$numb",
    "asfd\nasdf\nhaha\n", numb, usedColors.first, MyDateController.today));

AgainWeirdController weird(int numb) => AgainWeirdController(AgainWeird(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    15,
    null,
    MyDateController.today.addOrRemoveDays(100),
    MyDateController.today.addOrRemoveDays(10)));

AgainYearController year(int numb) => AgainYearController(AgainYearDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    MyDateController.today.day,
    MyDateController.today.month));

AgainWeekController week(int numb) => AgainWeekController(AgainWeekDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    3,
    null,
    MyDateController.today.addOrRemoveDays(100),
    MyDateController.today.addOrRemoveDays(10)));

AgainAmountController amount(int numb) => AgainAmountController(AgainAmountDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    MyDateController.today.addOrRemoveDays(20),
    15,
    null,
    MyDateController.today.addOrRemoveDays(10)));

AgainMonthController month(int numb) => AgainMonthController(AgainMonthDay(
    "job$numb",
    "asfd\nasdf\nhaha\n",
    numb,
    usedColors.first,
    15,
    null,
    MyDateController.today.addOrRemoveDays(100),
    MyDateController.today.addOrRemoveDays(10)));

void _switchButtonType() {
  final FakeEntityNotifier entityNotifier = FakeEntityNotifier();
  final FakeButtonNotifier notifier = FakeButtonNotifier(entityNotifier);
  var controller = AddingScreenController(null, notifier, true);
  List<Widget> data = [];
  List<String?> listo = [];
  doListo(listo, data, controller);
  expect(data.any((e) => e is ColorButtons), true);
  expect(data.any((e) => e is SelectorShow), true);
  count('', 2, listo);
  checkingCheck([
    PossibleValues.job,
    PossibleValues.todo,
    PossibleValues.col,
    PossibleValues.imp
  ], controller.widgetsOnScreen.keys.toList());

  controller.buttonType.value = Deadline;
  doListo(listo, data, controller);
  count('', 3, listo);
  checkingCheck([
    PossibleValues.job,
    PossibleValues.dat,
    PossibleValues.todo,
    PossibleValues.col,
    PossibleValues.imp
  ], controller.widgetsOnScreen.keys.toList());

  controller.buttonType.value = AgainWeekDay;
  doListo(listo, data, controller);
  count('', 4, listo);
  checkingCheck([
    PossibleValues.job,
    PossibleValues.day,
    PossibleValues.str,
    PossibleValues.end,
    PossibleValues.todo,
    PossibleValues.col,
    PossibleValues.imp
  ], controller.widgetsOnScreen.keys.toList());

  controller.buttonType.value = AgainAmountDay;
  doListo(listo, data, controller);
  count('', 4, listo);
  count('0', 1, listo);
  checkingCheck([
    PossibleValues.job,
    PossibleValues.day,
    PossibleValues.str,
    PossibleValues.end,
    PossibleValues.todo,
    PossibleValues.col,
    PossibleValues.imp
  ], controller.widgetsOnScreen.keys.toList());

  controller.buttonType.value = AgainYearDay;
  doListo(listo, data, controller);
  count('', 2, listo);
  checkingCheck([
    PossibleValues.job,
    PossibleValues.day,
    PossibleValues.mon,
    PossibleValues.todo,
    PossibleValues.col,
    PossibleValues.imp
  ], controller.widgetsOnScreen.keys.toList());

  controller.buttonType.value = AgainMonthDay;
  doListo(listo, data, controller);
  count('', 4, listo);
  checkingCheck([
    PossibleValues.job,
    PossibleValues.day,
    PossibleValues.str,
    PossibleValues.end,
    PossibleValues.todo,
    PossibleValues.col,
    PossibleValues.imp
  ], controller.widgetsOnScreen.keys.toList());

  controller.buttonType.value = AgainWeird;
  doListo(listo, data, controller);
  count('', 4, listo);
  checkingCheck([
    PossibleValues.job,
    PossibleValues.day,
    PossibleValues.mon,
    PossibleValues.str,
    PossibleValues.end,
    PossibleValues.todo,
    PossibleValues.col,
    PossibleValues.imp
  ], controller.widgetsOnScreen.keys.toList());
}

void doListo(
    List<String?> listo, List<Widget> data, AddingScreenController controller) {
  data.clear();
  data.addAll(controller.createScreenWidgets());
  listo.clear();
  for (int i = 0; i < data.length; i++) {
    listo.addAll(textButtonSearch(data[i], TextField));
    listo.addAll(textButtonSearch(data[i], BlagendaUniformButton));
  }
}

void checkingCheck(List<PossibleValues> a, List<PossibleValues> b) {
  expect(a.length, b.length);
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      expect(b.contains(a[index]), true);
    }
  }
}

void count(String text, int amount, List<String?> data) =>
    expect(data.where((e) => e == text).length, amount);
