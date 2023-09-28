import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/note_controller.dart';
import 'package:flutter/material.dart';

import 'ObservationScreen/observation_screen_loading.dart';
import 'ObservationScreen/observation_screen_options.dart';
import 'ObservationScreen/observation_screen_buttons.dart';

class ObservationScreenController {
  late final ObservationScreenLoading _observationScreenLoading;
  final ObservationScreenOptions _observationScreenOptions =
      ObservationScreenOptions();
  late final ObservationScreenButtons _observationScreenButtons;

  ///lists used to store all buttons and used to .select the ones to display
  final Map<Type, List> _allLists = {
    AgainAmountController: <AgainAmountController>[],
    AgainMonthController: <AgainMonthController>[],
    AgainWeekController: <AgainWeekController>[],
    AgainYearController: <AgainYearController>[],
    DeadlineController: <DeadlineController>[],
    NoteController: <NoteController>[]
  };

  ///needs to load first use doneLoading to check if done
  ObservationScreenController() {
    _observationScreenLoading = ObservationScreenLoading(_getCorrectList);
    _observationScreenButtons = ObservationScreenButtons();
    _observationScreenLoading.loadListsFromStorage(_allLists);
  }

  List<Widget> getWidgetListNote(void Function() setStateMethod) =>
      _observationScreenButtons.getWidgetListNote(
          setStateMethod,
          _observationScreenOptions,
          _getCorrectList(NoteController) as List<NoteController>);

  List<Widget> getWidgetListEndBased(void Function() setStateMethod) =>
      _observationScreenButtons.getWidgetListEndBased(
          setStateMethod,
          ObservationScreenOptions.daysToShow,
          _allLists,
          _observationScreenOptions);

  ///reset screen to default
  void resetSearch(void Function() setStateMethod) =>
      _observationScreenOptions.resetSearch(setStateMethod, _resetCounters);

  void resetLists() {
    for (var e in _allLists.entries) {
      _observationScreenButtons.updateEndbasedToCurrentDay(
          e.value as List<BasicButtonController>,
          _getCorrectList,
          _observationScreenLoading.deleteList,
          _observationScreenLoading.updateList);
    }
  }

  void _resetCounters() => _observationScreenButtons.resetCounters();

  BasicButtonController? getSelectedButton() {
    if (_observationScreenButtons.idSelected == -1) return null;
    List correctList =
        _getCorrectList(_observationScreenButtons.typeOfSelected!);
    return correctList
        .firstWhere((e) => _observationScreenButtons.idSelected == e.button.id);
  }

  List _getCorrectList(Type t) => _allLists[t]!;

  bool justAddedCheck() => _observationScreenLoading.justAddedCheck(_allLists);

  void setAllToNotNew() {
    _allLists.forEach((key, value) {
      if (key != EndBasedController) return;
      for (var button in value) {
        button.timeWhenNotNewItemAnymore = null;
      }
    });
  }

  bool doneLoading() => _observationScreenLoading.doneLoading();

  void loadListsFromStorage() =>
      _observationScreenLoading.loadListsFromStorage(_allLists);

  int getNewId(Type t) => _observationScreenLoading.getNewId(t);

  void addOrUpdateButton(
          BasicButtonController<BasicButton> c, void Function() resetScreen) =>
      _observationScreenLoading.addOrUpdateButton(c, resetScreen);

  void deleteSelected(void Function() resetScreen) => _observationScreenLoading
      .deleteSelected(resetScreen, getSelectedButton());

  void skipButton(void Function() resetScreen) =>
      _observationScreenLoading.skipButton(resetScreen, getSelectedButton());

  void flipImportant(void Function() resetScreen) =>
    _observationScreenLoading.flipImportant(resetScreen, getSelectedButton());

  List<Widget> getOptionButtons(void Function() setStateMethod) =>
      _observationScreenOptions.getOptionButtons(
          setStateMethod, _resetCounters);
}
