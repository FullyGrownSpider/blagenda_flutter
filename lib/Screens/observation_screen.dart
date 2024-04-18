import 'dart:async';

import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/observation_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/countdown_drawer.dart';
import 'package:blagenda_flutter_simple/Controllers/main_drawer.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Screens/search_screen.dart';
import 'package:flutter/material.dart';

import '../Commons/Models/entity.dart';
import '../Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../common_items.dart';
import 'adding_screen.dart';
import 'entity_adding_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int lastHour = 0;
  bool _wentBack = false;

  _OverviewScreenState() {
    _controller = ObservationScreenController(
        _openEntityEdit,
        (button) => _openEdit(currentContext!, button, false, (t) {
              return addOrUpdate(t);
            }));
    _drawer = MainDrawer(
        getButton,
        addOrUpdate,
        delete,
        skipButton,
        getNewId,
        getNewEntityId,
        _fullReset,
        getEndbasedData,
        getEntities,
        getButtonCopy,
        getEntityCopy);
    _countDownDrawer = CountdownDrawer(addOrUpdate, _fullReset, getEndbasedData,
        flipImportant, getButton, () => addOrRemoveDays(1), () => addOrRemoveDays(-1));
    _fill();
  }

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
    if (_controller.justAddedCheck() || awns || force) {
      if (awns || force) {
        MyDateController.resetDate();
        _controller.resetLists().then((value) {
          _resetScreen();
          lastHour = MyDateController.lookTime.hour;
          syncActionLowKey!(_reloadData);
        });
      } else {
        _resetScreen();
      }
    } else if (MyDateController.didHourPass(lastHour)) {
      lastHour = MyDateController.lookTime.hour;
      syncActionLowKey!(_reloadData);
    }
  }

  final BorderSide border = BorderSide(color: usedColors.first, width: 2);

  late final MainDrawer _drawer;
  late final CountdownDrawer _countDownDrawer;
  late final ObservationScreenController _controller;
  final List<Widget> _centerChildren = [];
  final List<Widget> _centerOptionsButton = [];

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
        body: PopScope(
            onPopInvoked: _onWillPop,
            canPop: _wentBack,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _centerChildren,
              ),
            )));
  }

  void _reloadData() {
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
    _centerChildren
        .add(containWidgetsPretty(_controller.getWidgetListEndBased(_resetScreen)));
    var notes = _controller.getWidgetListNote(_resetScreen);
    if (notes.isNotEmpty) _centerChildren.add(containWidgetsPretty(notes));
    _centerChildren.add(containWidgetsPretty((_centerOptionsButton)));
    if (!mounted) return;
    setState(() {});
  }

  Widget containWidgetsPretty(List<Widget> list) {
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
                        mainAxisAlignment: MainAxisAlignment.center, children: list)))));
  }

  void _resetButtons() {
    _centerOptionsButton.clear();
    _wentBack = false;
    _centerOptionsButton.addAll(_controller.getOptionButtons(() {
      _fullReset();
      _wentBack = false;
    }));
  }

  int getNewId(Type t) => _controller.getNewId(t);

  int getNewEntityId() => _controller.getNewEntityId();

  BasicButtonController? getButton() => _controller.getSelectedButton();

  void addOrUpdate(dynamic c) {
    if (c is EntityController) {
      _controller.addOrUpdateEntity(c);
      return;
    }
    if (c is! BasicButtonController) throw Exception('what did you do?');
    if (c.touched) {
      _controller.deleteButton(c, _resetScreen);
    } else {
      _controller.addOrUpdateButton(c, _resetScreen);
    }
    _wentBack = false;
  }

  void delete() => _controller.deleteSelected(_resetScreen);

  void skipButton() => _controller.skipButton(_resetScreen);

  void flipImportant() => _controller.flipImportant(_resetScreen);

  void addOrRemoveDays(int amount) => _controller.addOrRemoveDay(_resetScreen, amount);

  List<EndBasedController> getEndbasedData() => _controller.getEndbasedData();

  List<EntityController> getEntities() => _controller.getEntities();

  Future<dynamic> _openEntityEdit(BasicButtonController b) async {
    var c = getEntities().firstWhere((ent) => ent.tags.any((tag) {
          if (tag.data is TagObjectReference) {
            return (tag.data.type == b.runtimeType.toString() && b.id == tag.data.itd);
          }
          return BasicButtonController.equals(tag.data.button, b.button);
        }));
    if (currentContext == null) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddingEntityScreen(
                c,
                addOrUpdate,
                getNewEntityId,
                getEndbasedData,
                getEntities,
                (toUse) => _openButtonSearch(context, toUse, true),
                (toGet) => _openEdit(context, null, false, (t) {
                      toGet(t);
                      return addOrUpdate(t);
                    }))));
  }

  Future<dynamic> _openButtonSearch(BuildContext context,
      Future<dynamic> Function(dynamic)? addOrUpdateItem, bool closeOnAction) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchScreen<EndBasedController>(addOrUpdateItem!,
                getNewId, getEndbasedData(), closeOnAction, getButtonCopy)));
  }

  Future<dynamic> _openEdit(BuildContext context, BasicButtonController? it,
          bool withNote, dynamic Function(dynamic) doWith) =>
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AddingScreen(it, doWith, getNewId, getEndbasedData, withNote)));

  void _onWillPop(bool boolean) async {
    if (_wentBack) {
      _wentBack = !_wentBack;
    }
    _wentBack = !_wentBack;
    _controller.resetSearch(_fullReset);
  }

  Future<EndBasedController> getButtonCopy(EndBasedController toFind) async => _controller
      .getEndbasedData()
      .firstWhere((e) => e.id == toFind.id && e.runtimeType == toFind.runtimeType);

  Future<EntityController> getEntityCopy(EntityController toFind) async =>
      _controller.getEntities().firstWhere((e) => e.id == toFind.id);
}
