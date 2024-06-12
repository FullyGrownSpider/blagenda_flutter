import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/ObservationScreen/observation_screen_options.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter/cupertino.dart';

import '../../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../../ObjectControllers/ButtonControllers/deadline_controller.dart';
import '../../ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../../ObjectControllers/ButtonControllers/note_controller.dart';
import '../../blagenda_uniform_button.dart';
import '../../my_date_controller.dart';
import '../mix_button_creator.dart';
import '../mix_day_creator.dart';

class ObservationScreenButtons with DayCreator, ButtonCreator {
  ///the index used to give every button a selection ID
  int _globalCounter = -1;

  ///the selected counter
  int clicked = -1;

  ///the previous selected counter
  int previouslyClicked = -1;

  ///id of button to update when updating
  int idSelected = -1;

  ///if the selected is again the actual from now that is has (the altLeft)
  int fromNowSelect = -1;

  ///keep the data of all the new things
  final Map<_NewRef, MyDateController> _newThings = {};

  int amountJustAdded = 0;

  ///button type of the selected index
  Type? typeOfSelected;

  ///button type of the selected index
  Type? previousTypeOfSelected;

  final Future Function(BasicButtonController) _openEntityEdit;
  final Future Function(BasicButtonController) _openButtonEdit;

  ObservationScreenButtons(this._openEntityEdit, this._openButtonEdit);

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

  List<Widget> getWidgetListNote(
      ObservationScreenOptions options, List<BasicButtonController> notesList) {
    notesList = options.goesInList(notesList, wasJustAdded);
    List<Widget> items = [];
    if (notesList.isNotEmpty) {
      notesList = NoteController.chosenSort(notesList.cast<NoteController>(),
          BasicButtonController.maxValueCheck);
      items.add(const Text('Notes', style: bigTextStyle));
      items.addAll(addAsRow(
          (i) => _createButtonBase(notesList[i], false), notesList.length, (i) {
        return notesList[i].theStringLongestLength;
      }, BasicButtonController.maxValueCheck));
    }
    return items;
  }

  void resetCounters() {
    typeOfSelected = null;
    previouslyClicked = clicked = idSelected = -1;
  }

