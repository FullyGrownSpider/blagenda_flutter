import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/countdown_drawer_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/month_day_widet.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:flutter/material.dart';

import 'ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'blagenda_uniform_button.dart';

class CountdownDrawer extends StatefulWidget {
  const CountdownDrawer(this._getSelectedButton, this._notifier)
      : super(key: null);

  final BasicButtonController? Function() _getSelectedButton;
  final ButtonNotifier _notifier;

  @override
  State<CountdownDrawer> createState() => _CountdownDrawerState();
}

class _CountdownDrawerState extends State<CountdownDrawer> with MonthDayWidget {
  CountDownDrawerController countDownController = CountDownDrawerController();

  List<Widget> widgetList = [];

  @override
  void initState() {
    super.initState();
    countDownController
        .loadSortFillImportant(
            widget._notifier.getEndbasedData,
            containWidgetsPretty,
            widget._notifier.addOrUpdate,
            widget._notifier.getData().whereType<NoteController>().toList)
        .then((value) {
      widgetList.clear();
      widgetList.addAll(value);
      setState(() {});
    });
  }

  static const border = BorderSide(color: Colors.black38, width: 7);
  static const fakeBorder = BorderSide(color: Colors.transparent, width: 30);

  Widget containWidgetsPretty(List<Widget> list) {
    return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.black26,
            border: Border(
                top: border,
                left: fakeBorder,
                right: fakeBorder,
                bottom: border)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: list));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
      bigSplitterTextField,
      containWidgetsPretty([
        smallBlankSplit,
        buildMonthDayWidgets(
            MyDateController.today.year, MyDateController.today.month),
      ]),
      bigSplitterTextField,
      containWidgetsPretty([
        smallBlankSplit,
        countDownController.updateButtonsButtons(() {
          var but = widget._getSelectedButton();
          widget._notifier.flipImportant(but);
          if (but == null) return;
          countDownController
              .loadSortFillImportant(
                  widget._notifier.getEndbasedData,
                  containWidgetsPretty,
                  widget._notifier.addOrUpdate,
                  widget._notifier.getData().whereType<NoteController>().toList)
              .then((value) {
            widgetList.clear();
            widgetList.addAll(value);
            setState(() {});
          });
        }, () {
          var but = widget._getSelectedButton();
          widget._notifier.changeDays(but, 1);
        }, () {
          var but = widget._getSelectedButton();
          widget._notifier.changeDays(but, -1);
        }),
      ]),
      bigSplitterTextField,
      ...widgetList
    ])));
  }
}
