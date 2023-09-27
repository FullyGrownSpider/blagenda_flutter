import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../../common_items.dart';
import 'ObservationScreen/obeservation_screen_loading.dart';
import 'ObservationScreen/obeservation_screen_options.dart';
import 'common_day_display_screen_controller.dart';
import 'common_screen_controller.dart';

class ObservationScreenController {
  static const List<String> smallDateFormat = [D];

  late final ObservationScreenLoading _observationScreenLoading;
  late final ObservationScreenOptions _observationScreenOptions =
      ObservationScreenOptions();

  ///lists used to store all buttons and used to .select the ones to display
  final Map<Type, List> _allLists = {
    AgainAmountController: <AgainAmountController>[],
    AgainMonthController: <AgainMonthController>[],
    AgainWeekController: <AgainWeekController>[],
    AgainYearController: <AgainYearController>[],
    DeadlineController: <DeadlineController>[],
    NoteController: <NoteController>[]
  };

  ///the index used to give every button a selection ID
  int _globalCounter = -1;

  ///the selected counter
  int clicked = -1;

  ///id of button to update when updating
  int idSelected = -1;

  ///button type of the selected index
  Type? _typeOfSelected;

  ///needs to load first use doneLoading to check if done
  ObservationScreenController() {
    _observationScreenLoading = ObservationScreenLoading(_getCorrectList);
    _observationScreenLoading.loadListsFromStorage(_allLists);
  }

  List<Widget> getWidgetListEndBased(void Function() setStateMethod) {
    List<EndBasedController> overviewList = [];
    List<Widget> againDeadlineDisplayList = [];
    for (var e in _allLists.entries) {
      if (e.value is List<EndBasedController>) {
        overviewList.addAll(_observationScreenOptions.goesInList(
                e.value as List<EndBasedController>, MyDateController.lookTime)
            as List<EndBasedController>);
      }
    }
    if (overviewList.isEmpty) emptyDay();
    overviewList.sort();
    _observationScreenOptions.pickCorrectOption(
        () => againDeadlineDisplayList.addAll(_createWidgetEndBased(
                setStateMethod, MyDateController.lookTime, overviewList)
            .toList()),
        () => againDeadlineDisplayList.addAll(_createFullList(
            setStateMethod, MyDateController.lookTime, overviewList)), (c) {
      List<EndBasedController> newList = overviewList
          .where((e) =>
              e.wasJustAdded(MyDateController.lookTime) &&
              e.daysLeft > ObservationScreenOptions.daysToShow)
          .toList();
      againDeadlineDisplayList.addAll(_createNewEndBasedWasJustAddedDay(
          setStateMethod, MyDateController.lookTime, newList));
      againDeadlineDisplayList.addAll(_createEndBasedDayList(
          setStateMethod, MyDateController.lookTime, overviewList));
    });
    againDeadlineDisplayList.add(bigSplitterTextField);
    return againDeadlineDisplayList;
  }

  List<Widget> getWidgetListNote(void Function() setStateMethod) {
    List<BasicButtonController> notesList =
        _observationScreenOptions.goesInList(
            _getCorrectList(NoteController) as List<NoteController>,
            MyDateController.nowDate);
    List<Widget> items = [];
    if (notesList.isNotEmpty) {
      notesList = NoteController.chosenSort(
          notesList as List<NoteController>, BasicButtonController.maxValueCheck);
      items.add(const Text('Notes', style: bigTextStyle));
      items.addAll(addAsRow(
          (i) => _createButtonBase(notesList[i], setStateMethod),
          notesList.length, (i) {
        return notesList[i].theStringLongestLength;
      }, BasicButtonController.maxValueCheck));
      items.add(bigSplitterTextField);
    }
    return items;
  }

  ///reset screen to default
  void resetSearch(void Function() setStateMethod) =>
      _observationScreenOptions.resetSearch(setStateMethod, _resetCounters);

  ///days
  ///requires a sorted list based on .left
  List<Widget> _createEndBasedDayList(void Function() setStateMethod,
      MyDateController nowDate, List<EndBasedController> endBasedList) {
    List<Widget> againDeadlineDisplayList = [];
    int i = 0;
    if (endBasedList.isEmpty) return againDeadlineDisplayList;
    if (endBasedList.first.daysLeft == -1) {
      //-1 to also show yesterday
      i--;
    }
    for (; i < _observationScreenOptions.daysToShowNow; i++) {
      if (i == ObservationScreenOptions.daysToShow) {
        againDeadlineDisplayList.add(bigSplitterTextField);
      }
      againDeadlineDisplayList.addAll(createADay(nowDate, endBasedList, i,
          setStateMethod, _createButtonBase, i < ObservationScreenOptions.daysToShow));
    }
    return againDeadlineDisplayList;
  }

