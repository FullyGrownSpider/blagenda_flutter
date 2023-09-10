import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/end_based_controller.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../my_date_controller.dart';
import 'common_screen_controller.dart';

const List<String> bigDateFormat = [D, ', ', M, ' ', d];

const List<String> bigDateFormatWithYear = [D, ', ', M, ' ', d, ', ', yyyy];

const List<String> smallDateFormat = [D];

List<Widget> createADay(
    MyDateController nowDate,
    List<EndBasedController> listWithEverything,
    int fromNow,
    void Function() setStateMethod,
    Widget Function(EndBasedController, void Function()) addEndBasedButton,
    bool showNamesOnly,
    [bool hideSkips = false]) {
  List<Widget> list = [];
  bool added = false;
  var calcDay = nowDate.addOrRemoveDays(fromNow);
  var left = _createCalcDayColor(
      listWithEverything
          .any((e) => e is DeadlineController && e.daysLeft == fromNow + 7),
      '◮',
      calcDay);
  var right = _createCalcDayColor(
      listWithEverything
          .any((e) => e is AgainYearController && e.isHappeningOnDayFromNow(fromNow + 7)),
      '◭',
      calcDay);
  Text toAdd;
  var sortableList = listWithEverything
      .where((e) => e.isHappeningOnDayFromNow(fromNow))
      .toList(growable: false);
  for (var item in sortableList) {
    if (item is SkippableEndBasedController) {
      item = item
          .createNew(MyDateController.fromDaysFromNow(fromNow));
    }
  }
  sortableList.sort();
  if (showNamesOnly) {
    if (fromNow == -1) {
      if (_yesterdayShouldShow(listWithEverything
          .where((e) => e.daysLeft == -1)
          .toList(growable: false))) return list;
      toAdd = const Text('Yesterday', style: bigTextStyleYesterday);
    } else if (fromNow == 0) {
      var dayShort = formatDate(calcDay, smallDateFormat).substring(0, 2);
      toAdd = Text('Today ($dayShort)', style: bigTextStyle);
    } else {
      toAdd = Text(formatDate(calcDay, smallDateFormat), style: bigTextStyle);
    }
    list.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [left, toAdd, right]));
    for (var item in sortableList) {
      if (item is SkippableEndBasedController &&
          hideSkips &&
          fromNow == item.daysLeft &&
          item
              .skipCheckNotSure(fromNow, (item.daysLeft))) {
        continue;
      }
      list.add(smallerBlankSplit);
      list.add(addEndBasedButton(item, setStateMethod));
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
                border: Border(
                    bottom: BorderSide(color: Colors.black38, width: 20))),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center, children: list));
      } else {
        if (!added) {
          list.add(smallBlankSplit);
          list.add(smallBlankSplit);
          list.add(smallBlankSplit);
          list.add(smallBlankSplit);
          list.add(smallBlankSplit);
          list.add(smallBlankSplit);
        }
        list = addAdded(list, added);
        container = Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white10,
                border: Border(
                    top: BorderSide(color: Colors.green, width: 6),
                    bottom: BorderSide(color: Colors.green, width: 4))),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center, children: list));
      }
      list = <Widget>[];
      list.add(container);
    }
  } else {
    var newDate = nowDate.addOrRemoveDays(fromNow);
    if (newDate.year == nowDate.year) {
      toAdd = Text(formatDate(newDate, bigDateFormat), style: bigTextStyle);
    } else {
      toAdd =
          Text(formatDate(newDate, bigDateFormatWithYear), style: bigTextStyle);
    }
    list.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [left, toAdd, right]));
    list.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      left,
      Text('In ${(fromNow).toString()} days', style: secondaryBigTextStyle),
      right,
    ]));
    for (var item in sortableList) {
      if (item is SkippableEndBasedController &&
          hideSkips &&
          fromNow == item.daysLeft &&
          item
              .skipCheckNotSure(fromNow, (item.daysLeft))) {
        continue;
      }
      list.add(smallerBlankSplit);
      list.add(addEndBasedButton(item, setStateMethod));
      added = true;
    }
  }
  if (fromNow < 1) return list;
  list = addAdded(list, added);
  return list;
}

_createCalcDayColor(bool any, String s, MyDateController calcDay) {
  return Text(any ? s : '▲',
      style: TextStyle(
          color: usedColors[calcDay.weekday % 7],
          fontSize: bigTextStyle.fontSize,
          height: bigTextStyle.height,
          fontWeight: bigTextStyle.fontWeight));
}

bool _yesterdayShouldShow(List<EndBasedController> list) {
  return !list
      .any((e) => !(e is SkippableEndBasedController && e.inTheNextDays(7)));
}

addAdded(List<Widget> list, bool added) {
  if (added) {
    list.add(Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.green, width: 4))),
        child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [smallBlankSplit])));
  } else {
    list.add(Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.green, width: 4))),
        child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              smallBlankSplit,
              smallBlankSplit,
              smallBlankSplit,
              smallBlankSplit
            ])));
  }
  return list;
}
