import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/ObservationScreen/observation_screen_options.dart';
import 'package:flutter/cupertino.dart';

import '../../ButtonControllers/basic_button_controller.dart';
import '../../ButtonControllers/deadline_controller.dart';
import '../../ButtonControllers/end_based_controller.dart';
import '../../ButtonControllers/note_controller.dart';
import '../../my_date_controller.dart';
import '../common_day_display_screen_controller.dart';
import '../common_screen_controller.dart';

class ObservationScreenButtons {
  ///the index used to give every button a selection ID
  int globalCounter = -1;

  ///the selected counter
  int clicked = -1;

  ///id of button to update when updating
  int idSelected = -1;

  ///button type of the selected index
  Type? typeOfSelected;

  void updateEndbasedToCurrentDay(
      List<BasicButtonController> itemsToCheck,
      List<dynamic> Function(Type) getCorrectList,
      void Function(List<BasicButtonController>) delete,
      void Function(List<BasicButtonController>) update) {
    if (itemsToCheck.isEmpty || itemsToCheck.first is! EndBasedController) {
      return;
    }
    itemsToCheck as List<EndBasedController>;
    for (var element in itemsToCheck) {
      (element).rebuild();
    }
    List<EndBasedController> itemsToUpdate =
    getCorrectList(itemsToCheck.firstOrNull.runtimeType)
        .where((e) => e.requiresChange)
        .toList() as List<EndBasedController>;
    if (itemsToUpdate.isNotEmpty) {
      if (itemsToCheck.firstOrNull is DeadlineController) {
        delete(itemsToUpdate);
        getCorrectList(DeadlineController).removeWhere((e) => e.requiresChange);
      } else if (itemsToCheck.firstOrNull is SkippableEndBasedController) {
        delete(itemsToCheck
            .where((e) => (e as SkippableEndBasedController).wantDeleteMe())
            .toList());
        var toUpdate = itemsToCheck
            .where((e) => !(e as SkippableEndBasedController).wantDeleteMe())
            .toList();
        update(toUpdate);
        getCorrectList(itemsToCheck.firstOrNull.runtimeType)
            .remove((e) => e.wantDeleteMe());
        for (var toUpdateButton in toUpdate) {
          toUpdateButton.requiresChange = false;
        }
      }
    }
  }

  List<Widget> getWidgetListNote(void Function() setStateMethod,
      ObservationScreenOptions options, List<BasicButtonController> notesList) {
    notesList = options.goesInList(notesList, MyDateController.nowDate);
    List<Widget> items = [];
    if (notesList.isNotEmpty) {
      notesList = NoteController.chosenSort(notesList as List<NoteController>,
          BasicButtonController.maxValueCheck);
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

  void resetCounters() => clicked = idSelected = -1;

  void clickOnButton(
      int index, int id, Type type, void Function() setStateMethod) {
    if (clicked == index) {
      clicked = idSelected = -1;
      typeOfSelected = null;
    } else {
      clicked = index;
      idSelected = id;
      typeOfSelected = type;
    }
    globalCounter = -1;
    setStateMethod();
  }

  List<Widget> getWidgetListEndBased(
      void Function() setStateMethod,
      int daysToShow,
      Map<Type, List<dynamic>> allLists,
      ObservationScreenOptions options) {
    List<EndBasedController> everythingToShow = [];
    List<Widget> againDeadlineDisplayList = [];
    for (var list in allLists.values) {
      if (list is List<EndBasedController>) {
        everythingToShow.addAll(options.goesInList(
            list, MyDateController.lookTime)
        as List<EndBasedController>);
      }
    }
    if (everythingToShow.isEmpty) _emptyDay(daysToShow);
    everythingToShow.sort();
    options.pickCorrectOption(
          () {
        List<EndBasedController> newList = everythingToShow
            .where((e) =>
        e.wasJustAdded(MyDateController.lookTime) &&
            e.daysLeft > daysToShow)
            .toList();
        againDeadlineDisplayList.addAll(_createNewEndBasedWasJustAddedDay(
            setStateMethod, MyDateController.lookTime, newList, daysToShow));
        againDeadlineDisplayList.addAll(_createEndBasedDayList(
            setStateMethod,
            MyDateController.lookTime,
            everythingToShow,
            options.daysToShowNow));
      },
          () => againDeadlineDisplayList.addAll(_createFullList(
          setStateMethod, MyDateController.lookTime, everythingToShow)),
          (_) => againDeadlineDisplayList.addAll(_createWidgetEndBased(
          setStateMethod, MyDateController.lookTime, everythingToShow)
          .toList()),
    );
    againDeadlineDisplayList.add(bigSplitterTextField);
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
      againDeadlineDisplayList.addAll(createADay(nowDate, endBasedList, index,
          setStateMethod, _createButtonBase, true));
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
                setStateMethod,
                _createButtonBase,
                lastLeft < ObservationScreenOptions.daysToShow));
          }
        }
      }
    }
    return againDeadlineDisplayList;
  }

  List<Widget> _createNewEndBasedWasJustAddedDay(
      void Function() setStateMethod,
      MyDateController nowDate,
      List<EndBasedController> endBasedList,
      int daysToShow) {
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
            lastLeft < daysToShow));
      }
    }
    return againDeadlineDisplayList;
  }

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
          (idSelected == e.id && typeOfSelected == e.runtimeType),
          e.color,
          (idSelected == e.id && typeOfSelected == e.runtimeType)
              ? e.gettingTheStringSelected()
              : e.gettingTheStringShortWithDate(), () {
        if (idSelected != e.id || typeOfSelected != e.runtimeType) {
          idSelected = e.id;
          typeOfSelected = e.runtimeType;
        } else {
          idSelected = -1;
          typeOfSelected = null;
        }
        setStateMethod();
      }),
      smallBlankSplit
    ]);
  }

  ///days
  ///requires a sorted list based on .left
  List<Widget> _createEndBasedDayList(
      void Function() setStateMethod,
      MyDateController nowDate,
      List<EndBasedController> endBasedList,
      int daysToShowNow) {
    List<Widget> againDeadlineDisplayList = [];
    int i = 0;
    if (endBasedList.isEmpty) return againDeadlineDisplayList;
    if (endBasedList.first.daysLeft == -1) {
      //-1 to also show yesterday
      i--;
    }
    for (; i < daysToShowNow; i++) {
      if (i == ObservationScreenOptions.daysToShow) {
        againDeadlineDisplayList.add(bigSplitterTextField);
      }
      againDeadlineDisplayList.addAll(createADay(
          nowDate,
          endBasedList,
          i,
          setStateMethod,
          _createButtonBase,
          i < ObservationScreenOptions.daysToShow));
    }
    return againDeadlineDisplayList;
  }

  Widget _createButtonBase(
      BasicButtonController it, void Function() setStateMethod) {
    globalCounter++;
    int index = globalCounter;
    return blagendaUniformButton(
        clicked == index,
        it.color,
        _buttonDisplay(index, it),
            () => clickOnButton(index, it.id, it.runtimeType, setStateMethod));
  }

  String _buttonDisplay(int index, BasicButtonController it) {
    return clicked == index
        ? it.gettingTheStringSelected()
        : it.gettingTheStringShort();
  }

  void _emptyDay(int daysToShow) {
    var list = [];
    for (int i = 0; i < daysToShow; i++) {
      list.add(createADay(MyDateController.today, [], i, () {},
              (p0, p1) => const Text(''), true));
    }
  }
}
