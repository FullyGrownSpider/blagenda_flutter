import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/mix_button_creator.dart';
import 'package:flutter/material.dart';

import '../../../common_items.dart';
import '../../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../../ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../../blagenda_uniform_button.dart';

class ObservationScreenOptions with ButtonCreator, ChangeNotifier {
  static const int daysToShow = 6;
  @visibleForTesting
  static const List<int> possibleExtraDays = [30, 14];

  ///-1 no color selected
  ///-2 show everything in a list
  @visibleForTesting
  int chosenColor = -1;

  ///used to display more days or less days
  int daysToShowNow = daysToShow;

  ///the buttons to select the color to only show
  List<Widget> getOptionButtons(Function() resetCounters) {
    List<Widget> items = [];
    items.add(const Text('Display Options', style: bigTextStyle));
    items.addAll(globalCreateColorButtons(chosenColor,
      (col) => colorPressed(usedColors.indexOf(col), resetCounters)));
    items.addAll(addAsRow((i) => _createCounterButton(i, resetCounters),
        possibleExtraDays.length));
    items.add(_createDisplayAllEndBasedButtonsButton(resetCounters));
    return items;
  }

  Widget _createDisplayAllEndBasedButtonsButton(
      Function() resetCounters) =>
      BlagendaUniformButton(-2 == chosenColor, usedColors.first, 'Show all', () {
        resetCounters();
        daysToShowNow = daysToShow;
        if (-2 == chosenColor) {
          chosenColor = -1;
        } else {
          chosenColor = -2;
        }
        notifyListeners();
      });

  Widget _createCounterButton(
      int index, Function() resetCounters) =>
      BlagendaUniformButton(daysToShowNow == possibleExtraDays[index], usedColors.first,
          'Show next ${possibleExtraDays[index].toString()} days', () {
        chosenColor = -1;
        if (daysToShowNow == possibleExtraDays[index]) {
          daysToShowNow = daysToShow;
        } else {
          daysToShowNow = possibleExtraDays[index];
        }
        resetCounters();
        notifyListeners();
      });

  @visibleForTesting
  void colorPressed(int index, Function() resetCounters) {
    daysToShowNow = daysToShow;
    if (chosenColor == index) {
      chosenColor = -1;
    } else {
      chosenColor = index;
    }
    resetCounters();
    notifyListeners();
  }

  void resetSearch(Function() resetCounters) {
    if (chosenColor == -1 && daysToShowNow == daysToShow) return;
    chosenColor = -1;
    daysToShowNow = daysToShow;
    resetCounters();
    notifyListeners();
  }

  void pickCorrectOption(
      void Function() defaultListMaker,
      void Function() showEverythingListMaker,
      void Function(Color) colorChoiceListMaker) {
    if (chosenColor > -1) {
      colorChoiceListMaker(usedColors[chosenColor]);
    } else if (chosenColor == -2) {
      showEverythingListMaker();
    } else {
      defaultListMaker();
    }
  }

  bool _shouldGoIn(
          EndBasedController eb, bool Function(EndBasedController) wasJustAdded) =>
      eb.daysLeft <= daysToShowNow + 7 || wasJustAdded(eb);

  List<BasicButtonController> goesInList(List<BasicButtonController> allItems,
      bool Function(EndBasedController) wasJustAdded) {
    List<BasicButtonController> returnList = [];
    pickCorrectOption(() {
      //show x days
      var list = allItems.whereType<EndBasedController>();
      returnList.addAll(list.where((e) => _shouldGoIn(e, wasJustAdded)));
      if (daysToShow == daysToShowNow) {
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
