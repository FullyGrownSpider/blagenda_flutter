import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/ObservationScreen/observation_screen_options.dart';
import 'package:flutter/cupertino.dart';

import '../../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../../ObjectControllers/ButtonControllers/deadline_controller.dart';
import '../../ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../../ObjectControllers/ButtonControllers/note_controller.dart';
import '../../blagenda_uniform_button.dart';
import '../../my_date_controller.dart';
import '../mix_button_creator.dart';
import '../mix_day_creator.dart';

class ObservationScreenButtons with dayCreator, buttonCreator {
  ///the index used to give every button a selection ID
  int _globalCounter = -1;

  ///the selected counter
  int clicked = -1;

  ///the previous selected counter
  int previouslyClicked = -1;

  ///id of button to update when updating
  int idSelected = -1;

  ///keep the data of all the new things
  final Map<_NewRef, MyDateController> _newThings = {};

  int hasJustAdded = 0;

  ///button type of the selected index
  Type? typeOfSelected;

  ///button type of the selected index
  Type? previousTypeOfSelected;

  final Function(BasicButtonController) _openEntityEdit;

  ObservationScreenButtons(this._openEntityEdit);

  void updateEndbasedToCurrentDay(
      List<BasicButtonController> allItems,
      void Function(List<BasicButtonController>) delete,
      void Function(List<BasicButtonController>) update) {
    var itemsToCheck = allItems.whereType<EndBasedController>().toList();
    for (var element in itemsToCheck) {
      (element).rebuild();
    }
    List<EndBasedController> itemsToChange =
        itemsToCheck.where((e) => e.requiresChange).toList();
    delete(itemsToChange.whereType<DeadlineController>().toList());
    allItems.removeWhere((e) => e is DeadlineController && e.requiresChange);
    delete(itemsToChange
        .where((e) => e is SkippableEndBasedController && e.wantDeleteMe())
        .toList());
    update(itemsToChange
        .where((e) => e is SkippableEndBasedController && !e.wantDeleteMe())
        .toList());
  }

  List<Widget> getWidgetListNote(void Function() setStateMethod,
      ObservationScreenOptions options, List<BasicButtonController> notesList) {
    notesList = options.goesInList(notesList, wasJustAdded);
    List<Widget> items = [];
    if (notesList.isNotEmpty) {
      notesList = NoteController.chosenSort(
          notesList.cast<NoteController>(), BasicButtonController.maxValueCheck);
      items.add(const Text('Notes', style: bigTextStyle));
      items.addAll(addAsRow(
          (i) => _createButtonBase(notesList[i], setStateMethod), notesList.length, (i) {
        return notesList[i].theStringLongestLength;
      }, BasicButtonController.maxValueCheck));
    }
    return items;
  }

  void resetCounters() => clicked = idSelected = -1;

  void _clickOnButton(
      int index, void Function() setStateMethod, BasicButtonController e) {
    if (clicked == index) {
      clicked = -1;
    } else {
      clicked = index;
    }
    if (e.entitied != -1 &&
        idSelected != e.id &&
        typeOfSelected != e.runtimeType &&
        previouslyClicked == e.id &&
        previousTypeOfSelected == e.runtimeType) {
      //double click
      _openEntityEdit(e);
      previouslyClicked = -1;
      previousTypeOfSelected = null;
    } else if (idSelected != e.id || typeOfSelected != e.runtimeType) {
      //selecting click
      clicked = index;
      previouslyClicked = idSelected = e.id;
      previousTypeOfSelected = typeOfSelected = e.runtimeType;
    } else {
      //deselecting click
      clicked = -1;
      idSelected = -1;
      typeOfSelected = null;
    }
    setStateMethod();
  }

  List<Widget> getWidgetListEndBased(void Function() setStateMethod, int daysToShow,
      List<dynamic> allLists, ObservationScreenOptions options) {
    List<EndBasedController> everythingToShow = options
        .goesInList(allLists.whereType<EndBasedController>().toList(), wasJustAdded)
        .whereType<EndBasedController>()
        .toList();
    List<Widget> againDeadlineDisplayList = [];
    if (everythingToShow.isEmpty) _emptyDay(daysToShow);
    everythingToShow.sort();
    options.pickCorrectOption(
      () {
        List<EndBasedController> newList = [];
        if (_newThings.isNotEmpty) {
          newList.addAll(_newThings.keys
              .map((k) => everythingToShow.firstWhere((e) => k.compare(e)))
              .where((e) => e.daysLeft >= daysToShow));
          newList.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
        }
        againDeadlineDisplayList.addAll(_createEndBasedDayList(
            setStateMethod,
            MyDateController.lookTime,
            everythingToShow..removeWhere((element) => newList.contains(element)),
            options.daysToShowNow,
            newList));
      },
      () => againDeadlineDisplayList.addAll(
          _createFullList(setStateMethod, MyDateController.lookTime, everythingToShow)),
      (_) => againDeadlineDisplayList.addAll(_createWidgetEndBased(
              setStateMethod, MyDateController.lookTime, everythingToShow)
          .toList()),
    );
    _globalCounter = -1;
    return againDeadlineDisplayList;
  }

