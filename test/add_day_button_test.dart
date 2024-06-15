import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/weird_again.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

///test weather adding days makes days actually be added or removed correctly
void main() {
  test('deadline', _deadline);
  test('week', _week);
  test('year', _year);
  test('month', _month);
  test('day', _day);
  test('weird', _weird);
}

void _deadline() {
  var but =
      Deadline('23', '', 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(1));
  EndBasedController one = make(but);
  _badSpects(one);
}

void _week() {
  var but = AgainWeekDay('123', '', 1, Colors.black, MyDateController.nowDate.weekday);
  EndBasedController one = make(but);
  _spects(one);
}

void _year() {
  var but = AgainYearDay(
      '123',
      '',
      1,
      Colors.black,
      MyDateController.nowDate.addOrRemoveDays(12).day,
      MyDateController.nowDate.addOrRemoveDays(12).month);
  EndBasedController one = make(but);
  _badSpects(one);
}

void _month() {
  var but = AgainMonthDay('123', '', 1, Colors.black, 23);
  EndBasedController one = make(but);
  _spects(one);
}

void _weird() {
  var but = AgainWeird('123', '', 1, Colors.black, 1);
  EndBasedController one = make(but);
  _spects(one);
}

void _day() {
  var but = AgainAmountDay(
      '123', '', 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(10), 11, null);
  EndBasedController one = make(but);
  _badSpects(one);
}

void _spects(EndBasedController one) {
  int prev = one.daysLeft;
  one.addOrRemoveDays(1);
  _addSpect(one.daysLeft, prev, 1);
  prev = one.daysLeft;
  one.addOrRemoveDays(-1);
  _addSpect(one.daysLeft, prev, -1);
}

void _badSpects(EndBasedController one) {
  _spects(one);
  int prev = one.daysLeft;
  one.addOrRemoveDays(30);
  _addSpect(one.daysLeft, prev, 30);
  prev = one.daysLeft;
  one.addOrRemoveDays(-30);
  _addSpect(one.daysLeft, prev, -30);
}

void _addSpect(int now, int prev, int added) {
  expect(now, prev + added);
}

///test version of 'turn x into a controller'
EndBasedController make<t extends BasicButton>(t button) {
  var controller = dataToController(button) as EndBasedController;
  return controller;
}
