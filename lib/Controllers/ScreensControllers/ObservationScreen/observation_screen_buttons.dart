import 'dart:math';

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
  MyDateController _lastUpdate = MyDateController.now();
  final ButSelectorData _butSelectorData = ButSelectorData();

  final Future Function(BasicButtonController) _openButtonEdit;

  ObservationScreenButtons(this._openButtonEdit);

  void updateEndBasedToCurrentDay(
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
    notesList = options.goesInList(notesList, wasJustUpdated);
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

  void resetCounters() => _butSelectorData.reset();

  @visibleForTesting
  void clickOnButton(BasicButtonController e) =>
      _butSelectorData.select(e, _openButtonEdit);

  List<Widget> getWidgetListEndBased(int daysToShow, List<dynamic> allLists,
      ObservationScreenOptions options) {
    List<EndBasedController> everythingToShow = options
        .goesInList(
            allLists.whereType<EndBasedController>().toList(), wasJustUpdated)
        .whereType<EndBasedController>()
        .toList();
    List<Widget> againDeadlineDisplayList = [];
    if (everythingToShow.isEmpty) _emptyDay(daysToShow);
    everythingToShow.sort();
    options.pickCorrectOption(
      () {
        List<EndBasedController> newList = [];
        List<EndBasedController> newListToRemove = [];
        newList.addAll(allLists
            .where((e) => e is EndBasedController && e.touched)
            .toList(growable: false)
            .cast<EndBasedController>());
        newList.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
        newListToRemove.addAll(
            newList.where((e) => e.daysLeft >= options.displayState.days));
        againDeadlineDisplayList.addAll(_createEndBasedDayList(
            MyDateController.lookTime,
            everythingToShow
              ..removeWhere((element) => newListToRemove.contains(element)),
            options.displayState.days,
            newList,
            daysToShow));
      },
      () => againDeadlineDisplayList
          .addAll(_createFullList(MyDateController.lookTime, everythingToShow)),
      (_) => againDeadlineDisplayList.addAll(
          _createWidgetEndBased(MyDateController.lookTime, everythingToShow)
              .toList()),
    );
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

  Widget _createListItemEverythingEndBased(EndBasedController e) {
    final myBool = _butSelectorData.makeWorkingBool(e);
    return Column(children: [
      BlagendaUniformButton(
          e.color,
          () =>
              '${e.touched ? '⊚' : ''}${(myBool.value) ? e.gettingTheStringSelected() : e.gettingTheStringShortWithDate()}',
          () => clickOnButton(e),
          isSelected: myBool),
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
    ValueNotifier<bool> myBool = _butSelectorData.makeWorkingBool(it);
    return BlagendaUniformButton(
        it.color,
        () =>
            '${isNew ? '⊚' : ''}${isExtra ? (it.job.substring(0, min(4, it.job.length)).trim() + (it.job.length > 4 ? '...' : '')) : _buttonDisplay(it)}',
        () => clickOnButton(it),
        isSelected: myBool,
        isSmall: isExtra);
  }

  String _buttonDisplay(BasicButtonController it) {
    if (it.job.contains('!') || _butSelectorData.isItMe(it)) {
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

  /// if there have been updates form or away from new just added sends true
  bool justAddedCheck(List<EndBasedController> list) {
    if (MyDateController.now().isBefore(_lastUpdate)) {
      for (var e in list) {
        e.touched = false;
      }
      return false;
    }
    return list.any((e) => e.touched);
  }

  bool wasJustUpdated(EndBasedController eb) => eb.touched;

  BasicButtonController? getSelected(List<BasicButtonController> all) => all
      .cast<BasicButtonController?>()
      .firstWhere((e) => _butSelectorData.isItMe(e!), orElse: () => null);

  void updateMoment() =>
      _lastUpdate = MyDateController.now().add(const Duration(minutes: 10));
}

class ButSelectorData extends ChangeNotifier {
  int _id = -1;
  Type? _type;
  int _prevId = -1;
  Type? _prevType;
  bool doubleClicked = false;

  ///if the selected is again the actual from now that is has (the altLeft)
  int fromNowSelect = -1;

  ButSelectorData();

  void reset() {
    _id = _prevId = -1;
    _type = _prevType = null;
  }

  bool isItMe(BasicButtonController e) {
    if (e.id == _id && e.runtimeType == _type) {
      if (e is SkippableEndBasedController) {
        return e.altLeft == fromNowSelect;
      }
      return true;
    }
    return false;
  }

  ValueNotifier<bool> makeWorkingBool(BasicButtonController e) {
    var newValue = ValueNotifier(isItMe(e));
    addListener(() => newValue.value = isItMe(e));
    return newValue;
  }

  void select(BasicButtonController e,
      Function(BasicButtonController) doOnDoubleClick) {
    if (_id != e.id &&
        _type != e.runtimeType &&
        _prevId == e.id &&
        _prevType == e.runtimeType &&
        (e is! SkippableEndBasedController || fromNowSelect == e.altLeft)) {
      //double click
      doOnDoubleClick(e);
      reset();
    } else if (_id != e.id || _type != e.runtimeType) {
      //selecting click
      _prevId = _id = e.id;
      _prevType = _type = e.runtimeType;
      if (e is SkippableEndBasedController) {
        fromNowSelect = e.altLeft;
      }
    } else {
      //deselecting click
      _id = -1;
      _type = null;
    }
    notifyListeners();
  }
}
