import 'dart:async';

import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/observation_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/main_drawer.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';

import '../common_items.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({Key? key}) : super(key: key);

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int lastHour = 0;

  _OverviewScreenState() {
    _controller = ObservationScreenController();
    _drawer = MainDrawer(getButton, addOrUpdate, delete, skipButton,
        () => _controller.resetSearch(_fullReset), getNewId);
    _fill();
  }

  @override
  void initState() {
    super.initState();
    // defines a timer
    Timer.periodic(const Duration(seconds: 10), (Timer t) {
      _timerTick();
    });
  }

  void _timerTick() {
    bool awns = MyDateController.requiresResetDate();
    //requiresResetDate also resets last look time its semi important that its run
    if (_controller.justAddedCheck() || awns) {
      if (awns) {
        MyDateController.resetDate();
        _controller.resetLists();
        _resetScreen();
        lastHour = MyDateController.lookTime.hour;
        syncActionLowKey!(_reloadData);
      } else {
        _resetScreen();
      }
    } else if (MyDateController.hourPassed(lastHour)) {
      lastHour = MyDateController.lookTime.hour;
      syncActionLowKey!(_reloadData);
    }
  }

  late final MainDrawer _drawer;
  late final ObservationScreenController _controller;
  final List<Widget> _centerChildren = [];
  final List<Widget> _centerOptionsButton = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white24,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(10.0),
            child: AppBar(
              backgroundColor: Colors.green,
            )),
        drawer: _drawer.createDrawer(context),
        body: SingleChildScrollView(
          // child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _centerChildren,
          ),
        ));
  }

  void _reloadData(){
    _controller.loadListsFromStorage();
    _fill();
  }

  void _fill() async {
    while (!_controller.doneLoading()) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    _resetButtons();
    _resetScreen();
  }

  void _fullReset() {
    _resetButtons();
    _resetScreen();
  }

  void _resetScreen() {
    _centerChildren.clear();
    _centerChildren.addAll(_controller.getWidgetListEndBased(_resetScreen));
    _centerChildren.addAll(_controller.getWidgetListNote(_resetScreen));
    _centerChildren.addAll(_centerOptionsButton);
    if (!mounted) return;
    setState(() {});
  }

  void _resetButtons() {
    _centerOptionsButton.clear();
    _centerOptionsButton.addAll(_controller.getOptionButtons(_fullReset));
  }

  int getNewId(Type t) => _controller.getNewId(t);

  BasicButtonController? getButton() => _controller.getSelectedButton();

  void addOrUpdate(BasicButtonController c) =>
      _controller.addOrUpdateButton(c, _resetScreen);

  void delete() => _controller.deleteSelected(_resetScreen);

  void skipButton() => _controller.skipButton(_resetScreen);
}
