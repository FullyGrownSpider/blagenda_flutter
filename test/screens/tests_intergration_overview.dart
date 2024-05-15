import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/entity.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/ObservationScreen/observation_screen_options.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter_test/flutter_test.dart';

import 'defaultButtons.dart';
import 'overview4test.dart';

void main() {
  test('adding', _createADayAndEntity);
  test('edit', _editADay);
  test('show week', _showWeek);
  test('show colors', _showColorButtons);
  test('show more days', _showMoreDays);
  test('show Everything', _showEverything);
  test('show long', _showLong);
}

void _createADayAndEntity() {
  var overView = buildOverview([], []);
  overView.addOrUpdate(NoteController(note()));
  overView.addOrUpdate(make(deadline()));
  overView.addOrUpdate(EntityController(Entity([], 1)));

  expect(overView.controller.allLists.length, 2);
  overView.controller.observationScreenButtons.justAddedCheck();
  expect(overView.controller.observationScreenButtons.amountJustAdded, 1);
}

void _editADay() {
  var overView = buildOverview([NoteController(note()), make(deadline())], []);
  var title = 'newTitle';
  overView.addOrUpdate(NoteController(note()..job = title));
  overView.addOrUpdate(make(deadline()..job = title));

  expect(overView.controller.allLists.where((e) => e.job == title).length, 2);
  overView.controller.observationScreenButtons.justAddedCheck();
  expect(overView.controller.observationScreenButtons.amountJustAdded, 1);
}

Overview4Test makeItFullForTesting() {
  return buildOverview([
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
  ], [])
    ..addOrUpdate(make(deadline()
      ..toDos = '10am\n10d'
      ..id = 6
      ..date = MyDateController.fromDaysFromNow(200)))
    ..addOrUpdate(make(deadline()
      ..job = 'long'
      ..color = usedColors.first
      ..toDos = '10am\n2d'
      ..id = 7
      ..date = MyDateController.fromDaysFromNow(3)))
    ..controller.observationScreenButtons.justAddedCheck();
}

void _showWeek() {
  var theScreen = makeItFullForTesting();
  expect(2, theScreen.controller.observationScreenButtons.amountJustAdded);
  var list = theScreen.controller.getWidgetListEndBased(() {});
  var buttons = [];
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, false));
    buttons.addAll(textButtonSearch(item, true));
  }
  //the 6 default days + yesterday + 2 deadlines + 3 from the new date + 3 long deadlines = 12
  expect(buttons.length, 15);
  expect(buttons[1], '123'); //yesterday
  expect(buttons[3], '⊚123'); //in the future
  expect(buttons[5], '123');
  expect(buttons[7], '123');
  expect(buttons[10], '©10:00 ~ long');
  expect(buttons[12], '©lon••');
  expect(buttons[14], '©lon••');
}

void _showEverything() {
  var theScreen = makeItFullForTesting();
  theScreen.controller.observationScreenOptions.chosenColor = -2;
  var list = theScreen.controller.getWidgetListEndBased(() {});
  var buttons = [];
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, true));
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
  theScreen.controller.observationScreenOptions.chosenColor = 0;
  var list = theScreen.controller.getWidgetListEndBased(() {});
  var buttons = [];
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, true));
  }
  expect(buttons.length, 5);
  expect(buttons.where((e) => e == '0').length, 2);
  theScreen.controller.observationScreenOptions.chosenColor = 1;
  list = theScreen.controller.getWidgetListEndBased(() {});
  buttons.clear();
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, true));
  }
  expect(buttons.length, 2);
  expect(buttons.where((e) => e == '1').length, 2);
}

void _showMoreDays() {
  var theScreen = makeItFullForTesting();
  theScreen.controller.observationScreenOptions.daysToShowNow =
      ObservationScreenOptions.possibleExtraDays.first;
  var list = theScreen.controller.getWidgetListEndBased(() {});
  var buttons = [];
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, true));
  }
  expect(buttons.length, 9);
  theScreen.controller.observationScreenOptions.daysToShowNow =
      ObservationScreenOptions.possibleExtraDays.last;
  list = theScreen.controller.getWidgetListEndBased(() {});
  buttons.clear();
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, true));
  }
  expect(buttons.length, 8);
}

void _showLong() {
  var theScreen = makeItFullForTesting();
  theScreen.addOrUpdate(make(deadline()
    ..date = MyDateController.fromDaysFromNow(-10)
    ..job = 'It\'s not butter'
    ..toDos = '20d'));
  var list = theScreen.controller.getWidgetListEndBased(() {});
  var buttons = [];
  for (var item in list) {
    buttons.addAll(textButtonSearch(item, true));
  }
  expect(buttons.length, 15);
}

EndBasedController make<t extends BasicButton>(t button) {
  var controller = dataToController(button) as EndBasedController;
  return controller;
}

Overview4Test buildOverview(
    List<BasicButtonController> buttons, List<EntityController> entities,
    [Function()? thingToDo]) {
  return Overview4Test((p0) => thingToDo, buttons, entities);
}
