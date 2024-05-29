import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/weird_again_controller.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../../common_items.dart';
import '../ObjectControllers/ButtonControllers/deadline_controller.dart';
import '../ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../blagenda_uniform_button.dart';
import '../my_date_controller.dart';

const List<String> _bigDateFormat = [D, ', ', M, ' ', d];

const List<String> _bigDateFormatWithYear = [D, ', ', M, ' ', d, ', ', yyyy];

const List<String> _smallDateFormat = [D];

mixin dayCreator {
  List<Widget> createADay(
      MyDateController nowDate,
      List<EndBasedController> listWithEverything,
      int fromNow,
      void Function() setStateMethod,
      Widget Function(EndBasedController, void Function(), bool) addEndBasedButton,
      bool showNamesOnly,
      bool showFirst,
      [bool shouldHideSkips = false,
      void Function(int)? clickOnDay]) {
    List<Widget> list = [];
    bool added = false;
    var calcDay = nowDate.addOrRemoveDays(fromNow);
    var left = _createCalcDayColor(
        listWithEverything
            .any((e) => e is DeadlineController && e.daysLeft == fromNow + 7),
        '◮',
        calcDay);
    var right = _createCalcDayColor(
        listWithEverything.any((e) =>
            (e is AgainYearController || (e is AgainWeirdController && e.day > 12)) &&
            e.isHappeningOnDayFromNow(fromNow + 7)),
        '◭',
        calcDay);
    Text toAdd;
    var sortableList =
        listWithEverything.where((e) => e.isHappeningOnDayFromNow(fromNow)).toList();
    var listWithExtra = listWithEverything
        .where((e) => !e.isHappeningOnDayFromNow(fromNow) && e.extraGoingOn(fromNow))
        .toList();
    for (int i = 0; i < sortableList.length; i++) {
      if (sortableList[i] is SkippableEndBasedController) {
        sortableList[i] =
            (sortableList[i] as SkippableEndBasedController).createNew(fromNow);
      }
    }
    sortableList.sort();
    if (showNamesOnly) {
      if (fromNow == -1) {
        if (_yesterdayShouldShow(listWithEverything
            .where((e) => e.daysLeft == -1 || e.extraGoingOn(-1))
            .toList(growable: false))) {
          return list;
        }
        toAdd = const Text('Yesterday', style: bigTextStyleYesterday);
      } else if (fromNow == 0) {
        var dayShort = formatDate(calcDay, _smallDateFormat).substring(0, 2);
        toAdd = Text('Today ($dayShort)', style: bigTextStyle);
      } else {
        toAdd = Text(formatDate(calcDay, _smallDateFormat), style: bigTextStyle);
      }
      var dayDisplayButton = _createDayButton(clickOnDay, toAdd, fromNow);
      list.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [left, dayDisplayButton, right]));
      for (var item in listWithExtra) {
        if (showFirst) {
          list.add(addEndBasedButton(item, setStateMethod, false));
        } else {
          list.add(addEndBasedButton(item, setStateMethod, true));
        }
        added = true;
      }
      for (var item in sortableList) {
        if (item is SkippableEndBasedController &&
            shouldHideSkips &&
            item.skipCheckNotSure(fromNow)) {
          continue;
        }
        list.add(addEndBasedButton(item, setStateMethod, false));
        added = true;
      }
      //yesterday gets a gray box around it and today a green one
      if (fromNow < 1) {
        Container container;
        if (fromNow == -1) {
          container = Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.black26,
                  border: Border(bottom: BorderSide(color: Colors.black38, width: 20))),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: list));
        } else {
          if (!added) {
            list.add(medBlankSplit);
            list.add(medBlankSplit);
          }
          list.add(medBlankSplit);
          container = Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white10,
                  border: Border(
                      top: BorderSide(color: Colors.green, width: 6),
                      bottom: BorderSide(color: Colors.green, width: 4))),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: list));
        }

        list = <Widget>[];
        list.add(container);
        list.add(medBlankSplit);
      }
    } else {
      var newDate = nowDate.addOrRemoveDays(fromNow);
      if (newDate.year == nowDate.year) {
        toAdd = Text(formatDate(newDate, _bigDateFormat), style: bigTextStyle);
      } else {
        toAdd = Text(formatDate(newDate, _bigDateFormatWithYear), style: bigTextStyle);
      }
      var dayDisplayButton = _createDayButton(clickOnDay, toAdd, fromNow);
      list.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [left, dayDisplayButton, right]));
      list.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        left,
        Text('In ${(fromNow).toString()} days', style: secondaryBigTextStyle),
        right,
      ]));
      for (var item in listWithExtra) {
        if (showFirst) {
          list.add(addEndBasedButton(item, setStateMethod, false));
        } else {
          list.add(addEndBasedButton(item, setStateMethod, true));
        }
        added = true;
      }
      for (var item in sortableList) {
        if (item is SkippableEndBasedController &&
            shouldHideSkips &&
            item.skipCheckNotSure(fromNow)) {
          continue;
        }
        list.add(addEndBasedButton(item, setStateMethod, false));
        added = true;
      }
    }
    if (fromNow < 1) return list;
    list = addAdded(list, added);
    return list;
  }

  Text _createCalcDayColor(bool any, String s, MyDateController calcDay) {
    return Text(any ? s : '▲',
        style: TextStyle(
            color: usedColors[calcDay.weekday % 7],
            fontSize: bigTextStyle.fontSize,
            height: bigTextStyle.height,
            fontWeight: bigTextStyle.fontWeight));
  }

  bool _yesterdayShouldShow(List<EndBasedController> list) {
    return !list.any((e) => !(e is SkippableEndBasedController && e.inTheNextDays(7)));
  }

  List<Widget> addAdded(List<Widget> list, bool added) {
    if (added) {
      list.add(Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.green, width: 4))),
          child: const Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [smallBlankSplit])));
    } else {
      list.add(Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.green, width: 4))),
          child: const Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [medBlankSplit])));
    }
    return list;
  }

  _createDayButton(void Function(int)? clickOnDay, Text toAdd, int fromNow) {
    return TextButton(
        onPressed: clickOnDay == null ? null : () => clickOnDay(fromNow), child: toAdd);
  }
}
