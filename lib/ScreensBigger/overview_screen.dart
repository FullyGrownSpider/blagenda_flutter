import 'dart:async';
import 'dart:math';

import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/observation_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../Controllers/blagenda_uniform_button.dart';
import '../Loading/button_notifier.dart';
import '../Loading/entity_notifier.dart';
import '../ScreensPhone/adding_screen.dart';
import '../common_items.dart';

class DesktopOverviewScreen extends StatefulWidget {
  const DesktopOverviewScreen(this._buttonNotifier, this._entityNotifier,
      {super.key});

  final EntityNotifier _entityNotifier;
  final ButtonNotifier _buttonNotifier;

  @override
  State<DesktopOverviewScreen> createState() => _DesktopOverviewScreenState();
}

class _DesktopOverviewScreenState extends State<DesktopOverviewScreen> {
  static const TextStyle infoTextStyle = TextStyle(
      fontSize: 35.0,
      height: 1.7,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      decoration: TextDecoration.underline,
      color: Colors.grey);

  static const TextStyle functionTextStyle = TextStyle(
      fontSize: 18.0,
      height: 1.3,
      fontWeight: FontWeight.bold,
      color: Colors.white);

  final int funnyNumber =
      Random(MyDateController.today.hashCode).nextInt(100) + 1;

  bool showImportantOnly = false;
  int lastHour = 0;

  @override
  void initState() {
    super.initState();
    // defines a timer
    Timer.periodic(const Duration(minutes: 2), (Timer t) {
      _timerTick();
    });
    _timerTick(true);
  }

  void _timerTick([bool force = false]) {
    bool awns = MyDateController.didDayPass();
    //requiresResetDate also resets last look time its semi important that its run
    if (awns || force) {
      MyDateController.resetDate();
      lastHour = MyDateController.lookTime.hour;
      widget._buttonNotifier
          .awaitLoading()
          .then((_) => _controller.updateButtonsDay());
      widget._buttonNotifier.dataSyncLowKey();
      if (awns) setState(() {});
    } else if (MyDateController.didHourPass(lastHour)) {
      lastHour = MyDateController.lookTime.hour;
      widget._buttonNotifier.dataSyncLowKey();
    } else if (_controller.justAddedCheck()) {
      setState(() {});
    }
  }

  final BorderSide border = BorderSide(color: usedColors.first, width: 2);

  late final ObservationScreenController _controller =
      ObservationScreenController(
          (e) => _openEdit(e, false), widget._buttonNotifier);
  final List<Widget> _centerChildren = [];

