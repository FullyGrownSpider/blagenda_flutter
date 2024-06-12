import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/mix_day_creator.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockingCreator with DayCreator {}

///tests if it shows days in createADay the way it should on a basic level
void main() {
  test('deadline', deadline);

  test('week', week);
  test('year', year);
  test('month', month);
  test('day', day);
  test('skip', skip);
}

MyDateController wowDate = MyDateController.nowDate.addOrRemoveDays(-10);

MockingCreator to = MockingCreator();

void deadline() {
  var deadline = Deadline('23', '', 1, Colors.black, MyDateController.nowDate);
  showIn10(deadline);
  var deadline2 =
      Deadline('23', '', 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(-1));
  var yesterday = make(deadline2);
  expect(false, yesterday.requiresChange);
}

void week() {
  var week = make(AgainWeekDay('123', '', 1, Colors.black, 1));
  for (int i = 0; i < 7; i++) {
    var list = to.createADay(MyDateController.nowDate, [week], i,
        (p0, p2) => const Text(''), false, false);
    if (list.length > 2) {
      expect(true, true);
      return;
    }
  }
  expect(true, false);
}

void year() {
  var year = AgainYearDay('123', '', 1, Colors.black, MyDateController.nowDate.day,
      MyDateController.nowDate.month);
  showIn10(year);
}

void month() {
  var month = AgainMonthDay('123', '', 1, Colors.black, MyDateController.nowDate.day);
  showIn10(month);
}

void day() {
  var day = AgainAmountDay('123', '', 1, Colors.black, MyDateController.nowDate, 11);
  showIn10(day);
}

void skip() {
  var month = AgainMonthDay(
      '123', '', 1, Colors.black, MyDateController.nowDate.day, MyDateController.today);
  var monthController = make(month);
  var list = to.createADay(MyDateController.today, [monthController], 0,
      (p0, p2) => const Text(''), false, false);
  expect(false, listCheck(list));
  MyDateController.today = wowDate;
  list = to.createADay(wowDate, [monthController], 10,
      (p0, p2) => const Text(''), false, false);
  expect(false, listCheck(list));
  MyDateController.today = wowDate.addOrRemoveDays(10);
}

void showIn10<t extends BasicButton>(t button) {
  MyDateController.today = wowDate;
  var correctThing = make(button);
  var list = to.createADay(
      wowDate, [correctThing], 10, (p0, p2) => const Text(''), false, false);
  expect(true, listCheck(list));
  MyDateController.today = wowDate.addOrRemoveDays(10);
}

bool listCheck(List<Widget> list) {
  var l = list.whereType<Text>().length;
  return l > 0;
}

EndBasedController make<t extends BasicButton>(t button) {
  var controller = dataToController(button) as EndBasedController;
  return controller;
}
