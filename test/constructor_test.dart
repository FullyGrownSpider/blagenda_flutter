import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/button_conversion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deadline', deadline);
  test('week', week);
  test('year', year);
  test('month', month);
  test('day', day);
  // test('test normal input', testInput);
}

void deadline(){
  var deadline = Deadline("123", [""], 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(10));
  var deadline2 = Deadline("123", [""], 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(-10));
  var d1 = make(deadline);
  expect(d1.requiresChange, false);
  var d2 = make(deadline2);
  expect(d2.requiresChange, true);
}
void week(){
  var week = AgainWeekDay("123", [""], 1, Colors.black, 1, null, null, MyDateController.nowDate.addOrRemoveDays(10));
  var week2 = AgainWeekDay("123", [""], 1, Colors.black, 1, MyDateController.nowDate.addOrRemoveDays(-10));
  var week3 = AgainWeekDay("123", [""], 1, Colors.black, 1, null, MyDateController.nowDate.addOrRemoveDays(-10));
  var week4 = AgainWeekDay("123", [""], 1, Colors.black, 1, null, null, MyDateController.nowDate.addOrRemoveDays(10));
  var d1 = make(week);
  expect(d1.requiresChange, false);
  expect(d1.daysLeft > 7, true);
  var d2 = make(week2);
  expect(d2.requiresChange, true);
  expect((d2 as SkippableEndBasedController).displayJob().contains("⚈"), false);
  expect(d2.daysLeft, 1);
  var d3 = make(week3);
  expect(d3.requiresChange, true);
  expect((d3 as SkippableEndBasedController).displayJob().contains("⚈"), true);
  expect((d3 as AgainWeekController).wantDeleteMe(), true);
  var d4 = make(week4);
  expect(d4.daysLeft > 10, true);
}
void year(){
  var year = AgainYearDay("123", [""], 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(12).day, MyDateController.nowDate.addOrRemoveDays(12).month);
  var year2 = AgainYearDay("123", [""], 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(-12).day, MyDateController.nowDate.addOrRemoveDays(-12).month);
  var d1= make(year);
  expect(d1.requiresChange, false);
  expect(d1.daysLeft < 20, true);
  var d2 = make(year2);
  expect(d2.requiresChange, false);
  expect((d2 as SkippableEndBasedController).displayJob().contains("⚈"), false);
  expect((d2 as AgainYearController).dateController.year, MyDateController.nowDate.year + 1);

}
void month(){
  var month = AgainMonthDay("123", [""], 1, Colors.black, 23);
  var month1 = AgainMonthDay("123", [""], 1, Colors.black, 23, null, MyDateController.nowDate.addOrRemoveDays(10));
  var month2 = AgainMonthDay("123", [""], 1, Colors.black, 23, null, null, MyDateController.nowDate.addOrRemoveDays(40));
  var month3 = AgainMonthDay("123", [""], 1, Colors.black, 23, null, MyDateController.nowDate.addOrRemoveDays(-10));
  var d1= make(month);
  expect(d1.requiresChange, false);
  var d2= make(month1);
  expect((d2 as AgainMonthController).displayJob().contains("⚈"), true);
  expect(d2.wantDeleteMe(), false);
  var d3= make(month2);
  expect(d3.dateController.daysLeftUntil() > 40, true);
  var d4= make(month3);
  expect((d4 as SkippableEndBasedController).displayJob().contains("⚈"), true);
  expect((d4).wantDeleteMe(), true);

}
void day(){
  var day = AgainAmountDay("123", [""], 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(10), 11, null);
  var day2 = AgainAmountDay("123", [""], 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(-10), 11, null);
  var day3 = AgainAmountDay("123", [""], 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(-10), 11, null, MyDateController.nowDate.addOrRemoveDays(-1));
  var day4 = AgainAmountDay("123", [""], 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(-10), 11, null, MyDateController.nowDate.addOrRemoveDays(100));
  var d1 = make(day) as SkippableEndBasedController;
  var d2 = make(day2) as SkippableEndBasedController;
  var d3 = make(day3) as SkippableEndBasedController;
  var d4 = make(day4) as SkippableEndBasedController;
  expect(d1.requiresChange, false);
  expect(d2.wantDeleteMe(), false);
  expect(d2.requiresChange, true);
  expect(d3.requiresChange, true);
  expect((d3).displayJob().contains("⚈"), true);
  expect(d3.wantDeleteMe(), true);
  expect(d4.requiresChange, true);
  expect((d4).displayJob().contains("⚈"), false);
  expect(d4.wantDeleteMe(), false);
}

EndBasedController make<t extends BasicButton>(t button){
  var controller = buttonToController(t, button) as EndBasedController;
  return controller;
}

