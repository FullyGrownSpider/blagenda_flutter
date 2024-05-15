import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:flutter/cupertino.dart';

import '../../../Commons/Models/Buttons/weird_again.dart';
import '../../../Commons/Models/entity.dart';
import '../../../Loading/mix_loading.dart';
import '../../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../../ObjectControllers/ButtonControllers/end_based_controller.dart';

class ObservationScreenLoading with loading {
  final List<bool> _loaded = [false, false, false, false, false, false, false];

  ObservationScreenLoading();

  static final List<Future<List<dynamic>> Function(loading)> _toLoad = [
    (l) => l.getData<BasicButton>(),
    (l) => l.getData<Deadline>(),
    (l) => l.getData<AgainYearDay>(),
    (l) => l.getData<AgainWeekDay>(),
    (l) => l.getData<AgainAmountDay>(),
    (l) => l.getData<AgainWeird>(),
    (l) => l.getData<AgainMonthDay>()
  ];

  bool doneLoading() => !_loaded.any((e) => !e);

  ///async method will fill parameter list of buttons
  void loadListsFromStorage(
      List<BasicButtonController> allLists, List<EntityController> entities) {
    var tagsUseAble = entities
        .map((e) => e.tags.where((t) => t.data is! String).toList())
        .expand((element) => element)
        .toList(growable: false);
    allLists.clear();
    for (int i = 0; i < _loaded.length; i++) {
      _loaded[i] = false;
      _toLoad[i](this).then((value) {
        if (value.isNotEmpty) {
          for (var tag in tagsUseAble) {
            for (var c in value) {
              if (tag.data is TagObjectReference) {
                if (tag.data.type == c.runtimeType.toString() && c.id == tag.data.itd) {
                  c.entitied = tag.data.itd;
                }
              } else if (BasicButtonController.equals(tag.data.button, c.button)) {
                c.entitied = tag.data.id;
              }
            }
          }
          allLists.addAll(value.cast<BasicButtonController>().toList());
        }
        _loaded[i] = true;
      });
    }
  }

  Future<List<EntityController>> loadEntityListFromStorage() async {
    return (await getData<Entity>()).cast<EntityController>().toList();
  }

  int getNewId(Type t, List<BasicButtonController> allItems) {
    var correctList = allItems.where((e) => e.runtimeType == t).toList();
    if (correctList.isNotEmpty) {
      correctList.sort((a, b) => a.id.compareTo(b.id));
      for (int i = 0; i < correctList.length; i++) {
        if (correctList[i].button.id != i) {
          return i;
        }
      }
    }
    return correctList.length;
  }

  @visibleForTesting
  void storeUpdateButton(BasicButtonController toAdd, void Function() setStateMethod,
      List<BasicButtonController> allItems) {
    updateData(toAdd.button);
    var index = allItems
        .indexWhere((e) => toAdd.id == e.id && toAdd.runtimeType == e.runtimeType);
    if (index == -1) return;
    allItems[index] = toAdd;
    setStateMethod();
  }

  @visibleForTesting
  void storeAddButton(BasicButtonController toAdd, void Function() setStateMethod,
      List<BasicButtonController> allItems) {
    allItems.add(toAdd);
    storeData(toAdd.button);
    setStateMethod();
  }

  ///will update if selected is the same type and same id as thing added
  void addOrUpdateButton(BasicButtonController controller, void Function() setStateMethod,
      List<BasicButtonController> allItems) {
    controller.touched = true;
    if (allItems
        .where((e) => e.runtimeType == controller.runtimeType)
        .any((e) => e.id == controller.id)) {
      storeUpdateButton(controller, setStateMethod, allItems);
    } else {
      storeAddButton(controller, setStateMethod, allItems);
    }
  }

  void deleteSelected(void Function() setStateMethod,
      BasicButtonController selectedButton, List<BasicButtonController> allItems) {
    deleteButton(selectedButton).then((value) {
      //readd if delete didn't do its "thing"
      if (!value) {
        allItems.add(selectedButton);
        setStateMethod();
      }
    });
    allItems.removeWhere(
        (e) => selectedButton.id == e.id && e.runtimeType == selectedButton.runtimeType);
    setStateMethod();
  }

  void skipButton(void Function() setStateMethod, BasicButtonController? selectedButton,
      List<BasicButtonController> allItems) {
    if (selectedButton == null) {
      return;
    } else if (selectedButton is! SkippableEndBasedController) {
      deleteSelected(setStateMethod, selectedButton, allItems);
    } else {
      (selectedButton).makeNewSkip(selectedButton.dateController);
      storeUpdateButton(selectedButton, setStateMethod, allItems);
    }
  }

  void flipImportant(void Function() setStateMethod,
      BasicButtonController? selectedButton, List<BasicButtonController> allItems) {
    if (selectedButton == null) return;
    selectedButton.touched = true;
    selectedButton.flipImportant();
    storeUpdateButton(selectedButton, setStateMethod, allItems);
  }

  void deleteList(List<BasicButtonController> toDelete) => deleteButtons(toDelete);

  void updateList(List<BasicButtonController> toUpdate) => updateButtons(toUpdate);

  void changeDays(
      void Function() setStateMethod,
      BasicButtonController<BasicButton>? selectedButton,
      List<BasicButtonController> allItems,
      int amount) {
    if (selectedButton == null || selectedButton is! EndBasedController) return;
    selectedButton.touched = true;
    selectedButton.addOrRemoveDays(amount);
    storeUpdateButton(selectedButton, setStateMethod, allItems);
  }
}
