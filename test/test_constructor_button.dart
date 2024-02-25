import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/weird_again.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deadline', deadline);
  test('week', week);
  test('year', year);
  test('month', month);
  test('day', day);
  test('weird', weird);
  // test('test normal input', testInput);
}

void deadline() {
  var deadline =
      Deadline('23', '', 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(10));
  var deadline2 =
      Deadline('123', '', 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(-10));
  var d1 = make(deadline);
  expect(d1.requiresChange, false);
  var d2 = make(deadline2);
  expect(d2.requiresChange, true);

  var days = d1.daysLeft;
  MyDateController.today = MyDateController.nowDate.addOrRemoveDays(1);
  d1.rebuild();
  expect(d1.daysLeft % 7, (days - 1) % 7);
  backToTheFutureTesting(deadline);
  backToTheFutureTesting(deadline2);
  MyDateController.today = MyDateController.nowDate.addOrRemoveDays(-1);
}

void week() {
  var week1 = AgainWeekDay('123', '', 1, Colors.black, MyDateController.nowDate.weekday);
  var week2 = AgainWeekDay(
      '123',
      '',
      1,
      Colors.black,
      (MyDateController.nowDate.weekday - 1) % 7,
      MyDateController.nowDate.addOrRemoveDays(-10));
  var week3 = AgainWeekDay('123', '', 1, Colors.black, MyDateController.nowDate.weekday,
      null, MyDateController.nowDate.addOrRemoveDays(-10));
  var week4 = AgainWeekDay('123', '', 1, Colors.black, MyDateController.nowDate.weekday,
      null, null, MyDateController.nowDate.addOrRemoveDays(10));
  var d1 = make(week1);
  expect(d1.requiresChange, false);
  expect(d1.daysLeft, 0);
  var d2 = make(week2);
  expect(d2.requiresChange, true);
  expect((d2 as SkippableEndBasedController).displayJob().contains('⚈'), false);
  var d3 = make(week3);
  expect(d3.requiresChange, true);
  expect((d3 as SkippableEndBasedController).displayJob().contains('⚈'), true);
  expect((d3 as AgainWeekController).wantDeleteMe(), true);
  var d4 = make(week4);
  expect(d4.daysLeft, 14);

  var days = d1.daysLeft;
  var d1Clone = (d1 as AgainWeekController).createNew(7);
  var daysAlt = d1Clone.daysLeft;
  var daysAltAlt = d1Clone.altLeft;
  expect(days, daysAlt);

  MyDateController.today = MyDateController.nowDate.addOrRemoveDays(1);
  d1.rebuild();
  expect(d1.daysLeft % 7, (days - 1) % 7);
  expect(7, daysAltAlt);
  backToTheFutureTesting(week1);
  backToTheFutureTesting(week2);
  backToTheFutureTesting(week3);
  backToTheFutureTesting(week4);
  MyDateController.today = MyDateController.nowDate.addOrRemoveDays(-1);
}

void year() {
  var year = AgainYearDay(
      '123',
      '',
      1,
      Colors.black,
      MyDateController.nowDate.addOrRemoveDays(12).day,
      MyDateController.nowDate.addOrRemoveDays(12).month);
  var year2 = AgainYearDay(
      '123',
      '',
      1,
      Colors.black,
      MyDateController.nowDate.addOrRemoveDays(-12).day,
      MyDateController.nowDate.addOrRemoveDays(-12).month);
  var d1 = make(year);
  expect(d1.requiresChange, false);
  expect(d1.daysLeft < 20, true);
  var d2 = make(year2);
  expect(d2.requiresChange, false);
  expect((d2 as SkippableEndBasedController).displayJob().contains('⚈'), false);
  expect(
      (d2 as AgainYearController).dateController.year, MyDateController.nowDate.year + 1);

  var days = d1.daysLeft;
  MyDateController.today = MyDateController.nowDate.addOrRemoveDays(1);
  d1.rebuild();
  expect(d1.daysLeft % 7, (days - 1) % 7);
  backToTheFutureTesting(year);
  backToTheFutureTesting(year2);
  MyDateController.today = MyDateController.nowDate.addOrRemoveDays(-1);
}

void month() {
  var month = AgainMonthDay('123', '', 1, Colors.black, 23);
  var month1 = AgainMonthDay(
      '123', '', 1, Colors.black, 23, null, MyDateController.nowDate.addOrRemoveDays(10));
  var month2 = AgainMonthDay('123', '', 1, Colors.black, 23, null, null,
      MyDateController.nowDate.addOrRemoveDays(40));
  var month3 = AgainMonthDay('123', '', 1, Colors.black, 23, null,
      MyDateController.nowDate.addOrRemoveDays(-10));
  var d1 = make(month);
  expect(d1.requiresChange, false);
  var d2 = make(month1);
  expect((d2 as AgainMonthController).displayJob().contains('⚈'), true);
  expect(d2.wantDeleteMe(), false);
  var d3 = make(month2);
  expect(d3.dateController.daysLeftUntil() > 40, true);
  var d4 = make(month3);
  expect((d4 as SkippableEndBasedController).displayJob().contains('⚈'), true);
  expect((d4).wantDeleteMe(), true);

  var days = d1.daysLeft;
  MyDateController.today = MyDateController.nowDate.addOrRemoveDays(1);
  d1.rebuild();
  expect(d1.daysLeft % 7, (days - 1) % 7);
  backToTheFutureTesting(month);
  backToTheFutureTesting(month1);
  backToTheFutureTesting(month2);
  backToTheFutureTesting(month3);
  MyDateController.today = MyDateController.nowDate.addOrRemoveDays(-1);
}

