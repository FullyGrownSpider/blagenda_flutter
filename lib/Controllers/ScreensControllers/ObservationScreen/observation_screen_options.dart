import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/mix_button_creator.dart';
import 'package:flutter/material.dart';

import '../../../common_items.dart';
import '../../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../../ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../../blagenda_uniform_button.dart';

class ObservationScreenOptions with buttonCreator {
  static const int daysToShow = 6;
  static const List<int> _possibleExtraDays = [30, 14];

  ///-1 no color selected
  ///-2 show everything in a list
  int _chosenColor = -1;

  ///used to display more days or less days
  int daysToShowNow = daysToShow;

  ///the buttons to select the color to only show
  List<Widget> getOptionButtons(
      void Function() setStateMethod, Function() resetCounters) {
    List<Widget> items = [];
    items.add(const Text('Display Options', style: bigTextStyle));
    items.addAll(globalCreateColorButtons(
        setStateMethod, (i) => _colorPressed(i, resetCounters), _chosenColor));
    items.addAll(addAsRow((i) => _createCounterButton(setStateMethod, i, resetCounters),
        _possibleExtraDays.length));
    items.add(_createDisplayAllEndBasedButtonsButton(setStateMethod, resetCounters));
    return items;
  }

  Widget _createDisplayAllEndBasedButtonsButton(
          void Function() setStateMethod, Function() resetCounters) =>
      BlagendaUniformButton(-2 == _chosenColor, usedColors.first, 'Show all', () {
        resetCounters();
        daysToShowNow = daysToShow;
        if (-2 == _chosenColor) {
          _chosenColor = -1;
        } else {
          _chosenColor = -2;
        }
        setStateMethod();
      });

  Widget _createCounterButton(
          void Function() setStateMethod, int index, Function() resetCounters) =>
      BlagendaUniformButton(daysToShowNow == _possibleExtraDays[index], usedColors.first,
          'Show next ${_possibleExtraDays[index].toString()} days', () {
        _chosenColor = -1;
        if (daysToShowNow == _possibleExtraDays[index]) {
          daysToShowNow = daysToShow;
        } else {
          daysToShowNow = _possibleExtraDays[index];
        }
        resetCounters();
        setStateMethod();
      });

  void _colorPressed(int index, Function() resetCounters) {
    daysToShowNow = daysToShow;
    if (_chosenColor == index) {
      _chosenColor = -1;
    } else {
      _chosenColor = index;
    }
    resetCounters();
  }

  void resetSearch(void Function() setStateMethod, Function() resetCounters) {
    if (_chosenColor == -1 && daysToShowNow == daysToShow) return;
    _chosenColor = -1;
    daysToShowNow = daysToShow;
    resetCounters();
    setStateMethod();
  }

  void pickCorrectOption(
      void Function() defaultListMaker,
      void Function() showEverythingListMaker,
      void Function(Color) colorChoiceListMaker) {
    if (_chosenColor > -1) {
      colorChoiceListMaker(usedColors[_chosenColor]);
    } else if (_chosenColor == -2) {
      showEverythingListMaker();
    } else {
      defaultListMaker();
    }
  }

  bool _shouldGoIn(
          EndBasedController eb, bool Function(EndBasedController) wasJustAdded) =>
      eb.daysLeft < daysToShowNow + 7 && eb.daysLeft >= -1 || wasJustAdded(eb);

  List<BasicButtonController> goesInList(List<BasicButtonController> allItems,
      bool Function(EndBasedController) wasJustAdded) {
    if (allItems.isEmpty) return allItems;
    pickCorrectOption(() {
      var list = allItems.whereType<EndBasedController>();
      var newList = list.where((e) => _shouldGoIn(e, wasJustAdded));
      if (daysToShowNow != daysToShow) {
        //if you select 14 you want to see something 14 days away too not just
        //13
        list = list.where((e) => e.daysLeft == daysToShowNow).toList()..addAll(newList);
      } else {
        list = newList.toList();
      }
    }, () {
      // return list;
    }, (c) {
      allItems = (allItems).where((e) => e.colorCheck(c)).toList();
    });
    return allItems;
  }
}
