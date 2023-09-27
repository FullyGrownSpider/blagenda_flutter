import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/common_screen_controller.dart';
import 'package:flutter/material.dart';

import '../../ButtonControllers/basic_button_controller.dart';
import '../../ButtonControllers/end_based_controller.dart';
import '../../my_date_controller.dart';

class ObservationScreenOptions {
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
    items.addAll(addAsRow(
        (i) => _createCounterButton(setStateMethod, i, resetCounters),
        _possibleExtraDays.length));
    items.add(
        _createDisplayAllEndBasedButtonsButton(setStateMethod, resetCounters));
    items.add(bigSplitterTextField);
    return items;
  }

  Widget _createDisplayAllEndBasedButtonsButton(
          void Function() setStateMethod, Function() resetCounters) =>
      blagendaUniformButton(-2 == _chosenColor, usedColors.first, 'Show all',
          () {
        resetCounters();
        daysToShowNow = daysToShow;
        if (-2 == _chosenColor) {
          _chosenColor = -1;
        } else {
          _chosenColor = -2;
        }
        setStateMethod();
      });

  Widget _createCounterButton(void Function() setStateMethod, int index,
          Function() resetCounters) =>
      blagendaUniformButton(
          daysToShowNow == _possibleExtraDays[index],
          usedColors.first,
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

  bool _shouldGoIn(EndBasedController eb, MyDateController now) =>
      eb.daysLeft < daysToShowNow + 7 && eb.daysLeft >= -1 ||
      eb.wasJustAdded(now);

  List<BasicButtonController> goesInList(
      List<BasicButtonController> list, MyDateController now) {
    if (list.isEmpty) return list;
    pickCorrectOption(() {
      if (list.first is EndBasedController) {
        var newList =
            list.where((e) => _shouldGoIn(e as EndBasedController, now));
        if (daysToShowNow != daysToShow) {
          //if you select 14 you want to see something 14 days away too not just
          //13
          list = list
              .where((e) => (e as EndBasedController).daysLeft == daysToShowNow)
              .toList()
            ..addAll(newList);
        } else {
          list = newList.toList();
        }
      }
    }, () {
      // return list;
    }, (c) {
      list = (list).where((e) => e.colorCheck(c)).toList();
    });

    return list;
  }
}
