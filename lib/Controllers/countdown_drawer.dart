import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/countdown_Drawer_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/month_day_widet.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';

import '../Loading/mix_loading.dart';
import 'ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'blagenda_uniform_button.dart';

class CountdownDrawer extends StatefulWidget {
  final void Function() addToButton;

  final void Function() removeFromButton;

  const CountdownDrawer(
      this.addOrUpdateButton,
      this.resetScreen,
      this.getEndBasedButtons,
      this._flipImportant,
      this._getSelectedButton,
      this.addToButton,
      this.removeFromButton)
      : super(key: null);

  final void Function(BasicButtonController) addOrUpdateButton;
  final void Function() _flipImportant;

  final BasicButtonController? Function() _getSelectedButton;

  final void Function() resetScreen;
  final List<EndBasedController> Function() getEndBasedButtons;

  @override
  State<CountdownDrawer> createState() => _CountdownDrawerState();
}

class _CountdownDrawerState extends State<CountdownDrawer> with loading, MonthDayWidget {
  CountDownDrawerController countDownController = CountDownDrawerController();

  List<Widget> widgetList = [];

  @override
  void initState() {
    super.initState();
    countDownController
        .loadSortFillImportant(widget.getEndBasedButtons, containWidgetsPretty,
            widget.addOrUpdateButton, widget.resetScreen, () => getData<BasicButton>())
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
            border:
                Border(top: border, left: fakeBorder, right: fakeBorder, bottom: border)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: list));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
      bigSplitterTextField,
      containWidgetsPretty([
        smallBlankSplit,
        buildMonthDayWidgets(MyDateController.today.year, MyDateController.today.month),
      ]),
      bigSplitterTextField,
      containWidgetsPretty([
        smallBlankSplit,
        countDownController.updateButtonsButtons(() {
          widget._flipImportant();
          var but = widget._getSelectedButton();
          if (but == null) return;
          countDownController
              .loadSortFillImportant(
                  widget.getEndBasedButtons,
                  containWidgetsPretty,
                  widget.addOrUpdateButton,
                  widget.resetScreen,
                  () => getData<BasicButton>())
              .then((value) {
            widgetList.clear();
            widgetList.addAll(value);
            setState(() {});
          });
        }, widget.addToButton, widget.removeFromButton),
      ]),
      bigSplitterTextField,
      ...widgetList
    ])));
  }
}
