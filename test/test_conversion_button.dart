import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screens/defaultButtons.dart';

///test weather loading of buttons works fine (.loading class)
const stringUsed = '◘';
void main() {
  test('deadline', _deadline);
  test('note', _note);
  test('week', _week);
  test('year', _year);
  test('month', _month);
  test('day', _day);
  // test('test normal input', testInput);
}

void _deadline() {
  var deadlineVar = deadline();
  _compare(deadlineVar, 6);
}

void _note() {
  var noteVar = note();
  _compare(noteVar, 5);
}

void _week() {
  var weekVar = week();
  _compare(weekVar, 8);
}

void _year() {
  var yearVar = year();
  _compare(yearVar, 9);
}

void _month() {
  var monthVar = month();
  _compare(monthVar, 8);
}

void _day() {
  var dayVar = day();
  _compare(dayVar, 9);
}

void _compare<t extends BasicButton>(t button, int expected) {
  var line = exportGenerator(button);
  var newButton = importGenerator<t>(line);
  var newLine = exportGenerator(newButton);
  // when you export a line after you load it its the same as when you unload it
  expect(line, newLine);
  var split = line.split(stringUsed);
  // amount we expect (all the values are put in)
  expect(expected + 1, split.length);
  // all unique
  expect(true, split.where((e) => split.where((ee) => e == ee).isEmpty).isEmpty);

  var check = BasicButton(button.job, button.toDos, button.id, button.color);
  check.important = button.important;
  expect(button.job, check.job);
  expect(button.important, check.important);
  expect(button.toDos, check.toDos);
  expect(button.id, check.id);
  expect(button.color, check.color);
}
