import 'dart:async';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/observation_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/countdown_drawer.dart';
import 'package:blagenda_flutter_simple/ScreensPhone/main_drawer.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';

import '../Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../Loading/button_notifier.dart';
import '../Loading/entity_notifier.dart';
import '../common_items.dart';
import 'adding_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen(this._buttonNotifier, this._entityNotifier, {super.key});

  final EntityNotifier _entityNotifier;
  final ButtonNotifier _buttonNotifier;

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int lastHour = 0;
  bool _wentBack = false;

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
    } else if (MyDateController.didHourPass(lastHour)) {
      lastHour = MyDateController.lookTime.hour;
      widget._buttonNotifier.dataSyncLowKey();
    } else if (_controller.justAddedCheck()) {
      setState(() {});
    }
  }

  final BorderSide border = BorderSide(color: usedColors.first, width: 2);

  late final MainDrawer _drawer =
      MainDrawer(widget._buttonNotifier, widget._entityNotifier, getButton);
  late final CountdownDrawer _countDownDrawer =
      CountdownDrawer(getButton, widget._buttonNotifier);
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
            preferredSize: const Size.fromHeight(10.0),
            child: AppBar(
              backgroundColor: Colors.green,
            )),
        drawer: _drawer.createDrawer(context),
        endDrawer: _countDownDrawer,
        body: ListenableBuilder(
            listenable: widget._buttonNotifier,
            builder: (BuildContext context, Widget? child) => ListenableBuilder(
                listenable: _controller.observationScreenOptions.getNotifier(),
                builder: (BuildContext context, Widget? child) {
                  _resetScreen();
                  return PopScope(
                      onPopInvoked: _onWillPop,
                      canPop: _wentBack,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _centerChildren,
                        ),
                      ));
                })));
  }

  void _resetScreen() {
    _centerChildren.clear();
    _centerChildren
        .add(_containWidgetsPretty(_controller.getWidgetListEndBased()));
    var notes = _controller.getWidgetListNote();
    if (notes.isNotEmpty) _centerChildren.add(_containWidgetsPretty(notes));
    _centerChildren
        .add(_containWidgetsPretty((_controller.getOptionButtons())));
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

  Future<dynamic> _openEdit(BasicButtonController? it, bool withNote) =>
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AddingScreen(it, widget._buttonNotifier, withNote)));

  void _onWillPop(bool boolean) async {
    if (Navigator.canPop(context)) return;
    if (_wentBack) {
      _wentBack = !_wentBack;
    }
    _wentBack = !_wentBack;
    _controller.resetSelects();
  }
}
