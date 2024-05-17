import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/ObservationScreen/observation_screen_loading.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/observation_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/blagenda_uniform_button.dart';
import 'package:blagenda_flutter_simple/Controllers/countdown_drawer.dart';
import 'package:blagenda_flutter_simple/Controllers/main_drawer.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';

///test copy of the overviewscreen
class Overview4Test {
  int lastHour = 0;
  List<BasicButtonController> dataFromLoading;
  List<EntityController> entityDataFromLoading;

  Function(Function()) syncActionLowKey;

  Overview4Test(this.syncActionLowKey, this.dataFromLoading, this.entityDataFromLoading) {
    controller = ObservationScreenController(_nothing, _nothing);
    controller.observationScreenLoading = ObservationScreenLoadingTest();
    controller.allLists.addAll(dataFromLoading);
    controller.entityList.addAll(entityDataFromLoading);
    drawer = MainDrawer(
        getButton,
        addOrUpdate,
        delete,
        skipButton,
        getNewId,
        getNewEntityId,
        _fullReset,
        getEndbasedData,
        getEntities,
        getButtonCopy,
        getEntityCopy);
    countDownDrawer = CountdownDrawer(addOrUpdate, _fullReset, getEndbasedData,
        flipImportant, getButton, () => addOrRemoveDays(1), () => addOrRemoveDays(-1));
    _fill();
  }

  void timerTick([bool force = false]) {
    bool awns = MyDateController.didDayPass();
    //requiresResetDate also resets last look time its semi important that its run
    if (controller.justAddedCheck() || awns || force) {
      if (awns || force) {
        MyDateController.resetDate();
        controller.resetLists().then((value) {
          _resetScreen();
          lastHour = MyDateController.lookTime.hour;
          syncActionLowKey(_reloadData);
        });
      } else {
        _resetScreen();
      }
    } else if (MyDateController.didHourPass(lastHour)) {
      lastHour = MyDateController.lookTime.hour;
      syncActionLowKey(_reloadData);
    }
  }

  late final MainDrawer drawer;
  late final CountdownDrawer countDownDrawer;
  late final ObservationScreenController controller;
  final List<Widget> centerChildren = [];
  final List<Widget> centerOptionsButton = [];

  void _reloadData() {
    controller.allLists
      ..clear()
      ..addAll(dataFromLoading);
    controller.entityList
      ..clear()
      ..addAll(entityDataFromLoading);
    _fill();
  }

  void _fill() async {
    while (!controller.doneLoading()) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    _resetButtons();
    _resetScreen();
  }

  void _fullReset() {
    _resetButtons();
    _resetScreen();
  }

  void _resetScreen() {
    centerChildren.clear();
    centerChildren.addAll(controller.getWidgetListEndBased(_resetScreen));
    var notes = controller.getWidgetListNote(_resetScreen);
    if (notes.isNotEmpty) centerChildren.addAll(notes);
    centerChildren.addAll((centerOptionsButton));
  }

  void _resetButtons() {
    centerOptionsButton.clear();
    centerOptionsButton.addAll(controller.getOptionButtons(() {
      _fullReset();
    }));
  }

  int getNewId(Type t) => controller.getNewId(t);

  int getNewEntityId() => controller.getNewEntityId();

  BasicButtonController? getButton() => controller.getSelectedButton();

  void addOrUpdate(dynamic c) {
    if (c is EntityController) {
      controller.addOrUpdateEntity(c);
      return;
    }
    if (c is! BasicButtonController) throw Exception('what did you do?');
    if (c.touched) {
      controller.deleteButton(c, _resetScreen);
    } else {
      controller.addOrUpdateButton(c, _resetScreen);
    }
  }

  void delete() => controller.deleteSelected(_resetScreen);

  void skipButton() => controller.skipButton(_resetScreen);

  void flipImportant() => controller.flipImportant(_resetScreen);

  void addOrRemoveDays(int amount) => controller.addOrRemoveDay(_resetScreen, amount);

  List<EndBasedController> getEndbasedData() => controller.getEndbasedData();

  List<EntityController> getEntities() => controller.getEntities();

  Future<EndBasedController> getButtonCopy(EndBasedController toFind) async => controller
      .getEndbasedData()
      .firstWhere((e) => e.id == toFind.id && e.runtimeType == toFind.runtimeType);

  Future<EntityController> getEntityCopy(EntityController toFind) async =>
      controller.getEntities().firstWhere((e) => e.id == toFind.id);

  Future<void> _nothing(dynamic _) async {}
}

class ObservationScreenLoadingTest extends ObservationScreenLoading {
  List<BasicButtonController> buttonsStore = [];
  List<EntityController> entitiesStore = [];
  bool started = false;

  @override
  void loadListsFromStorage(
      List<BasicButtonController> allLists, List<EntityController> entities) {
    if (!started) {
      buttonsStore.addAll(allLists);
      entitiesStore.addAll(entities);
      started = true;
      return;
    }
    allLists.clear();
    allLists.addAll(buttonsStore);
    entities.clear();
    entities.addAll(entitiesStore);
  }

  @override
  void storeUpdateButton(BasicButtonController toAdd, void Function() setStateMethod,
      List<BasicButtonController> allItems) {
    allItems.removeWhere(
        (element) => element.id == toAdd.id && element.runtimeType == toAdd.runtimeType);
    buttonsStore.removeWhere(
        (element) => element.id == toAdd.id && element.runtimeType == toAdd.runtimeType);
    storeAddButton(toAdd, setStateMethod, allItems);
  }

  @override
  void storeAddButton(BasicButtonController toAdd, void Function() setStateMethod,
      List<BasicButtonController> allItems) {
    buttonsStore.add(toAdd);
    allItems.add(toAdd);
  }

  @override
  bool doneLoading() => true;

  @override
  Future<List<EntityController>> loadEntityListFromStorage() async {
    return entitiesStore;
  }
}

///agressivly search for text in text buttons in the given widget (the dynamic is to do sneaky reflection)
List<String?> textButtonSearch(dynamic victim, bool needBlagenda) {
  if (!needBlagenda && victim is TextButton && victim.child is Text) {
    return [(victim.child as Text).data];
  }
  if (needBlagenda && victim is BlagendaUniformButton) {
    return [victim.text];
  }
  try {
    return textButtonSearch(victim.child, needBlagenda);
  } catch (_) {}
  try {
    var children = victim.children;
    var myList = <String?>[];
    for (var child in children) {
      myList.addAll(textButtonSearch(child, needBlagenda));
    }
    return myList;
  } catch (_) {}
  return [];
}