  ///adding special color days
  List<Widget> _createWidgetEndBased(void Function() setStateMethod,
      MyDateController nowDate, List<EndBasedController> endBasedList) {
    List<Widget> againDeadlineDisplayList = [];
    int index = 0;
    if (endBasedList.isNotEmpty && endBasedList.first.daysLeft == -1) {
      index--;
    }
    for (; index < ObservationScreenOptions.daysToShow; index++) {
      againDeadlineDisplayList.addAll(createADay(
          nowDate, endBasedList, index, setStateMethod, _createButtonBase, true));
    }
    if (endBasedList.any((e) => e.daysLeft >= ObservationScreenOptions.daysToShow)) {
      againDeadlineDisplayList.add(bigSplitterTextField);
      var lastLeft = 0;
      for (var button in endBasedList) {
        if (button.daysLeft >= ObservationScreenOptions.daysToShow) {
          if (!button.isHappeningOnDayFromNow(lastLeft)) {
            lastLeft = button.daysLeft;
            againDeadlineDisplayList.addAll(createADay(
                nowDate,
                endBasedList,
                lastLeft,
                setStateMethod,
                _createButtonBase,
                lastLeft < ObservationScreenOptions.daysToShow));
          }
        }
      }
    }
    return againDeadlineDisplayList;
  }

  List<Widget> _createFullList(void Function() setStateMethod, MyDateController nowDate,
      List<EndBasedController> endBasedList) {
    endBasedList.sort();
    return endBasedList
        .map((e) => _createListItemEverythingEndBased(e, setStateMethod))
        .toList();
  }

  Widget _createListItemEverythingEndBased(
      EndBasedController e, void Function() setStateMethod) {
    _globalCounter++;
    int index = _globalCounter;
    return Column(children: [
      BlagendaUniformButton(
          (idSelected == e.id && typeOfSelected == e.runtimeType),
          e.color,
          (idSelected == e.id && typeOfSelected == e.runtimeType)
              ? e.gettingTheStringSelected()
              : e.gettingTheStringShortWithDate(),
          () => _clickOnButton(index, setStateMethod, e)),
      smallBlankSplit
    ]);
  }

  ///days
  ///requires a sorted list based on .left
  List<Widget> _createEndBasedDayList(
      void Function() setStateMethod,
      MyDateController nowDate,
      List<EndBasedController> endBasedList,
      int daysToShowNow,
      List<EndBasedController> justAdded) {
    List<Widget> againDeadlineDisplayList = [];
    int i = 0;
    if (endBasedList.isEmpty) return againDeadlineDisplayList;
    if (endBasedList.first.daysLeft == -1) {
      //Yesterday show here
      againDeadlineDisplayList.addAll(
          createADay(nowDate, endBasedList, -1, setStateMethod, _createButtonBase, true));
    }
    //Just added things show here
    if (justAdded.isNotEmpty) {
      var lastLeft = -1;
      for (var button in justAdded) {
        if (!button.isHappeningOnDayFromNow(lastLeft)) {
          lastLeft = button.daysLeft;
          againDeadlineDisplayList.addAll(createADay(nowDate, justAdded, lastLeft,
              setStateMethod, _createButtonBase, lastLeft < daysToShowNow));
        }
      }
    }
    for (; i < daysToShowNow; i++) {
      //show the week
      if (i == ObservationScreenOptions.daysToShow) {
        againDeadlineDisplayList.add(bigSplitterTextField);
      }
      againDeadlineDisplayList.addAll(createADay(nowDate, endBasedList, i, setStateMethod,
          _createButtonBase, i < ObservationScreenOptions.daysToShow));
    }
    return againDeadlineDisplayList;
  }

  Widget _createButtonBase(BasicButtonController it, void Function() setStateMethod) {
    _globalCounter++;
    int index = _globalCounter;
    return BlagendaUniformButton(clicked == index, it.color, _buttonDisplay(index, it),
        () => _clickOnButton(index, setStateMethod, it));
  }

  String _buttonDisplay(int index, BasicButtonController it) {
    return clicked == index ? it.gettingTheStringSelected() : it.gettingTheStringShort();
  }

  void _emptyDay(int daysToShow) {
    var list = [];
    for (int i = 0; i < daysToShow; i++) {
      list.add(createADay(
          MyDateController.today, [], i, () {}, (p0, p1) => const Text(''), true));
    }
  }

  void addNew(int id, Type type) {
    var timeWhenNotNewItemAnymore =
        MyDateController.now().add(const Duration(minutes: 4));
    _newThings[_getKey(id, type)] = timeWhenNotNewItemAnymore;
  }

  void removeNew(int id, Type type) {
    _newThings.remove(_getKey(id, type));
  }

  _NewRef _getKey(int id, Type type) => _newThings.keys
      .firstWhere((e) => e.t == type && e.id == id, orElse: () => _NewRef(type, id));

  /// if there have been updates form or away from new just added sends true
  bool justAddedCheck() {
    if (_newThings.isEmpty) return false;
    MyDateController now = MyDateController.now();
    int hasJustAddedCalc = 0;
    List toRemove = [];
    for (var butId in _newThings.keys) {
      if (_newThings[butId]!.isBefore(now)) {
        toRemove.add(butId);
      }
    }
    for (var ref in toRemove) {
      _newThings.remove(ref);
    }
    if (hasJustAdded != hasJustAddedCalc) {
      hasJustAdded = _newThings.length;
      return true;
    }
    return false;
  }

  bool wasJustAdded(EndBasedController eb) => _newThings.keys.any((e) => e.compare(eb));
}

class _NewRef {
  final Type t;
  final int id;

  _NewRef(this.t, this.id);

  bool compare(EndBasedController eb) => t == eb.runtimeType && id == eb.id;
}
