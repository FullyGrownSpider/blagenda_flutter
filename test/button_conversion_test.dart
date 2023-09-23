import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/button_conversion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const StringUsed = '◘';
void main() {
  test('deadline', deadline);
  test('note', note);
  test('week', week);
  test('year', year);
  test('month', month);
  test('day', day);
  // test('test normal input', testInput);
}

void deadline(){
  var deadline = Deadline("123", [""], 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(10));
  compare(deadline, 6);
}
void note(){
  var note = BasicButton("123", [""], 1, Colors.black);
  compare(note, 4);
}
void week(){
  var week = AgainWeekDay("123", [""], 1, Colors.black, 1, MyDateController.nowDate.addOrRemoveDays(10));
  compare(week, 6);
}
void year(){
  var year = AgainYearDay("123", [""], 1, Colors.black, 12, 10, MyDateController.nowDate.addOrRemoveDays(10));
  compare(year, 7);
}
void month(){
  var month = AgainMonthDay("123", [""], 1, Colors.black, 23, MyDateController.nowDate.addOrRemoveDays(10));
  compare(month, 6);
}
void day(){
  var day = AgainAmountDay("123", [""], 1, Colors.black, MyDateController.nowDate.addOrRemoveDays(10), 11, MyDateController.nowDate.addOrRemoveDays(10));
  compare(day, 7);
}

void compare<t extends BasicButton>(t button, int expected){
  var line = buttonExportGenerator(button);
  var newButton = buttonImportGenerator<t>(line);
  var newLine = buttonExportGenerator(newButton);
  // when you export a line after you load it its the same as when you unload it
  expect(line, newLine);
  var split = line.split(StringUsed);
  // amount we expect (all the values are put in)
  expect(split.length, expected + 1);
  // all unique
  expect(true, split.where((e) => split.where((ee) => e == ee).isEmpty).isEmpty);

}