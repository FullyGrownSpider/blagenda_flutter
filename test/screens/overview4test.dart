import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/entity.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/observation_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/blagenda_uniform_button.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:blagenda_flutter_simple/Loading/entity_notifier.dart';
import 'package:flutter/material.dart';

///test copy of the overviewscreen
class Overview4Test {
  FakeButtonNotifier notifier;
  FakeEntityNotifier entityNotifier;
  late ObservationScreenController controller =
      ObservationScreenController((_) async {}, notifier);

  Overview4Test(this.notifier, this.entityNotifier);

  void addOrUpdate(ce) => notifier.addOrUpdate(ce);
}

///agressivly search for text in text buttons in the given widget (the dynamic is to do sneaky reflection)
List<String?> textButtonSearch(dynamic victim, Type needBlagenda) {
  switch (needBlagenda){
  case (const (TextButton)) :
    if (victim is TextButton && victim.child is Text) {
      return [(victim.child as Text).data];
    }
    break;
    case(const (BlagendaUniformButton)) :
      if (victim is BlagendaUniformButton) {
        return [victim.text()];
      }
      break;
    case(const (TextField)) :
      if (victim is TextField) {
        return [(victim.controller!.text)];
      }
      break;
    default : throw (Exception('not testable yet'));
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

class FakeButtonNotifier extends ButtonNotifier {
  FakeButtonNotifier(super.entities);

  @override
  Future<void> init() async {
    notifyListeners();
  }

  // @override TODO something changed it doesnt work now with testing
  // void addOrUpdate(BasicButtonController but) {
  //   buttons.removeWhere((e) => e.runtimeType == but.runtimeType && e.id == but.id);
  //   buttons.add(but);
  //   hardPoint = true;
  //   notifyListeners();
  // }

  ///only have button controllers of the same type in list
  @override
  void addAll(List<BasicButtonController> butList) {
    buttons.addAll(butList);
    hardPoint = true;
    notifyListeners();
  }

  @override
  void delete(BasicButtonController but) {
    buttons
        .removeWhere((e) => e.runtimeType == but.runtimeType && e.id == but.id);
    hardPoint = true;
    notifyListeners();
  }

  @override
  Future<void> dataSyncLowKey() async {
    hardPoint = true;
    notifyListeners();
  }

  @override
  Future<void> dataSync() async {
    hardPoint = true;
    notifyListeners();
  }

  @override
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

  @override
  List<EndBasedController> getEndBasedData() =>
      buttons.whereType<EndBasedController>().toList();

  @override
  void flipImportant(BasicButtonController? selectedButton) {
    if (selectedButton == null) return;
    selectedButton.touched = true;
    selectedButton.flipImportant();
    addOrUpdate(selectedButton);
    hardPoint = false;
    notifyListeners();
  }

  @override
  void changeDays(
      BasicButtonController<BasicButton>? selectedButton, int amount) {
    if (selectedButton == null || selectedButton is! EndBasedController) return;
    selectedButton.touched = true;
    selectedButton.addOrRemoveDays(amount);
    addOrUpdate(selectedButton);
    hardPoint = false;
    notifyListeners();
  }

  @override
  void skipButton(SkippableEndBasedController selectedButton, int fromNow) {
    selectedButton.makeNewSkip(MyDateController.fromDaysFromNow(fromNow));
    addOrUpdate(selectedButton);
    hardPoint = false;
    notifyListeners();
  }
}

class FakeEntityNotifier extends EntityNotifier {
  final List<EntityController> _entities = [];

  @override
  Future<void> init() async {
    notifyListeners();
  }

  @override
  List<Tag> tagsUsable() => _entities
      .map((e) => e.tags.where((t) => t.data is! String).toList())
      .expand((element) => element)
      .toList(growable: false);

  @override
  void addOrUpdate(EntityController entity) {
    _entities.add(entity);
    notifyListeners();
  }

  @override
  void delete(EntityController entity) {
    _entities.removeWhere(
        (e) => e.runtimeType == entity.runtimeType && e.id == entity.id);
    notifyListeners();
  }

  @override
  int getNewEntityId() {
    _entities.sort((a, b) => a.id.compareTo(b.id));
    for (int i = 0; i < _entities.length; i++) {
      if (_entities[i].id != i) {
        return i;
      }
    }
    return _entities.length;
  }

  @override
  List<EntityController> getData() => _entities;
}
