import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/loading.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../../common_items.dart';
import 'common_day_display_screen_controller.dart';
import 'common_screen_controller.dart';

class ObservationScreenController {
  static const int _daysToShow = 6;
  static const int _maxTextSize = 11;
  static const List<int> _possibleExtraDays = [30, 14];
  static const List<String> smallDateFormat = [D];

  ///lists used to store all buttons and used to .select the ones to display
  final Map<Type, List> _allLists = {
    AgainAmountController: <AgainAmountController>[],
    AgainMonthController: <AgainMonthController>[],
    AgainWeekController: <AgainWeekController>[],
    AgainYearController: <AgainYearController>[],
    DeadlineController: <DeadlineController>[],
    NoteController: <NoteController>[]
  };
  final List<bool> _loaded = [false, false, false, false, false, false];

  static final List<Future<List> Function(Loading)> _buttonGet = [
    (l) => l.getButtons<AgainAmountController>(),
    (l) => l.getButtons<AgainMonthController>(),
    (l) => l.getButtons<AgainWeekController>(),
    (l) => l.getButtons<AgainYearController>(),
    (l) => l.getButtons<DeadlineController>(),
    (l) => l.getButtons<NoteController>(),
  ];

  bool doneLoading() => !_loaded.any((e) => !e);

  ///-1 no color selected
  ///-2 show everything in a list
  int chosenColor = -1;

  ///used to display more days or less days
  int daysToShowNow = _daysToShow;

  ///the index used to give every button a selection ID
  int _globalCounter = -1;

  ///the selected counter
  int clicked = -1;

  ///when you add something this is used to keep checking or not
  int hasJustAdded = 0;

  ///id of button to update when updating
  int idSelected = -1;

  ///button type of the selected index
  Type? _typeOfSelected;

  ///needs to load first use doneLoading to check if done
  ObservationScreenController() {
    _fillLists();
  }

  List<Widget> getWidgetListEndBased(void Function() setStateMethod) {
    List<EndBasedController> overviewList = [];
    List<Widget> againDeadlineDisplayList = [];
    for (var e in _allLists.entries) {
      if (e.value is List<EndBasedController>) {
        overviewList.addAll(_goesInList(
                e.value as List<EndBasedController>, MyDateController.lookTime)
            as List<EndBasedController>);
      }
    }
    overviewList.sort();
    if (chosenColor > -1) {
      againDeadlineDisplayList.addAll(_createWidgetEndBased(
              setStateMethod, MyDateController.lookTime, overviewList)
          .toList());
    } else if (chosenColor == -2) {
      againDeadlineDisplayList.addAll(_createFullList(
          setStateMethod, MyDateController.lookTime, overviewList));
    } else {
      List<EndBasedController> newList = overviewList
          .where((e) =>
              e.wasJustAdded(MyDateController.lookTime) && e.left > _daysToShow)
          .toList();
      againDeadlineDisplayList.addAll(_createNewEndBasedWasJustAddedDay(
          setStateMethod, MyDateController.lookTime, newList));
      againDeadlineDisplayList.addAll(_createEndBasedDayList(
          setStateMethod,
          MyDateController.lookTime,
          overviewList));
    }
    againDeadlineDisplayList.add(bigSplitterTextField);
    return againDeadlineDisplayList;
  }

  List<Widget> getWidgetListNote(void Function() setStateMethod) {
    List<BasicButtonController> notesList = _goesInList(
        _getCorrectList(NoteController) as List<NoteController>,
        MyDateController.nowDate);
    List<Widget> items = [];
    if (notesList.isNotEmpty) {
      notesList.sort((a, b) =>
          b.gettingTheStringLongLength.compareTo(a.gettingTheStringLongLength));
      items.add(const Text('Notes', style: bigTextStyle));
      items.addAll(addAsRow(
          (i) => _createButtonBase(notesList[i], setStateMethod),
          notesList.length, (i) {
        return notesList[i].gettingTheStringLongLength ~/ _maxTextSize;
      }));
      items.add(bigSplitterTextField);
    }
    return items;
  }

