import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/weird_again.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screens/default_buttons.dart';

void main() {
  test('week', _week);
  test('year', _year);
  test('month', _month);
  test('day', _day);
  test('weird', _weird);
}

void _week() {
  var weekBut = make(AgainWeekDay(
      'oi', '', 0, usedColors.first, MyDateController.nowDate.weekday));
  for (int i = 0; i < 15; i++) {
    expect(weekBut.isHappeningOnDayFromNow(i), i % 7 == 0);
  }
}

void _day() {
  var but = make(AgainAmountDay(
      'oi', '', 0, usedColors.first, MyDateController.nowDate, 7));
  for (int i = 0; i < 15; i++) {
    expect(but.isHappeningOnDayFromNow(i), i % 7 == 0);
  }
}

void _month() {
  var but = make(AgainMonthDay('oi', '', 0, usedColors.first, 7));
  for (int i = 0; i < 31; i++) {
    expect(but.isHappeningOnDayFromNow(i),
        MyDateController.fromDaysFromNow(i).day == 7);
  }
}

void _year() {
  var but = make(AgainYearDay('oi', '', 0, usedColors.first, 13, 1));
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year, 1, 13).daysLeftUntil()), true);
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year - 1, 1, 13).daysLeftUntil()), true);
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year + 1, 1, 13).daysLeftUntil()), true);
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year, 1, 14).daysLeftUntil()), false);
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year - 1, 1, 14).daysLeftUntil()), false);
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year + 1, 1, 14).daysLeftUntil()), false);
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year, 1, 12).daysLeftUntil()), false);
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year - 1, 1, 12).daysLeftUntil()), false);
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year + 1, 1, 12).daysLeftUntil()), false);
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year, 2, 13).daysLeftUntil()), false);
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year - 1, 2, 13).daysLeftUntil()), false);
  expect(but.isHappeningOnDayFromNow(MyDateController(MyDateController.nowDate.year + 1, 2, 13).daysLeftUntil()), false);
}

void _weird() {
  var but = make(AgainWeird('oi', '', 0, usedColors.first, 1));
  for (int i = 0; i< 31; i++){
    expect(but.isHappeningOnDayFromNow(i), MyDateController.fromDaysFromNow(i).weekday == 1 && MyDateController.fromDaysFromNow(i).day < 8);
  }
}
