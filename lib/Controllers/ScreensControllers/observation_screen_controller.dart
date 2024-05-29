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
  @visibleForTesting
  late ObservationScreenLoading observationScreenLoading;
  @visibleForTesting
  final ObservationScreenOptions observationScreenOptions = ObservationScreenOptions();
  @visibleForTesting
  late final ObservationScreenButtons observationScreenButtons;

  ///lists used to store all buttons and used to .select the ones to display
  @visibleForTesting
  final List<BasicButtonController> allLists = [];

  @visibleForTesting
  final List<EntityController> entityList = [];

  ///needs to load first use doneLoading to check if done
  ObservationScreenController(Future Function(BasicButtonController) openEntityScreen,
      Future Function(BasicButtonController) openButtonEdit) {
    observationScreenLoading = ObservationScreenLoading();
    observationScreenButtons = ObservationScreenButtons(openEntityScreen, openButtonEdit);
    observationScreenLoading.loadEntityListFromStorage().then((v) {
      entityList.clear();
      entityList.addAll(v);
      observationScreenLoading.loadListsFromStorage(allLists, entityList);
    });
  }

  void deselect() => observationScreenButtons.resetCounters();

  List<Widget> getWidgetListNote(void Function() setStateMethod) =>
      observationScreenButtons.getWidgetListNote(setStateMethod, observationScreenOptions,
          allLists.whereType<NoteController>().toList());

  List<Widget> getWidgetListEndBased(void Function() setStateMethod) =>
      observationScreenButtons.getWidgetListEndBased(setStateMethod,
          ObservationScreenOptions.daysToShow, allLists, observationScreenOptions);

  void resetSearch(void Function() setStateMethod) =>
      observationScreenOptions.resetSearch(setStateMethod, _resetCounters);

  Future<void> resetLists() async {
    while (!observationScreenLoading.doneLoading()) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    observationScreenButtons.updateEndbasedToCurrentDay(allLists,
        observationScreenLoading.deleteList, observationScreenLoading.updateList);
  }

  void _resetCounters() => observationScreenButtons.resetCounters();

  BasicButtonController? getSelectedButton() {
    if (observationScreenButtons.idSelected == -1) return null;
    List correctList = allLists
        .where((e) => e.runtimeType == observationScreenButtons.typeOfSelected!)
        .toList();
    return correctList
        .firstWhere((e) => observationScreenButtons.idSelected == e.button.id);
  }

  bool justAddedCheck() => observationScreenButtons.justAddedCheck();

  bool doneLoading() => observationScreenLoading.doneLoading();

  void loadListsFromStorage() =>
      observationScreenLoading.loadListsFromStorage(allLists, entityList);

  int getNewId(Type t) => observationScreenLoading.getNewId(t, allLists);

  void addOrUpdateButton(
      BasicButtonController<BasicButton> c, void Function() resetScreen) {
    if (c is EndBasedController) {
      observationScreenButtons.addNew(c.id, c.runtimeType);
    }
    observationScreenLoading.addOrUpdateButton(c, allLists);
    deselect();
    resetScreen();
  }

  void deleteSelected(void Function() resetScreen) {
    var selectedBut = getSelectedButton();
    if (selectedBut != null) {
      deleteButton(selectedBut, resetScreen);
      deselect();
    }
  }

  void deleteButton(BasicButtonController<BasicButton> c, void Function() resetScreen) {
    observationScreenButtons.removeNew(c.id, c.runtimeType);
    observationScreenLoading.deleteSelected(c, allLists);
    deselect();
    resetScreen();
  }

  void skipButton(void Function() resetScreen) {
    observationScreenLoading.skipButton(
        getSelectedButton(), allLists, observationScreenButtons.fromNowSelect);
    resetScreen();
  }

  void flipImportant(void Function() resetScreen) {
    observationScreenLoading.flipImportant(getSelectedButton(), allLists);
    resetScreen();
  }

  void addOrRemoveDay(void Function() resetScreen, int amount) {
    observationScreenLoading.changeDays(getSelectedButton(), allLists, amount);
    resetScreen();
  }

  List<Widget> getOptionButtons(void Function() setStateMethod) =>
      observationScreenOptions.getOptionButtons(setStateMethod, _resetCounters);

  List<EndBasedController> getEndbasedData() =>
      allLists.whereType<EndBasedController>().toList();

  List<EntityController> getEntities() => entityList;

  void addOrUpdateEntity(EntityController c) {
    int index = entityList.indexWhere((element) => element.id == c.id);
    if (index != -1) {
      entityList.removeAt(index);
      if (c.tags.isEmpty) {
        observationScreenLoading.deleteEntity(c, getEntities());
        return;
      }
      c.tagsAsReferences();
      observationScreenLoading.updateData(c.myEntity);
    } else {
      if (c.tags.isEmpty) return;
      c.tagsAsReferences();
      observationScreenLoading.storeData(c.myEntity);
    }
    entityList.add(c);
    deselect();
  }

  int getNewEntityId() {
    entityList.sort((a, b) => a.id.compareTo(b.id));
    for (int i = 0; i < entityList.length; i++) {
      if (entityList[i].id != i) {
        return i;
      }
    }
    return entityList.length;
  }
}
