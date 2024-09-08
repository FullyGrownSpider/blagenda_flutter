import 'dart:async';

import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/mix_search_able.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/observation_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/search_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/ScreensBigger/mini_add_button_screen.dart';
import 'package:flutter/material.dart';

import '../Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../Controllers/ObjectControllers/entity_controller.dart';
import '../Controllers/ScreensControllers/countdown_drawer_controller.dart';
import '../Loading/button_notifier.dart';
import '../Loading/entity_notifier.dart';
import 'mini_add_entity_screen.dart';
import 'mini_drawer.dart';
import 'mini_overview_screen.dart';
import 'mini_search_screen.dart';

class DesktopOverviewScreen extends StatefulWidget {
  const DesktopOverviewScreen(this._buttonNotifier, this._entityNotifier,
      {super.key});

  final EntityNotifier _entityNotifier;
  final ButtonNotifier _buttonNotifier;

  @override
  State<DesktopOverviewScreen> createState() => _DesktopOverviewScreenState();
}

class _DesktopOverviewScreenState extends State<DesktopOverviewScreen> {
  late final ObservationScreenController _observationController =
      ObservationScreenController(
          (e) => _openEdit(e, false), widget._buttonNotifier);

  final CountDownDrawerController _countDownController =
      CountDownDrawerController();

  int lastHour = 0;

  late final SearchScreenController<BasicButtonController>
      searchButtonController = SearchScreenController(
          _doActionWithClickedButton, widget._buttonNotifier);
  late final SearchScreenController<EntityController> searchEntityController =
      SearchScreenController(
          _doActionWithClickedEntity, widget._entityNotifier);

  ButState butState = ButState.overView;
  EntityState entityState = EntityState.search;
  BasicButtonController? selectedButton;
  EntityController? selectedEntity;

  MiniAddEntityScreen? currentEntityAdding;

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
          .then((_) => _observationController.updateButtonsDay());
      widget._buttonNotifier.dataSyncLowKey();
      if (awns) setState(() {});
    } else if (MyDateController.didHourPass(lastHour)) {
      lastHour = MyDateController.lookTime.hour;
      widget._buttonNotifier.dataSyncLowKey();
    } else if (_observationController.justAddedCheck()) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white24,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: AppBar(
              backgroundColor: Colors.green,
            )),
        body: Row(children: <Widget>[
          //The options
          Expanded(
              flex: 2,
              child: generateMenu(
                  _countDownController,
                  widget._buttonNotifier,
                  _observationController.getSelectedButton,
                  _openEdit,
                  _toggleEntityAdding,
                  _observationController.getOptionButtons,
                  showImportant,
                  showSearch,
                  butState, entityState)),
          //the buttons
          Expanded(flex: 3, child: pickCorrectCenter()),
          //the entities
          Expanded(
              flex: 3,
              child: ListenableBuilder(
                  listenable: widget._entityNotifier,
                  builder: (BuildContext context, Widget? child) =>
                      pickCorrectRight()))
        ]));
  }

  void showImportant() {
    setState(() {
      butState = ButState.important;
    });
  }

  void showSearch() {
    setState(() {
      switch (butState) {
        case ButState.overView:
          butState = ButState.search;
          break;
        default:
          butState = ButState.overView;
          break;
      }
    });
  }

  BasicButtonController? getButton() =>
      _observationController.getSelectedButton();

  void _openEdit(BasicButtonController? it, bool _) async {
    selectedButton = it;
    setState(() {
      butState = ButState.adding;
    });
  }

  Future<void> _doActionWithClickedButton(SearchAble p1) async {
    selectedButton = p1 as BasicButtonController;
    setState(() {
      butState = ButState.adding;
    });
    return;
  }

  Future<BasicButtonController?> openSearchGetAwns() async {
    setState(() {
      butState = ButState.search;
    });
    return selectedButton;
  }

  Future<void> _doActionWithClickedEntity(SearchAble p1) async {
    selectedEntity = p1 as EntityController;
    setState(() {
      entityState = EntityState.adding;
    });
    return;
  }

  void _toggleEntityAdding() {
    if (entityState != EntityState.adding) {
      setState(() {
        entityState = EntityState.adding;
      });
    } else {
      if (currentEntityAdding != null){
        var entity = currentEntityAdding!.getEntity();
        if (entity != null){
          widget._entityNotifier.addOrUpdate(entity);
        }
      }
      setState(() {
        entityState = EntityState.search;
      });
    }
  }

  Widget pickCorrectCenter() {
    switch (butState) {
      case ButState.adding:
        var currentAdding = MiniAddButtonScreen(
            selectedButton ?? _observationController.getSelectedButton(),
            widget._buttonNotifier,
            true);
        selectedButton = null;
        return currentAdding.makeAddingButtonScreen();
      case ButState.search:
        return search(widget._buttonNotifier, searchButtonController);
      case ButState.important:
        return Column(
            children: _countDownController.loadSortFillImportant(
                widget._buttonNotifier.getEndBasedData,
                containWidgetsPretty,
                _doActionWithClickedButton,
                widget._buttonNotifier
                    .getData()
                    .whereType<NoteController>()
                    .toList));
      default:
        return generateDayView(
            _observationController.getWidgetListEndBased,
            _observationController.getWidgetListNote,
            widget._buttonNotifier,
            _observationController.observationScreenOptions.getNotifier);
    }
  }

//TODO make pretty
  Widget containWidgetsPretty(List<Widget> list) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.black26,
            border: Border(
                // top: border,
                // left: fakeBorder,
                // right: fakeBorder,
                bottom: border)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: list));
  }

  Widget pickCorrectRight() {
    Widget body;
    switch (entityState) {
      case EntityState.adding:
        currentEntityAdding = MiniAddEntityScreen(
            selectedEntity,
            openSearchGetAwns,
            (s) => _openEdit(s as BasicButtonController, s is NoteController),
            widget._buttonNotifier,
            widget._entityNotifier);
        selectedEntity = null;
        body = currentEntityAdding!.makeAddingEntityScreen();
        break;
      default:
        body = search(widget._entityNotifier, searchEntityController);
        break;
    }
    return Container(
        constraints: const BoxConstraints(
            minHeight: double.infinity, minWidth: double.infinity),
        decoration: const BoxDecoration(
            border: Border.fromBorderSide(
                BorderSide(width: 2, color: Colors.green))),
        child: body);
  }

}

enum ButState { overView, search, adding, important }

enum EntityState {
  search,
  adding,
}
