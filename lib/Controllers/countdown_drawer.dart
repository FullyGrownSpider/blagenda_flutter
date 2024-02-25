import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:flutter/material.dart';

import '../Loading/mix_loading.dart';
import '../common_items.dart';
import 'ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'ObjectControllers/ButtonControllers/note_controller.dart';
import 'ScreensControllers/ObservationScreen/observation_screen_options.dart';
import 'ScreensControllers/mix_button_creator.dart';

class CountdownDrawer extends StatefulWidget {
  const CountdownDrawer(this.addOrUpdateButton, this.resetScreen, this.getEndBasedButtons)
      : super(key: null);

  final void Function(BasicButtonController) addOrUpdateButton;

  final void Function() resetScreen;
  final List<EndBasedController> Function() getEndBasedButtons;

  @override
  State<CountdownDrawer> createState() => _CountdownDrawerState();
}

class _CountdownDrawerState extends State<CountdownDrawer> with buttonCreator, loading {
  static const border = BorderSide(color: Colors.black38, width: 7);
  static const fakeBorder = BorderSide(color: Colors.transparent, width: 30);

  List<Widget> widgetList = [];

  @override
  void initState() {
    super.initState();
    loadSortFill();
  }

  Future<void> loadSortFill() async {
    List<EndBasedController> endButtons = [];
    List<BasicButtonController> notes = [];
    var walkList = widget.getEndBasedButtons();
    endButtons.addAll(walkList.where((e) => e.important && e.daysLeft > -1));
    var complicatedList = walkList
        .where((e) => e.important && e.daysLeft == -1 && e is SkippableEndBasedController)
        .toList();
    if (complicatedList.isNotEmpty) {
      for (int i = 0; i < 400; i++) {
        for (int ii = 0; ii < complicatedList.length; ii++) {
          if (complicatedList[ii].isHappeningOnDayFromNow(i)) {
            endButtons
                .add((complicatedList[ii] as SkippableEndBasedController).createNew(i));
            complicatedList.removeAt(ii);
          }
        }
        if (complicatedList.isEmpty) break;
      }
    }

    endButtons.sort();
    notes.addAll((await getData<BasicButton>())
        .where((e) => e.important)
        .toList()
        .cast<NoteController>());
    widgetList.clear();
    for (int i = 0; i < 4; i++) {
      widgetList.add(buttonCreator.splitterTextField);
    }
    widgetList.add(buttonCreator.bigSplitterTextField);
    widgetList.add(buttonCreator.splitterTextField);
    widgetList.add(buttonCreator.splitterTextField);
    for (var note in notes) {
      widgetList.add(containWidgetsPretty([
        blagendaUniformButton(false, note.color, note.displayGenericText(note.job, 25),
            () => createUnimportantButton(note))
      ]));
      widgetList.add(buttonCreator.bigSplitterTextField);
      widgetList.add(buttonCreator.splitterTextField);
      widgetList.add(buttonCreator.splitterTextField);
    }
    for (var but in endButtons) {
      bool displayAble = ObservationScreenOptions.daysToShow < but.daysLeft + 1 ||
          (but is SkippableEndBasedController &&
              ObservationScreenOptions.daysToShow < but.altLeft + 1);
      widgetList.add(containWidgetsPretty([
        blagendaUniformButton(
            false,
            displayAble ? but.color : lerpIt(but.color),
            but.displayGenericText(but.gettingTheStringShort(), 25),
            () => createUnimportantButton(but)),
        if (displayAble) createCountDownText(but)
      ]));
      widgetList.add(buttonCreator.bigSplitterTextField);
      widgetList.add(buttonCreator.splitterTextField);
      widgetList.add(buttonCreator.splitterTextField);
    }
    widgetList.add(buttonCreator.bigSplitterTextField);
    widgetList.add(buttonCreator.bigSplitterTextField);
    widgetList.add(buttonCreator.bigSplitterTextField);
    setState(() {});
  }

  Function createUnimportantButton(BasicButtonController it) {
    return () {
      it.flipImportant();
      widget.addOrUpdateButton(it);
      widget.resetScreen();
    };
  }

  Widget createCountDownText(EndBasedController it) {
    if (it is SkippableEndBasedController) {
      return blagendaUniformButton(false, usedColors[4], 'In ${it.altLeft} days.', () {});
    }
    return blagendaUniformButton(false, usedColors[4], 'In ${it.daysLeft} days.', () {});
  }

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
    return Drawer(child: SingleChildScrollView(child: Column(children: widgetList)));
  }
}