  ///adding special color days
  List<Widget> _createWidgetEndBased(void Function() setStateMethod,
      MyDateController nowDate, List<EndBasedController> endBasedList) {
    List<Widget> againDeadlineDisplayList = [];
    int index = 0;

    if (endBasedList.isNotEmpty && endBasedList.first.daysLeft == -1) {
      //memory intensive? maybe can be done better? like only checking first one?
      index--;
    }
    //-1 to also show yesterday
    for (; index < ObservationScreenOptions.daysToShow; index++) {
      againDeadlineDisplayList.addAll(createADay(nowDate, endBasedList, index,
          setStateMethod, _createButtonBase, true));
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

  List<Widget> _createNewEndBasedWasJustAddedDay(void Function() setStateMethod,
      MyDateController nowDate, List<EndBasedController> endBasedList) {
    List<Widget> againDeadlineDisplayList = [];
    var lastLeft = -1;
    for (var button in endBasedList) {
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
    return againDeadlineDisplayList;
  }

  void _updateEndbasedToCurrentDay(List<EndBasedController> itemsToCheck) {
    List<EndBasedController> itemsToUpdate =
        _getCorrectList(itemsToCheck.firstOrNull.runtimeType)
            .where((e) => e.requiresChange)
            .toList() as List<EndBasedController>;
    if (itemsToUpdate.isNotEmpty) {
      if (itemsToCheck.firstOrNull is DeadlineController) {
        loading.deleteButtons(itemsToUpdate);
        _getCorrectList(DeadlineController)
            .removeWhere((e) => e.requiresChange);
      } else if (itemsToCheck.firstOrNull is SkippableEndBasedController) {
        var toDelete = itemsToCheck
            .where((e) => (e as SkippableEndBasedController).wantDeleteMe())
            .toList();
        var toUpdate = itemsToCheck
            .where((e) => !(e as SkippableEndBasedController).wantDeleteMe())
            .toList();
        loading.deleteButtons(toDelete);
        loading.updateButtons(toUpdate);
        _getCorrectList(itemsToCheck.firstOrNull.runtimeType)
            .remove((e) => e.wantDeleteMe());
        for (var toUpdateButton in toUpdate) {
          toUpdateButton.requiresChange = false;
        }
      }
    }
  }

  void resetLists() {
    for (var e in _allLists.entries) {
      if (e.value.isNotEmpty && e.value.first is EndBasedController) {
        for (var element in e.value) {
          (element as EndBasedController).rebuild();
        }
        _updateEndbasedToCurrentDay(e.value as List<EndBasedController>);
      }
    }
  }

  String _buttonDisplay(int index, BasicButtonController it) {
    if (it is EndBasedController) {
      return clicked == index
          ? it.gettingTheStringSelected()
          : it.gettingTheStringShort();
    } else {
      return clicked == index
          ? it.gettingTheStringSelected()
          : it.gettingTheStringShort();
    }
  }

  Widget _createButtonBase(
      BasicButtonController it, void Function() setStateMethod) {
    _globalCounter++;
    int index = _globalCounter;
    return blagendaUniformButton(
        clicked == index, it.color, _buttonDisplay(index, it), () {
      clickOnButton(index, it.id, it.runtimeType, setStateMethod);
    });
  }

  void clickOnButton(
      int index, int id, Type type, void Function() setStateMethod) {
    if (clicked == index) {
      clicked = idSelected = -1;
      _typeOfSelected = null;
    } else {
      clicked = index;
      idSelected = id;
      _typeOfSelected = type;
    }
    _globalCounter = -1;
    setStateMethod();
  }

  void _resetCounters() => clicked = idSelected = -1;

  BasicButtonController? getSelectedButton() {
    if (idSelected == -1) return null;
    List correctList = _getCorrectList(_typeOfSelected!);
    return correctList.firstWhere((e) => idSelected == e.button.id);
  }

  List _getCorrectList(Type t) => _allLists[t]!;

  List<Widget> _createFullList(void Function() setStateMethod,
      MyDateController nowDate, List<EndBasedController> endBasedList) {
    endBasedList.sort();
    return endBasedList
        .map((e) => _createListItemEverythingEndBased(e, setStateMethod))
        .toList();
  }

  Widget _createListItemEverythingEndBased(
      EndBasedController e, void Function() setStateMethod) {
    return Column(children: [
      blagendaUniformButton(
          (idSelected == e.id && _typeOfSelected == e.runtimeType),
          e.color,
          (idSelected == e.id && _typeOfSelected == e.runtimeType)
              ? e.gettingTheStringSelected()
              : e.gettingTheStringShortWithDate(), () {
        if (idSelected != e.id || _typeOfSelected != e.runtimeType) {
          idSelected = e.id;
          _typeOfSelected = e.runtimeType;
        } else {
          idSelected = -1;
          _typeOfSelected = null;
        }
        setStateMethod();
      }),
      smallBlankSplit
    ]);
  }

  bool justAddedCheck() => _observationScreenLoading.justAddedCheck(_allLists);

  void setAllToNotNew() {
    _allLists.forEach((key, value) {
      if (key != EndBasedController) return;
      for (var button in value) {
        button.timeWhenNotNewItemAnymore = null;
      }
    });
  }

  void emptyDay() {
    var list = [];
    for (int i = 0; i < _observationScreenOptions.daysToShowNow; i++) {
      list.add(createADay(MyDateController.today, [], i, () {},
          (p0, p1) => const Text(''), true));
    }
  }

  bool doneLoading() => _observationScreenLoading.doneLoading();

  void loadListsFromStorage() =>
      _observationScreenLoading.loadListsFromStorage(_allLists);

  int getNewId(Type t) => _observationScreenLoading.getNewId(t);

  void addOrUpdateButton(
          BasicButtonController<BasicButton> c, void Function() resetScreen) =>
      _observationScreenLoading.addOrUpdateButton(c, resetScreen);

  void deleteSelected(void Function() resetScreen) => _observationScreenLoading
      .deleteSelected(resetScreen, getSelectedButton());

  void skipButton(void Function() resetScreen) =>
      _observationScreenLoading.skipButton(resetScreen, getSelectedButton());

  List<Widget> getOptionButtons(void Function() setStateMethod) =>
      _observationScreenOptions.getOptionButtons(
          setStateMethod, _resetCounters);
}
