import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:flutter/material.dart';

import '../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'ObservationScreen/observation_screen_buttons.dart';
import 'ObservationScreen/observation_screen_loading.dart';
import 'ObservationScreen/observation_screen_options.dart';

class ObservationScreenController {
  late final ObservationScreenLoading _observationScreenLoading;
  final ObservationScreenOptions _observationScreenOptions = ObservationScreenOptions();
  late final ObservationScreenButtons _observationScreenButtons;

  ///lists used to store all buttons and used to .select the ones to display
  final List<BasicButtonController> _allLists = [];

  final List<EntityController> _entityList = [];

  ///needs to load first use doneLoading to check if done
  ObservationScreenController(Function(BasicButtonController) openEntityScreen) {
    _observationScreenLoading = ObservationScreenLoading();
    _observationScreenButtons = ObservationScreenButtons(openEntityScreen);
    _observationScreenLoading.loadEntityListFromStorage().then((v) {
      _entityList.clear();
      _entityList.addAll(v);
      _observationScreenLoading.loadListsFromStorage(_allLists, _entityList);
    });
  }

  List<Widget> getWidgetListNote(void Function() setStateMethod) =>
      _observationScreenButtons.getWidgetListNote(setStateMethod,
          _observationScreenOptions, _allLists.whereType<NoteController>().toList());

  List<Widget> getWidgetListEndBased(void Function() setStateMethod) =>
      _observationScreenButtons.getWidgetListEndBased(setStateMethod,
          ObservationScreenOptions.daysToShow, _allLists, _observationScreenOptions);

  void resetSearch(void Function() setStateMethod) =>
      _observationScreenOptions.resetSearch(setStateMethod, _resetCounters);

  Future<void> resetLists() async {
    while (!_observationScreenLoading.doneLoading()) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    _observationScreenButtons.updateEndbasedToCurrentDay(_allLists,
        _observationScreenLoading.deleteList, _observationScreenLoading.updateList);
  }

  void _resetCounters() => _observationScreenButtons.resetCounters();

  BasicButtonController? getSelectedButton() {
    if (_observationScreenButtons.idSelected == -1) return null;
    List correctList = _allLists
        .where((e) => e.runtimeType == _observationScreenButtons.typeOfSelected!)
        .toList();
    return correctList
        .firstWhere((e) => _observationScreenButtons.idSelected == e.button.id);
  }

  bool justAddedCheck() => _observationScreenButtons.justAddedCheck();

  bool doneLoading() => _observationScreenLoading.doneLoading();

  void loadListsFromStorage() =>
      _observationScreenLoading.loadListsFromStorage(_allLists, _entityList);

  int getNewId(Type t) => _observationScreenLoading.getNewId(t, _allLists);

  void addOrUpdateButton(
      BasicButtonController<BasicButton> c, void Function() resetScreen) {
    if (c is EndBasedController) {
      _observationScreenButtons.addNew(c.id, c.runtimeType);
    }
    _observationScreenLoading.addOrUpdateButton(c, resetScreen, _allLists);
  }

  void deleteSelected(void Function() resetScreen) {
    var selectedBut = getSelectedButton();
    if (selectedBut != null) {
      deleteButton(selectedBut, resetScreen);
    }
  }

  void deleteButton(BasicButtonController<BasicButton> c, void Function() resetScreen) {
    _observationScreenButtons.removeNew(c.id, c.runtimeType);
    _observationScreenLoading.deleteSelected(resetScreen, c, _allLists);
  }

  void skipButton(void Function() resetScreen) =>
      _observationScreenLoading.skipButton(resetScreen, getSelectedButton(), _allLists);

  void flipImportant(void Function() resetScreen) => _observationScreenLoading
      .flipImportant(resetScreen, getSelectedButton(), _allLists);

  List<Widget> getOptionButtons(void Function() setStateMethod) =>
      _observationScreenOptions.getOptionButtons(setStateMethod, _resetCounters);

  List<EndBasedController> getEndbasedData() =>
      _allLists.whereType<EndBasedController>().toList();

  List<EntityController> getEntities() => _entityList;

  void addOrUpdateEntity(EntityController c) {
    int index = _entityList.indexWhere((element) => element.id == c.id);
    if (index != -1) {
      _entityList.removeAt(index);
      if (c.tags.isEmpty) {
        _observationScreenLoading.deleteEntity(c, getEntities());
        return;
      }
      c.tagsAsReferences();
      _observationScreenLoading.updateData(c.myEntity);
    } else {
      if (c.tags.isEmpty) return;
      c.tagsAsReferences();
      _observationScreenLoading.storeData(c.myEntity);
    }
    _entityList.add(c);
  }

  int getNewEntityId() {
    _entityList.sort((a, b) => a.id.compareTo(b.id));
    for (int i = 0; i < _entityList.length; i++) {
      if (_entityList[i].id != i) {
        return i;
      }
    }
    return _entityList.length;
  }
}