  BuildContext? currentContext;

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    return Scaffold(
        backgroundColor: Colors.white24,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: AppBar(
              backgroundColor: Colors.green,
            )),
        body: Row(children: <Widget>[
          //The options
          Expanded(child: generateMenu()),
          //the buttons
          Expanded(child: generateDayView()), //TODO if statement to switch between search, important and normal (maybe in observation screen?)
          //the entities
          Expanded(
              child: ListenableBuilder(
                  listenable: widget._entityNotifier,
                  builder: (BuildContext context, Widget? child) =>
                      Text('???')))
        ]));
  }

  Widget generateDayView() {
    return ListenableBuilder(
        listenable: widget._buttonNotifier,
        builder: (BuildContext context, Widget? child) => ListenableBuilder(
            listenable: _controller.observationScreenOptions.getNotifier(),
            builder: (BuildContext context, Widget? child) {
              _resetScreen();
              return LayoutBuilder(
                  builder: (context, constraint) => SingleChildScrollView(
                      child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraint.maxHeight),
                          child: IntrinsicHeight(
                            child: Column(
                              children: _centerChildren,
                            ),
                          ))));
            }));
  }

  Widget generateMenu() {
    return LayoutBuilder(
        builder: (context, constraint) => Container(
            decoration: const BoxDecoration(
                border: Border.fromBorderSide(
                    BorderSide(width: 2, color: Colors.green))),
            child: SingleChildScrollView(
                child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraint.maxHeight),
                    child: IntrinsicHeight(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                          Container(
                              width: double.infinity,
                              decoration:
                                  const BoxDecoration(color: Colors.black),
                              child: Column(children: [
                                Text(
                                  formatDate(MyDateController.today,
                                      [D, ', ', M, ' ', d]),
                                  style: infoTextStyle,
                                ),
                                Text(
                                    '${formatDate(MyDateController.today, [
                                          'W:',
                                          WW
                                        ])} - N:$funnyNumber',
                                    style: infoTextStyle)
                              ])),
                          Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Colors.green, width: 2),
                                      bottom: BorderSide(
                                          color: Colors.green, width: 2)),
                                  color: Colors.black),
                              child: Column(children: [
                                ListTile(
                                    title: const Text('Add Button',
                                        style: functionTextStyle),
                                    trailing: const Icon(Icons.add,
                                        color: Colors.white),
                                    onTap: () => _openEdit(null, true)
                                        .then((v) => Navigator.pop(context))),
                                ListTile(
                                    title: const Text('Update Button',
                                        style: functionTextStyle),
                                    trailing: const Icon(Icons.edit,
                                        color: Colors.white),
                                    onTap: () {
                                      var button =
                                          _controller.getSelectedButton();
                                      if (button != null) {
                                        _openEdit(button, true).then(
                                            (v) => Navigator.pop(context));
                                      }
                                    }),
                                ListTile(
                                  title: const Text('Delete Button',
                                      style: functionTextStyle),
                                  trailing: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onTap: () {
                                    var button =
                                        _controller.getSelectedButton();
                                    if (button != null) {
                                      widget._buttonNotifier.delete(button);
                                    }
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text('Skip this time',
                                      style: functionTextStyle),
                                  trailing: const Icon(Icons.next_plan_outlined,
                                      color: Colors.white),
                                  onTap: () {
                                    var button =
                                        _controller.getSelectedButton();
                                    if (button == null) return;
                                    if (button is SkippableEndBasedController) {
                                      widget._buttonNotifier
                                          .skipButton(button, button.altLeft);
                                    } else {
                                      widget._buttonNotifier.delete(button);
                                    }
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                    title: const Text('Sync Online Data',
                                        style: functionTextStyle),
                                    trailing: const Icon(Icons.sync,
                                        color: Colors.white),
                                    onTap: () =>
                                        widget._buttonNotifier.dataSync())
                              ])),
                          ...updateButtonsButtons(() {
                            var but = _controller.getSelectedButton();
                            widget._buttonNotifier.flipImportant(but);
                          }, () {
                            var but = _controller.getSelectedButton();
                            widget._buttonNotifier.changeDays(but, 1);
                          }, () {
                            var but = _controller.getSelectedButton();
                            widget._buttonNotifier.changeDays(but, -1);
                          }, () {
                            showImportantOnly = !showImportantOnly;
                            //TODO make work
                          }),
                              //TODO find appointment
                          ..._controller.getOptionButtons()
                        ]))))));
  }

  void _resetScreen() {
    _centerChildren.clear();
    _centerChildren
        .add(_containWidgetsPretty(_controller.getWidgetListEndBased()));
    var notes = _controller.getWidgetListNote();
    if (notes.isNotEmpty) _centerChildren.add(_containWidgetsPretty(notes));
  }

  Widget _containWidgetsPretty(List<Widget> list) {
    return Container(
        padding: const EdgeInsets.only(bottom: 5),
        width: double.infinity,
        decoration: BoxDecoration(border: Border(bottom: border)),
        child: Container(
            padding: const EdgeInsets.only(bottom: 3),
            width: double.infinity,
            decoration: BoxDecoration(border: Border(bottom: border)),
            child: Container(
                padding: const EdgeInsets.only(bottom: 1),
                width: double.infinity,
                decoration: BoxDecoration(border: Border(bottom: border)),
                child: Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border(bottom: border)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: list)))));
  }

  BasicButtonController? getButton() => _controller.getSelectedButton();

  List<Widget> updateButtonsButtons(
          void Function() flipImportant, addDays, removeDays, showImportant) =>
      [
        BlagendaUniformButton(
            usedColors[4], () => 'Important Flip', flipImportant),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          BlagendaUniformButton(usedColors[4], () => '↑ Day ↑', removeDays),
          BlagendaUniformButton(usedColors[4], () => '↓ Day ↓', addDays),
        ]),
        BlagendaUniformButton(
            usedColors[4],
            () => showImportantOnly
                ? 'Show Important Items'
                : 'Show Normal Calendar',
            showImportant)
      ];

  Future<dynamic> _openEdit(BasicButtonController? it, bool withNote) =>
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AddingScreen(it, widget._buttonNotifier, withNote)));
}
