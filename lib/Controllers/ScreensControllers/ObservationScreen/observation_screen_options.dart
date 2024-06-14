import 'dart:math';

import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/mix_button_creator.dart';
import 'package:blagenda_flutter_simple/Controllers/color_buttons.dart';
import 'package:flutter/material.dart';

import '../../../common_items.dart';
import '../../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../../ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../../blagenda_uniform_button.dart';

class ObservationScreenOptions with ButtonCreator {
  static const int daysToShow = 6;
  @visibleForTesting
  static const List<int> possibleExtraDays = [30, 14];

  DisplayState displayState = DisplayState();

  ValueNotifier getNotifier() => displayState._actuallyCurrent;
  final List<Widget> _items = [];

  ///the buttons to select the color to only show
  List<Widget> getOptionButtons(Function() resetCounters) {
    if (_items.isEmpty) {
      _items.add(const Text('Display Options', style: bigTextStyle));
      _items.add(ColorButtons(displayState._actuallyCurrent,
          (dClick) => colorPressed(dClick, resetCounters)));
      _items.addAll(addAsRow((i) => _createCounterButton(i, resetCounters),
          possibleExtraDays.length));
      _items.add(_createDisplayAllEndBasedButtonsButton(resetCounters));
    }
    return _items;
  }

  Widget _createDisplayAllEndBasedButtonsButton(Function() resetCounters) {
    var myBool = _makeBool(() => displayState.state == States.everything);
    return BlagendaUniformButton(usedColors.first, () => 'Show all', () {
      resetCounters();
      //should reset?
      myBool.value = displayState.state != States.everything;
      if (myBool.value) {
        displayState.showEverything();
      } else {
        displayState.days = daysToShow;
      }
    }, isSelected: myBool);
  }

  Widget _createCounterButton(int index, Function() resetCounters) {
    var myBool = _makeBool(() => displayState.days == possibleExtraDays[index]);
    return BlagendaUniformButton(usedColors.first,
        () => 'Show next ${possibleExtraDays[index].toString()} days', () {
      if (myBool.value) {
        displayState.days = daysToShow;
      } else {
        displayState.days = possibleExtraDays[index];
      }
      resetCounters();
    }, isSelected: myBool);
  }

  ValueNotifier<bool> _makeBool(Function() action) {
    ValueNotifier<bool> yourBool = ValueNotifier(action());
    displayState.addListener(() {
      yourBool.value = action();
    });
    return yourBool;
  }

  @visibleForTesting
  void colorPressed(bool dClick, Function() resetCounters) {
    if (dClick) {
      displayState.days = daysToShow;
    }
    resetCounters();
  }

  void resetSearch(Function() resetCounters) {
    if (displayState.days == daysToShow) return;
    displayState.days = daysToShow;
    resetCounters();
  }

  void pickCorrectOption(
      void Function() defaultListMaker,
      void Function() showEverythingListMaker,
      void Function(Color) colorChoiceListMaker) {
    var chosenState = displayState.state;
    if (chosenState == States.colors) {
      colorChoiceListMaker(usedColors[displayState.color]);
    } else if (chosenState == States.everything) {
      showEverythingListMaker();
    } else {
      defaultListMaker();
    }
  }

  ///only for check about days
  bool _shouldGoIn(EndBasedController eb,
          bool Function(EndBasedController) wasJustAdded) =>
      eb.daysLeft <= displayState.days + 7 || wasJustAdded(eb);

  List<BasicButtonController> goesInList(List<BasicButtonController> allItems,
      bool Function(EndBasedController) wasJustAdded) {
    List<BasicButtonController> returnList = [];
    pickCorrectOption(() {
      //show x days
      var list = allItems.whereType<EndBasedController>();
      returnList.addAll(list.where((e) => _shouldGoIn(e, wasJustAdded)));
      if (displayState.days == daysToShow) {
        returnList.addAll(allItems.whereType<NoteController>());
      }
    }, () {
      //show everything
      returnList = allItems;
    }, (c) {
      //show colored
      returnList = (allItems).where((e) => e.colorCheck(c)).toList();
    });
    return returnList;
  }
}

class DisplayState {
  final ValueNotifier<int> _actuallyCurrent =
      ValueNotifier(ObservationScreenOptions.daysToShow + usedColors.length);

  //-2 is show EVERYTHING
  @visibleForTesting
  // 0 - usedColors.length is that color
  States get state {
    return _actuallyCurrent.value == -2
        ? States.everything
        : _actuallyCurrent.value >= usedColors.length
            ? States.days
            : States.colors;
  }

  int get color => _actuallyCurrent.value;

  void showEverything() => _actuallyCurrent.value = -2;

  set colorMode(int color) => _actuallyCurrent.value = color;

  int get days => max(ObservationScreenOptions.daysToShow,
      _actuallyCurrent.value - (usedColors.length));

  set days(int value) => _actuallyCurrent.value = value + (usedColors.length);

  void addListener(void Function() listener) =>
      _actuallyCurrent.addListener(listener);
}
@visibleForTesting
enum States { everything, colors, days }
