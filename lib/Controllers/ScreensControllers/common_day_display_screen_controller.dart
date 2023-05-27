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
    bool _showNamesOnly,
    [bool hideSkips = false]) {
  List<Widget> list = [];
  bool added = false;
  var calcDay = nowDate.addOrRemoveDays(fromNow);
  var calcDayColor = Text('▲',
      style: TextStyle(
          color: usedColors[calcDay.weekday % 7],
          fontSize: bigTextStyle.fontSize,
          height: bigTextStyle.height,
          fontWeight: bigTextStyle.fontWeight));
  Text toAdd;
  var sortableList = listWithEverything
      .where((e) => e.isInLeft(fromNow))
      .toList(growable: false);
  for (int i = 0; i < sortableList.length; i++) {
    if (sortableList[i] is SkippableEndBasedController) {
      sortableList[i] = (sortableList[i] as SkippableEndBasedController)
          .createNew(MyDateController.fromDaysFromNow(fromNow));
    }
  }
  sortableList.sort();
  if (_showNamesOnly) {
    if (fromNow == -1) {
      toAdd = const Text('Yesterday', style: bigTextStyleYesterday);
    } else if (fromNow == 0) {
      var dayShort = formatDate(calcDay, smallDateFormat).substring(0, 2);
      toAdd = Text('Today (' + dayShort + ')', style: bigTextStyle);
    } else {
      toAdd = Text(formatDate(calcDay, smallDateFormat), style: bigTextStyle);
    }
    list.add(Row(children: [
      calcDayColor,
      toAdd,
      calcDayColor,
    ], mainAxisAlignment: MainAxisAlignment.center));
    for (int i = 0; i < sortableList.length; i++) {
      if (sortableList[i] is SkippableEndBasedController &&
          hideSkips &&
          fromNow == sortableList[i].left &&
          (sortableList[i] as SkippableEndBasedController)
              .skipCheckNotSure(fromNow, (sortableList[i].left))) {
        continue;
      }
      list.add(smallerBlankSplit);
      list.add(addEndBasedButton(sortableList[i], setStateMethod));
      added = true;
    }
    //yesterday gets a gray box around it and today a green one
    if (fromNow < 1) {
      Container container;
      if (fromNow == -1) {
        container = Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: list),
          width: double.infinity,
          decoration: const BoxDecoration(
              color: Colors.black26,
              border: Border(
                  bottom: BorderSide(color: Colors.black38, width: 20))));
      } else {
        if(!added) {
          list.add(smallBlankSplit);
          list.add(smallBlankSplit);
          list.add(smallBlankSplit);
          list.add(smallBlankSplit);
          list.add(smallBlankSplit);
          list.add(smallBlankSplit);
        }
        list = addAdded(list, added);
        container = Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center, children: list),
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white10,
                border: Border(
                    top:BorderSide(color: Colors.green, width: 6),
                    bottom: BorderSide(color: Colors.green, width: 4))));
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
    list.add(Row(children: [
      calcDayColor,
      toAdd,
      calcDayColor,
    ], mainAxisAlignment: MainAxisAlignment.center));
    list.add(Row(children: [
      calcDayColor,
      Text('In ' + (fromNow).toString() + ' days',
          style: secondaryBigTextStyle),
      calcDayColor
    ], mainAxisAlignment: MainAxisAlignment.center));
    for (int i = 0; i < sortableList.length; i++) {
      if (sortableList[i] is SkippableEndBasedController &&
          hideSkips &&
          fromNow == sortableList[i].left &&
          (sortableList[i] as SkippableEndBasedController)
              .skipCheckNotSure(fromNow, (sortableList[i].left))) {
        continue;
      }
      list.add(smallerBlankSplit);
      list.add(addEndBasedButton(sortableList[i], setStateMethod));
      added = true;
    }
  }
  if (fromNow < 1) return list;
  list = addAdded(list,added);
  return list;
}

addAdded(List<Widget> list, bool added){
  if (added) {
    list.add(Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [smallBlankSplit]),
        decoration: const BoxDecoration(
            border:
            Border(bottom: BorderSide(color: Colors.green, width: 4)))));
  } else {
    list.add(Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              smallBlankSplit,
              smallBlankSplit,
              smallBlankSplit,
              smallBlankSplit
            ]),
        decoration: const BoxDecoration(
            border:
            Border(bottom: BorderSide(color: Colors.green, width: 4)))));
  }
  return list;
}