void weird() {
  MyDateController.today = MyDateController(2023, 12, 31);
  var weird = AgainWeird('123', '', 1, Colors.black, 1);
  var weirdCheck = AgainWeekDay('123', '', 1, Colors.black, 1);
  var weird1 = AgainWeird('123', '', 1, Colors.black, 15);
  var weird2 = AgainWeird('123', '', 1, Colors.black, 15, null, null,
      MyDateController.today.addOrRemoveDays(31));
  var weird3 = AgainWeird(
      '123', '', 1, Colors.black, 15, null, MyDateController.today.addOrRemoveDays(-14));
  var d1 = make(weird);
  var c1 = make(weirdCheck);
  var d2 = make(weird1);
  var d3 = make(weird2);
  var d4 = make(weird3);

  d1.rebuild();
  d2.rebuild();
  d3.rebuild();
  d4.rebuild();
  c1.rebuild();

  var days = d1.daysLeft;
  var daysCheck = c1.daysLeft;
  expect(days, daysCheck);
  days = d2.daysLeft;
  expect(days, daysCheck + 14);
  days = d3.daysLeft;
  expect(days, daysCheck + 14);
  expect(d4.requiresChange, true);
}

void day() {
  var day = AgainAmountDay(
      '123', '', 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(10), 11, null);
  var day2 = AgainAmountDay('123', '', 1, Colors.black,
      MyDateController.nowDate.addOrRemoveDays(-10), 11, null);
  var day3 = AgainAmountDay(
      '123',
      '',
      1,
      Colors.black,
      MyDateController.nowDate.addOrRemoveDays(-10),
      11,
      null,
      MyDateController.nowDate.addOrRemoveDays(-1));
  var day4 = AgainAmountDay(
      '123',
      '',
      1,
      Colors.black,
      MyDateController.nowDate.addOrRemoveDays(-10),
      11,
      null,
      MyDateController.nowDate.addOrRemoveDays(100));
  var endingTest = MyDateController.nowDate.addOrRemoveDays(340);
  var day5 = AgainAmountDay('123', '', 1, Colors.black,
      MyDateController.nowDate.addOrRemoveDays(-10), 11, null, endingTest);

  var d1 = make(day) as SkippableEndBasedController;
  var d2 = make(day2) as SkippableEndBasedController;
  var d3 = make(day3) as SkippableEndBasedController;
  var d4 = make(day4) as SkippableEndBasedController;
  var d5 = make(day5) as SkippableEndBasedController;
  expect(d1.requiresChange, false);
  expect(d2.wantDeleteMe(), false);
  expect(d2.requiresChange, true);
  expect(d2.startDate != null, true);
  expect(d3.startDate != null, true);
  expect(d3.requiresChange, true);
  expect((d3).displayJob().contains('⚈'), true);
  expect(d3.wantDeleteMe(), true);
  expect(d4.requiresChange, true);
  expect(d4.startDate != null, true);
  expect((d4).displayJob().contains('⚈'), false);
  expect(d4.wantDeleteMe(), false);
  expect(d5.wantDeleteMe(), false);
  expect(d5.startDate != null, true);
  expect(d5.endingDate, endingTest);

  var days = d1.daysLeft;
  MyDateController.today = MyDateController.nowDate.addOrRemoveDays(1);
  d1.rebuild();
  expect(d1.daysLeft % 7, (days - 1) % 7);
  backToTheFutureTesting(day);
  backToTheFutureTesting(day2);
  backToTheFutureTesting(day3);
  backToTheFutureTesting(day4);
  MyDateController.today = MyDateController.nowDate.addOrRemoveDays(-1);
}

///test if the countdown goes well (from x to zero)
void backToTheFutureTesting<t extends BasicButton>(t actBut) {
  var but = make(actBut);
  MyDateController ogNowDate = MyDateController.today;
  if (but.daysLeft < 1) {
    MyDateController.today = MyDateController.nowDate.addOrRemoveDays(2);
  }
  int lastCheck = but.daysLeft;
  while (but.daysLeft > 0) {
    MyDateController.today = MyDateController.nowDate.addOrRemoveDays(1);
    but.rebuild();
    expect(but.daysLeft, lastCheck - 1);
    lastCheck = but.daysLeft;
  }
  MyDateController.today = ogNowDate;
}

///test version of 'turn x into a controller'
EndBasedController make<t extends BasicButton>(t button) {
  var controller = dataToController(button) as EndBasedController;
  return controller;
}