  ///the buttons to select the color to only show
  List<Widget> getOptionButtons(void Function() setStateMethod) {
    List<Widget> items = [];
    items.add(const Text('Display Options', style: bigTextStyle));
    items.addAll(
        globalCreateColorButtons(setStateMethod, _colorPressed, chosenColor));
    items.addAll(addAsRow((i) => _createCounterButton(setStateMethod, i),
        _possibleExtraDays.length));
    items.add(_createDisplayAllEndBasedButtonsButton(setStateMethod));
    items.add(bigSplitterTextField);
    return items;
  }

  void _colorPressed(int index) {
    daysToShowNow = _daysToShow;
    if (chosenColor == index) {
      chosenColor = -1;
    } else {
      chosenColor = index;
    }
    _resetCounters();
  }

  Widget _createDisplayAllEndBasedButtonsButton(
          void Function() setStateMethod) =>
      blagendaUniformButton(-2 == chosenColor, usedColors.first, 'Show all',
          () {
        _resetCounters();
        daysToShowNow = _daysToShow;
        if (-2 == chosenColor) {
          chosenColor = -1;
        } else {
          chosenColor = -2;
        }
        setStateMethod();
      });

  ///reset screen to default
  void resetSearch(void Function() setStateMethod) {
    if (chosenColor == -1 && daysToShowNow == _daysToShow) return;
    chosenColor = -1;
    daysToShowNow = _daysToShow;
    _resetCounters();
    setStateMethod();
  }

  Widget _createCounterButton(void Function() setStateMethod, int index) =>
      blagendaUniformButton(
          daysToShowNow == _possibleExtraDays[index],
          usedColors.first,
          'Show next ' + _possibleExtraDays[index].toString() + ' days', () {
        chosenColor = -1;
        if (daysToShowNow == _possibleExtraDays[index]) {
          daysToShowNow = _daysToShow;
        } else {
          daysToShowNow = _possibleExtraDays[index];
        }
        _resetCounters();
        setStateMethod();
      });

  ///days
  ///requires a sorted list based on .left
  List<Widget> _createEndBasedDayList(void Function() setStateMethod,
      MyDateController nowDate, List<EndBasedController> endBasedList) {
    List<Widget> againDeadlineDisplayList = [];
    int i = 0;
    if (endBasedList.isEmpty) return againDeadlineDisplayList;
    if (endBasedList.first.left == -1) {
      //-1 to also show yesterday
      i--;
    }
    for (; i < daysToShowNow; i++) {
      if (i == _daysToShow) {
        againDeadlineDisplayList.add(bigSplitterTextField);
      }
      againDeadlineDisplayList.addAll(createADay(nowDate, endBasedList, i,
          setStateMethod, _createButtonBase, i < _daysToShow));
    }
    return againDeadlineDisplayList;
  }

