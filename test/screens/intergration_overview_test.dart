import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/ObservationScreen/observation_screen_options.dart';
import 'package:blagenda_flutter_simple/Controllers/blagenda_uniform_button.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'default_buttons.dart';
import 'overview4test.dart';

void main() {
  test('show week', _showWeek);
  test('show colors', _showColorButtons);
  test('show more days', _showMoreDays);
  test('show Everything', _showEverything);
  test('show long', _showLong);
  test('skipping', _skipThisTime);
}

Overview4Test makeItFullForTesting() {
  final overView = buildOverview([
    NoteController(note()),
    make(deadline()
      ..id = 0
      ..date = MyDateController.yesterday),
    make(deadline()),
    make(deadline()
      ..id = 2
      ..date = MyDateController.fromDaysFromNow(0)),
    make(deadline()
      ..id = 3
      ..date = MyDateController.fromDaysFromNow(8)),
    make(deadline()
      ..id = 4
      ..date = MyDateController.fromDaysFromNow(17)),
    make(deadline()
      ..id = 5
      ..date = MyDateController.fromDaysFromNow(200))
  ], []);
  overView.addOrUpdate(make(deadline()
    ..job = 'in the near future'
    ..toDos = '10am\n10d'
    ..id = 6
    ..date = MyDateController.fromDaysFromNow(200))
    ..touched = true);
  overView
    .addOrUpdate(make(deadline()
      ..job = 'longggggggggg'
      ..color = usedColors.first
      ..toDos = '10am\n2d'
      ..id = 7
      ..date = MyDateController.fromDaysFromNow(3))
      ..touched = true);
  overView.controller.justAddedCheck();
  return overView;
}

void _skipThisTime() {
  var nrOne = make(AgainMonthDay(
      'this', '', 1, usedColors.first, MyDateController.today.day));
  var nrTwo = make(AgainAmountDay(
      'that-y', '', 1, usedColors.first, MyDateController.today, 3));
  var theScreen = buildOverview([NoteController(note()), nrOne, nrTwo], [])
    ..controller.justAddedCheck();
  var list = theScreen.controller.getWidgetListEndBased();
  var buttons = [];
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, TextButton));
    buttons.addAll(textButtonSearch(item, BlagendaUniformButton));
  }
  expect(buttons.contains('this'), true);
  //...

  theScreen.controller.observationScreenButtons.clickOnButton(nrOne);
  theScreen.notifier.skipButton(
      theScreen.controller.getSelectedButton()! as SkippableEndBasedController,
      0);
  list = theScreen.controller.getWidgetListEndBased();
  buttons.clear();
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, TextButton));
    buttons.addAll(textButtonSearch(item, BlagendaUniformButton));
  }
  expect(buttons.contains('this'), false);
  expect(buttons.where((e) => e == 'that-y').length, 2);

  //,,
  theScreen.controller.observationScreenButtons.clickOnButton(nrTwo);
  theScreen.notifier.skipButton(
      theScreen.controller.getSelectedButton()! as SkippableEndBasedController,
      3);

  list = theScreen.controller.getWidgetListEndBased();
  buttons.clear();
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, TextButton));
    buttons.addAll(textButtonSearch(item, BlagendaUniformButton));
  }
  expect(buttons.contains('this'), false);
  expect(buttons.where((e) => e == 'that-y').length, 1);
}

void _showWeek() {
  var theScreen = makeItFullForTesting();
  var list = theScreen.controller.getWidgetListEndBased();
  var buttons = [];
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, TextButton));
    buttons.addAll(textButtonSearch(item, BlagendaUniformButton));
  }
  //the 6 default days + yesterday + 2 deadlines + 3 from the new date + 3 long deadlines = 12
  expect(buttons.length, 15);
  expect(buttons[1], '123'); //yesterday
  expect(buttons[3], '⊚in the near future'); //in the future
  expect(buttons[5], '123');
  expect(buttons[7], '123');
  expect(buttons[10], '⊚10:00 ~ longggggggggg');
  expect(buttons[12], '⊚long...');
  expect(buttons[14], '⊚long...');
}

void _showEverything() {
  var theScreen = makeItFullForTesting();
  theScreen.controller.observationScreenOptions.displayState.showEverything();
  expect(States.everything,
      theScreen.controller.observationScreenOptions.displayState.state);
  var list = theScreen.controller.getWidgetListEndBased();
  var buttons = [];
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, BlagendaUniformButton));
  }
  expect(buttons.length, 8);
}

void _showColorButtons() {
  var theScreen = makeItFullForTesting();
  var butOne = deadline()
    ..date = MyDateController.fromDaysFromNow(10)
    ..job = '0'
    ..id = 200
    ..color = usedColors.first;
  var butTwo = deadline()
    ..job = '0'
    ..id = 201
    ..color = usedColors.first;
  var butThree = deadline()
    ..date = MyDateController.fromDaysFromNow(10)
    ..job = '1'
    ..id = 202
    ..color = usedColors[1];
  var butFour = deadline()
    ..job = '1'
    ..id = 203
    ..color = usedColors[1];
  theScreen.addOrUpdate(make(butOne));
  theScreen.addOrUpdate(make(butTwo));
  theScreen.addOrUpdate(make(butThree));
  theScreen.addOrUpdate(make(butFour));
  theScreen.controller.observationScreenOptions.displayState.colorMode = 0;
  var list = theScreen.controller.getWidgetListEndBased();
  var buttons = [];
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, BlagendaUniformButton));
  }
  expect(buttons.length, 5);
  expect(buttons.where((e) => e == '0').length, 2);
  theScreen.controller.observationScreenOptions.displayState.colorMode = 1;
  list = theScreen.controller.getWidgetListEndBased();
  buttons.clear();
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, BlagendaUniformButton));
  }
  expect(buttons.length, 2);
  expect(buttons.where((e) => e == '1').length, 2);
}

void _showMoreDays() {
  var theScreen = makeItFullForTesting();
  theScreen.controller.observationScreenOptions.displayState.days =
      ObservationScreenOptions.possibleExtraDays.first;
  var list = theScreen.controller.getWidgetListEndBased();
  var buttons = [];
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, BlagendaUniformButton));
  }
  expect(buttons.length, 9);
  theScreen.controller.observationScreenOptions.displayState.days =
      ObservationScreenOptions.possibleExtraDays.last;
  list = theScreen.controller.getWidgetListEndBased();
  buttons.clear();
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, BlagendaUniformButton));
  }
  expect(buttons.length, 8);
}

void _showLong() {
  var theScreen = makeItFullForTesting();
  theScreen.addOrUpdate(make(deadline()
    ..date = MyDateController.fromDaysFromNow(-10)
    ..job = 'It\'s not butter'
    ..toDos = '20d'));
  var list = theScreen.controller.getWidgetListEndBased();
  var buttons = [];
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, BlagendaUniformButton));
  }
  expect(buttons.length, 13);
}

EndBasedController make<t extends BasicButton>(t button) {
  var controller = dataToController(button) as EndBasedController;
  return controller;
}

Overview4Test buildOverview(
    List<BasicButtonController> buttons, List<EntityController> entities,
    [Function()? thingToDo]) {
  final enitityNotifier = FakeEntityNotifier();
  final notifier = FakeButtonNotifier(enitityNotifier);
  notifier.getData().addAll(buttons); //kinda should not do this
  return Overview4Test(notifier, enitityNotifier);
}