  void _clickOnButton(int index, BasicButtonController e) {
    if (idSelected != e.id &&
        typeOfSelected != e.runtimeType &&
        previouslyClicked == e.id &&
        previousTypeOfSelected == e.runtimeType) {
      //double click
      if (e.entitied != -1) {
        _openEntityEdit(e);
      } else {
        _openButtonEdit(e);
      }
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
    if (e is SkippableEndBasedController) {
      fromNowSelect = e.altLeft;
    }
  }

  List<Widget> getWidgetListEndBased(int daysToShow, List<dynamic> allLists,
      ObservationScreenOptions options) {
    List<EndBasedController> everythingToShow = options
        .goesInList(
            allLists.whereType<EndBasedController>().toList(), wasJustAdded)
        .whereType<EndBasedController>()
        .toList();
    List<Widget> againDeadlineDisplayList = [];
    if (everythingToShow.isEmpty) _emptyDay(daysToShow);
    everythingToShow.sort();
    options.pickCorrectOption(
      () {
        List<EndBasedController> newList = [];
        List<EndBasedController> newListToRemove = [];
        if (_newThings.isNotEmpty) {
          newList.addAll(_newThings.keys
              .map((k) => everythingToShow.firstWhere((e) => k.compare(e))));
          newList.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
          newListToRemove.addAll(
              newList.where((e) => e.daysLeft >= options.daysToShowNow));
        }
        againDeadlineDisplayList.addAll(_createEndBasedDayList(
            MyDateController.lookTime,
            everythingToShow
              ..removeWhere((element) => newListToRemove.contains(element)),
            options.daysToShowNow,
            newList,
            daysToShow));
      },
      () => againDeadlineDisplayList.addAll(_createFullList(
          MyDateController.lookTime, everythingToShow)),
      (_) => againDeadlineDisplayList.addAll(_createWidgetEndBased(
              MyDateController.lookTime, everythingToShow)
          .toList()),
    );
    _globalCounter = -1;
    return againDeadlineDisplayList;
  }

  ///adding special color days
  List<Widget> _createWidgetEndBased(
      MyDateController nowDate, List<EndBasedController> endBasedList) {
    List<Widget> againDeadlineDisplayList = [];
    int index = 0;
    if (endBasedList.isNotEmpty && endBasedList.first.daysLeft < 0) {
      index--;
    }
    for (; index < ObservationScreenOptions.daysToShow; index++) {
      againDeadlineDisplayList.addAll(createADay(nowDate, endBasedList, index,
          _createButtonBase, true, false, true, _openButtonEditMethod()));
    }
    if (endBasedList
        .any((e) => e.daysLeft >= ObservationScreenOptions.daysToShow)) {
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
                _createButtonBase,
                lastLeft < ObservationScreenOptions.daysToShow,
                false,
                endBasedList.first.daysLeft >= 0,
                _openButtonEditMethod()));
          }
        }
      }
    }
    return againDeadlineDisplayList;
  }

  void Function(int) _openButtonEditMethod() {
    return (int number) {
      _openButtonEdit(DeadlineController(Deadline('!', '', -1, usedColors.first,
          MyDateController.fromDaysFromNow(number))));
    };
  }

  List<Widget> _createFullList(
      MyDateController nowDate, List<EndBasedController> endBasedList) {
    endBasedList.sort();
    return endBasedList
        .map((e) => _createListItemEverythingEndBased(e))
        .toList();
  }

  Widget _createListItemEverythingEndBased(
      EndBasedController e) {
    _globalCounter++;
    int index = _globalCounter;
    return Column(children: [
      BlagendaUniformButton(
          (idSelected == e.id && typeOfSelected == e.runtimeType),
          e.color,
          (idSelected == e.id && typeOfSelected == e.runtimeType)
              ? e.gettingTheStringSelected()
              : e.gettingTheStringShortWithDate(),
          () => _clickOnButton(index, e)),
      smallBlankSplit
    ]);
  }

  ///days
  ///requires a sorted list based on .left
  List<Widget> _createEndBasedDayList(
      MyDateController nowDate,
      List<EndBasedController> endBasedList,
      int daysToShowNow,
      List<EndBasedController> justAdded,
      int daysToShow) {
    List<Widget> againDeadlineDisplayList = [];
    int i = 0;
    if (endBasedList.isEmpty) return againDeadlineDisplayList;
    if (endBasedList.first.daysLeft < 0) {
      //Yesterday show here
      againDeadlineDisplayList.addAll(createADay(nowDate, endBasedList, -1,
          _createButtonBase, true, true, true, _openButtonEditMethod()));
    }
    //Just added things show here up top
    if (justAdded.isNotEmpty) {
      var lastLeft = -1;
      for (var button
          in justAdded.where((element) => element.daysLeft >= daysToShowNow)) {
        if (!button.isHappeningOnDayFromNow(lastLeft)) {
          lastLeft = button.daysLeft;
          againDeadlineDisplayList.addAll(createADay(
              nowDate,
              [...justAdded, ...endBasedList],
              lastLeft,
              (controller, isExtra) => _createButtonBase(
                  controller, isExtra, justAdded.contains(controller)),
              lastLeft < daysToShowNow,
              false,
              false,
              _openButtonEditMethod()));
        }
      }
    }
    for (; i < daysToShowNow; i++) {
      //show the week
      if (i == ObservationScreenOptions.daysToShow) {
        againDeadlineDisplayList.add(bigSplitterTextField);
      }
      againDeadlineDisplayList.addAll(createADay(
          nowDate,
          endBasedList,
          i,
          (controller, isExtra) => _createButtonBase(
              controller, isExtra, justAdded.contains(controller)),
          i < ObservationScreenOptions.daysToShow,
          false,
          endBasedList.first.daysLeft >= 0,
          _openButtonEditMethod()));
    }
    return againDeadlineDisplayList;
  }

  BlagendaUniformButton _createButtonBase(
      BasicButtonController it, bool isExtra,
      [bool isNew = false]) {
    _globalCounter++;
    int index = _globalCounter;
    return BlagendaUniformButton(
        clicked == index,
        it.color,
        '${isNew ? '⊚' : ''}${isExtra ? it.job.substring(0, 3) + BlagendaUniformButton.smollButStartText : _buttonDisplay(index, it)}',
        () => _clickOnButton(index, it));
  }

  String _buttonDisplay(int index, BasicButtonController it) {
    if (it.job.startsWith('!') || clicked == index) {
      return it.gettingTheStringSelected().replaceFirst(r'^!', '');
    }
    return it.gettingTheStringShort();
  }

  void _emptyDay(int daysToShow) {
    var list = [];
    for (int i = 0; i < daysToShow; i++) {
      list.add(createADay(
          MyDateController.today,
          [],
          i,
          (p0, p2) => const Text(''),
          true,
          false,
          false,
          _openButtonEditMethod()));
    }
  }

  void addNew(int id, Type type) {
    var timeWhenNotNewItemAnymore =
        MyDateController.now().add(const Duration(minutes: 4));
    _newThings[_getKey(id, type)] = timeWhenNotNewItemAnymore;
    amountJustAdded++;
  }

  void removeNew(int id, Type type) {
    _newThings.remove(_getKey(id, type));
  }

  _NewRef _getKey(int id, Type type) =>
      _newThings.keys.firstWhere((e) => e.t == type && e.id == id,
          orElse: () => _NewRef(type, id));

  /// if there have been updates form or away from new just added sends true
  bool justAddedCheck() {
    if (_newThings.isEmpty) return false;
    MyDateController now = MyDateController.now();
    int hasJustAddedCalc = _newThings.length;
    List toRemove = [];
    for (var butId in _newThings.keys) {
      if (_newThings[butId]!.isBefore(now)) {
        toRemove.add(butId);
      }
    }
    for (var ref in toRemove) {
      _newThings.remove(ref);
    }
    amountJustAdded = _newThings.length;
    if (amountJustAdded != hasJustAddedCalc) {
      return true;
    }
    return false;
  }

  bool wasJustAdded(EndBasedController eb) =>
      _newThings.keys.any((e) => e.compare(eb));
}

class _NewRef {
  final Type t;
  final int id;

  _NewRef(this.t, this.id);

  bool compare(EndBasedController eb) => t == eb.runtimeType && id == eb.id;
}