  ///adding special color days
  List<Widget> _createWidgetEndBased(void Function() setStateMethod,
      MyDateController nowDate, List<EndBasedController> endBasedList) {
    List<Widget> againDeadlineDisplayList = [];
    int index = 0;

    if (endBasedList.isNotEmpty && endBasedList.first.left == -1) {
      //memory intensive? maybe can be done better? like only checking first one?
      index--;
    }
    //-1 to also show yesterday
    for (; index < _daysToShow; index++) {
      againDeadlineDisplayList.addAll(createADay(nowDate, endBasedList, index,
          setStateMethod, _createButtonBase, true));
    }
    if (endBasedList.any((e) => e.left >= _daysToShow)) {
      againDeadlineDisplayList.add(bigSplitterTextField);
      var lastLeft = 0;
      for (int i = 0; i < endBasedList.length; i++) {
        if (endBasedList[i].left >= _daysToShow) {
          if (!endBasedList[i].isInLeft(lastLeft)) {
            lastLeft = endBasedList[i].left;
            againDeadlineDisplayList.addAll(createADay(
                nowDate,
                endBasedList,
                endBasedList[i].left,
                setStateMethod,
                _createButtonBase,
                endBasedList[i].left < _daysToShow));
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
    for (int i = 0; i < endBasedList.length; i++) {
      if (!endBasedList[i].isInLeft(lastLeft)) {
        lastLeft = endBasedList[i].left;
        againDeadlineDisplayList.addAll(createADay(
            nowDate,
            endBasedList,
            endBasedList[i].left,
            setStateMethod,
            _createButtonBase,
            endBasedList[i].left < _daysToShow));
      }
    }
    return againDeadlineDisplayList;
  }

  void resetLists() {
    for (var e in _allLists.entries) {
      if (e.value.isNotEmpty && e.value.first is EndBasedController) {
        for (var element in e.value) {
          (element as EndBasedController).rebuild();
        }
      }
    }
  }

  void _fillLists() {
    for (var list in _allLists.entries) {
      list.value.clear();
    }
    for (int i = 0; i < _loaded.length; i++) {
      _loaded[i] = false;
      _buttonGet[i](loading).then((value) {
        if (value.isNotEmpty) {
          _allLists[value.first.runtimeType]!.addAll(value);
          if (value.first is EndBasedController) {
            List<EndBasedController> itemsToUpdate =
                _getCorrectList(value.first.runtimeType)
                    .where((e) => (e as EndBasedController).requiresChange)
                    .toList() as List<EndBasedController>;
            if (itemsToUpdate.isNotEmpty) {
              if (value.first is DeadlineController) {
                loading.deleteButtons(itemsToUpdate, DeadlineController);
                _getCorrectList(DeadlineController).removeWhere(
                    (e) => (e as EndBasedController).requiresChange);
              } else {
                loading.updateButtons(
                    (_getCorrectList(AgainAmountController)
                        as List<EndBasedController>),
                    AgainAmountController);
              }
            }
          }
        }
        _loaded[i] = true;
      });
    }
  }

  bool _shouldGoIn(EndBasedController eb, MyDateController now) =>
      eb.left < daysToShowNow && eb.left >= -1 || eb.wasJustAdded(now);

  List<BasicButtonController> _goesInList(
      List<BasicButtonController> list, MyDateController now) {
    if (chosenColor == -2 || list.isEmpty) return list;
    if (chosenColor != -1) {
      //a color has been picked
      Color c = usedColors[chosenColor];
      return (list).where((e) => e.colorCheck(c)).toList();
    }
    if (list.first is EndBasedController) {
      var newList = list.where((e) => _shouldGoIn(e as EndBasedController, now));
      if (daysToShowNow != _daysToShow) {
        //if you select 14 you want to see something 14 days away too not just
        //13
        return list
            .where((e) => (e as EndBasedController).left == daysToShowNow)
            .toList()
          ..addAll(newList);
      } else {
        return newList.toList();
      }
    }
    return list;
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
      clickFunction(index, it.id, it.runtimeType, setStateMethod);
    });
  }

  void clickFunction(
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

  BasicButtonController? getSelectedButton() {
    if (idSelected == -1) return null;
    List correctList = _getCorrectList(_typeOfSelected!);
    return correctList.firstWhere((e) => idSelected == e.button.id);
  }

  void deleteSelected(void Function() setStateMethod) {
    if (idSelected == -1) return;
    BasicButtonController? controller = getSelectedButton();
    if (controller == null) return;
    loading.deleteButton(controller);

    List correctList = _getCorrectList(_typeOfSelected!);
    correctList.removeWhere((e) => idSelected == e.button.id);
    setStateMethod();
  }

  void skipButton(void Function() setStateMethod) {
    if (idSelected == -1) return;
    BasicButtonController? controller = getSelectedButton();
    if (controller == null || controller is SkippableEndBasedController) return;
    (controller as SkippableEndBasedController)
        .newSkip(controller.dateController);
    _updateButton(controller, setStateMethod);
  }

  List _getCorrectList(Type t) => _allLists[t]!;

  List<Widget> _createFullList(void Function() setStateMethod,
      MyDateController nowDate, List<EndBasedController> endBasedList) {
    endBasedList.sort((e, b) => e.left.compareTo(b.left));
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

  bool justAddedCheck() {
    MyDateController now = MyDateController.now();
    var hasJustAddedCalc = 0;
    for (var e in _allLists.entries) {
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

  int getNewId(Type t) {
    var correctList = _getCorrectList(t);
    if (correctList.isNotEmpty) {
      correctList.sort((a, b) {
        return a.button.id.compareTo(b.button.id);
      });
      for (int i = 0; i < correctList.length; i++) {
        if (correctList[i].button.id != i) {
          return i;
        }
      }
    }
    return correctList.length;
  }
}
