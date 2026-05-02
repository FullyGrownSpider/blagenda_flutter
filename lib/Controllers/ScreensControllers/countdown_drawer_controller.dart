import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common_items.dart';
import '../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../ObjectControllers/ButtonControllers/note_controller.dart';
import '../blagenda_uniform_button.dart';
import 'ObservationScreen/observation_screen_options.dart';

class CountDownDrawerController {
  List<Widget> loadSortFillImportant(
      List<EndBasedController> Function() getEndBasedButtons,
      Widget Function(List<Widget> list) style,
      void Function(BasicButtonController) addOrUpdateButton,
      List<dynamic> Function() getNotes,
      [bool extraLines = true]) {
    List<Widget> widgetList = [];
    List<EndBasedController> endButtons = [];
    List<BasicButtonController> notes = [];
    var walkList = getEndBasedButtons();
    endButtons.addAll(walkList.where((e) => e.important && e.daysLeft > -1));
    var complicatedList = walkList
        .where((e) =>
            e.important && e.daysLeft == -1 && e is SkippableEndBasedController)
        .toList();
    if (complicatedList.isNotEmpty) {
      for (int i = 0; i < 400; i++) {
        for (int ii = 0; ii < complicatedList.length; ii++) {
          if (complicatedList[ii].isHappeningOnDayFromNow(i)) {
            endButtons.add((complicatedList[ii] as SkippableEndBasedController)
                .createNew(i));
            complicatedList.removeAt(ii);
          }
        }
        if (complicatedList.isEmpty) break;
      }
    }

    endButtons.sort();
    notes.addAll(
        (getNotes()).where((e) => e.important).toList().cast<NoteController>());
    widgetList.clear();
    for (var note in notes) {
      widgetList.add(style([
        BlagendaUniformButton(
            note.color,
            () => BasicButtonController.displayGenericText(note.job, 25),
            () => _createUnimportantButton(note, addOrUpdateButton))
      ]));
      widgetList.add(bigSplitterTextField);
      widgetList.add(splitterTextField);
      widgetList.add(splitterTextField);
    }
    for (var but in endButtons) {
      bool displayAble =
          ObservationScreenOptions.daysToShow < but.daysLeft + 1 ||
              (but is SkippableEndBasedController &&
                  ObservationScreenOptions.daysToShow < but.altLeft + 1);
      widgetList.add(style([
        BlagendaUniformButton(
            displayAble ? but.color : lerpIt(but.color),
            () => BasicButtonController.displayGenericText(but.gettingTheStringShort(), 25),
            () => _createUnimportantButton(but, addOrUpdateButton)),
        if (displayAble) _createCountDownText(but)
      ]));
      widgetList.add(bigSplitterTextField);
      widgetList.add(splitterTextField);
      widgetList.add(splitterTextField);
    }
    if (extraLines) {
      widgetList.add(bigSplitterTextField);
      widgetList.add(bigSplitterTextField);
      widgetList.add(bigSplitterTextField);
    }
    return widgetList;
  }

  Function _createUnimportantButton(BasicButtonController it,
      void Function(BasicButtonController) addOrUpdateButton) {
    return () {
      it.flipImportant();
      addOrUpdateButton(it);
    };
  }

  Widget _createCountDownText(EndBasedController it) {
    if (it is SkippableEndBasedController) {
      return BlagendaUniformButton(
          usedColors[4], () => 'In ${it.altLeft} days.', () {});
    }
    return BlagendaUniformButton(
        usedColors[4], () => 'In ${it.daysLeft} days.', () {});
  }

  Widget updateButtonsButtons(
      void Function() flipImportant, addDays, removeDays) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BlagendaUniformButton(
            usedColors[4], () => 'Important Flip', flipImportant),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          BlagendaUniformButton(usedColors[4], () => '↑ Day ↑', removeDays),
          BlagendaUniformButton(usedColors[4], () => '↓ Day ↓', addDays),
        ])
      ],
    );
  }
}
