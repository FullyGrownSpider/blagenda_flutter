import 'package:blagenda_flutter_simple/Commons/store_able.dart';
import 'package:flutter/material.dart';

import '../Commons/Models/Buttons/again.dart';
import '../Commons/Models/Buttons/basic_button.dart';
import '../Commons/Models/Buttons/deadline.dart';
import '../Commons/Models/Buttons/weird_again.dart';
import '../Commons/Models/entity.dart';
import '../Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../Controllers/my_date_controller.dart';
import 'entity_notifier.dart';
import 'loading.dart';

class ButtonNotifier
    with ChangeNotifier
    implements StoreAbleNotifier<BasicButtonController> {
  static final List<Future<List<dynamic>> Function(Loading)> _toLoad = [
    (l) => l.getData<BasicButton>(),
    (l) => l.getData<Deadline>(),
    (l) => l.getData<AgainYearDay>(),
    (l) => l.getData<AgainWeekDay>(),
    (l) => l.getData<AgainAmountDay>(),
    (l) => l.getData<AgainWeird>(),
    (l) => l.getData<AgainMonthDay>()
  ];

  final EntityNotifier entities;

  bool hardPoint = false;

  @protected
  @visibleForTesting
  final List<BasicButtonController> buttons = [];

  static final Loading _loading = Loading();

  final List<bool> _loaded = [false, false, false, false, false, false, false];

  ButtonNotifier(this.entities);

  @override
  List<BasicButtonController> getData() => buttons;

  Future<void> init() async {
    for (int i = 0; i < _loaded.length; i++) {
      _loaded[i] = false;
      _toLoad[i](_loading).then((value) {
        if (value.isNotEmpty) {
          for (var tag in entities.tagsUsable()) {
            for (var c in value) {
              if (tag.data is TagObjectReference) {
                if (tag.data.type == c.runtimeType.toString() &&
                    c.id == tag.data.itd) {
                  c.entitied = tag.data.itd;
                }
              } else if (BasicButtonController.equals(
                  tag.data.button, c.button)) {
                c.entitied = tag.data.id;
              }
            }
          }
          buttons.addAll(value.cast<BasicButtonController>().toList());
        }
        _loaded[i] = true;
      });
    }
    while (_loaded.any((e) => !e)) {
      await Future.delayed(const Duration(milliseconds: 1));
    }
    notifyListeners();
  }

  @override
  void addOrUpdate(BasicButtonController but) {
    int index = buttons.indexWhere((e) => e.runtimeType == but.runtimeType && e.id == but.id);
    if (index != -1) {
      buttons.removeAt(index);
    }
    buttons.add(but);
    _loading.updateData(but.button);
    hardPoint = true;
    notifyListeners();
  }

  ///only have button controllers of the same type in list
  void addAll(List<BasicButtonController> butList) {
    buttons.addAll(butList);
    _loading.updateButtons(butList);
    hardPoint = true;
    notifyListeners();
  }

  @override
  void delete(BasicButtonController but) {
    buttons
        .removeWhere((e) => e.runtimeType == but.runtimeType && e.id == but.id);
    _loading.deleteButton(but);
    hardPoint = true;
    notifyListeners();
  }

  Future<void> dataSyncLowKey() =>
      _loading.downloadDatabaseFilesCarefully().then((x) {
        if (x) {
          init().then((x) {
            hardPoint = true;
            notifyListeners();
          });
        }
      });

  Future<void> dataSync() => _loading.downloadDatabaseFiles().then((x) {
        init().then((x) {
          hardPoint = true;
          notifyListeners();
        });
      });

  int getNewId(Type t) {
    var correctList = buttons.where((e) => e.runtimeType == t).toList();
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

  List<EndBasedController> getEndBasedData() =>
      buttons.whereType<EndBasedController>().toList();

  void flipImportant(BasicButtonController? selectedButton) {
    if (selectedButton == null) return;
    selectedButton.touched = true;
    selectedButton.flipImportant();
    addOrUpdate(selectedButton);
    hardPoint = false;
    notifyListeners();
  }

  void changeDays(
      BasicButtonController<BasicButton>? selectedButton, int amount) {
    if (selectedButton == null || selectedButton is! EndBasedController) return;
    selectedButton.touched = true;
    selectedButton.addOrRemoveDays(amount);
    addOrUpdate(selectedButton);
    hardPoint = false;
    notifyListeners();
  }

  void skipButton(SkippableEndBasedController selectedButton, int fromNow) {
    selectedButton.makeNewSkip(MyDateController.fromDaysFromNow(fromNow));
    addOrUpdate(selectedButton);
    hardPoint = false;
    notifyListeners();
  }
}

abstract class StoreAbleNotifier<t extends StoreAble> {
  List<t> getData();

  void delete(t delete);

  void addOrUpdate(t update);
}
