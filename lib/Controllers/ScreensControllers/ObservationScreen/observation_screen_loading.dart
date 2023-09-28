import '../../../Loading/loading.dart';
import '../../../common_items.dart';
import '../../ButtonControllers/again_controller.dart';
import '../../ButtonControllers/basic_button_controller.dart';
import '../../ButtonControllers/deadline_controller.dart';
import '../../ButtonControllers/end_based_controller.dart';
import '../../ButtonControllers/note_controller.dart';
import '../../my_date_controller.dart';

class ObservationScreenLoading {
  int hasJustAdded = 0;

  ObservationScreenLoading(this._getCorrectList);

  final List Function(Type) _getCorrectList;

  final List<bool> _loaded = [false, false, false, false, false, false];

  bool doneLoading() => !_loaded.any((e) => !e);

  static final List<Future<List> Function(Loading)> _buttonGet = [
    (l) => l.getButtons<AgainAmountController>(),
    (l) => l.getButtons<AgainMonthController>(),
    (l) => l.getButtons<AgainWeekController>(),
    (l) => l.getButtons<AgainYearController>(),
    (l) => l.getButtons<DeadlineController>(),
    (l) => l.getButtons<NoteController>(),
  ];

  void loadListsFromStorage(Map<Type, List> allLists) {
    for (var list in allLists.entries) {
      list.value.clear();
    }
    for (int i = 0; i < _loaded.length; i++) {
      _loaded[i] = false;
      _buttonGet[i](loading).then((value) {
        if (value.isNotEmpty) {
          allLists[value.first.runtimeType]!.addAll(value);
        }
        _loaded[i] = true;
      });
    }
  }

  int getNewId(Type t) {
    var correctList = _getCorrectList(t);
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

  void _updateButton(
      BasicButtonController toAdd, void Function() setStateMethod) {
    loading.updateButton(toAdd);
    if (toAdd is EndBasedController) {
      toAdd.setToMakeNew();
    }
    List correctList = _getCorrectList(toAdd.runtimeType);
    var index = correctList.indexWhere((e) => toAdd.id == e.button.id);
    if (index == -1) return;
    correctList[index] = toAdd;
    setStateMethod();
  }

  void _addButton(BasicButtonController toAdd, void Function() setStateMethod) {
    List correctList = _getCorrectList(toAdd.runtimeType);
    if (toAdd is EndBasedController) {
      toAdd.setToMakeNew();
    }
    correctList.add(toAdd);
    loading.addButton(toAdd);
    setStateMethod();
  }

  ///will update if selected is the same type and same id as thing added
  void addOrUpdateButton(
      BasicButtonController controller, void Function() setStateMethod) {
    hasJustAdded++;
    if (_getCorrectList(controller.runtimeType)
        .any((e) => e.id == controller.id)) {
      _updateButton(controller, setStateMethod);
    } else {
      _addButton(controller, setStateMethod);
    }
  }

  void deleteSelected(
      void Function() setStateMethod, BasicButtonController? selectedButton) {
    if (selectedButton == null) return;
    loading.deleteButton(selectedButton);

    List correctList = _getCorrectList(selectedButton.runtimeType);
    correctList.removeWhere((e) => selectedButton.id == e.button.id);
    setStateMethod();
  }

  void skipButton(
      void Function() setStateMethod, BasicButtonController? selectedButton) {
    if (selectedButton == null ||
        selectedButton is SkippableEndBasedController) {
      return;
    }
    (selectedButton as SkippableEndBasedController)
        .makeNewSkip(selectedButton.dateController);
    _updateButton(selectedButton, setStateMethod);
  }

  void flipImportant(
      void Function() setStateMethod, BasicButtonController? selectedButton) {
    if (selectedButton == null) return;
    selectedButton.flipImportant();
    _updateButton(selectedButton, setStateMethod);
  }

  /// if there have been updates form or away from new just added sends true
  bool justAddedCheck(Map<Type, List<dynamic>> allLists) {
    MyDateController now = MyDateController.now();
    var hasJustAddedCalc = 0;
    for (var e in allLists.entries) {
      if (e.value.isNotEmpty && e.value.first is EndBasedController) {
        hasJustAddedCalc +=
            e.value.where((element) => element.wasJustAdded(now)).length;
      }
    }
    if (hasJustAdded != hasJustAddedCalc) {
      hasJustAdded = hasJustAddedCalc;
      return true;
    }
    return false;
  }

  void deleteList(List<BasicButtonController> toDelete) =>
      loading.deleteButtons(toDelete);

  void updateList(List<BasicButtonController> toUpdate) =>
      loading.deleteButtons(toUpdate);
}
