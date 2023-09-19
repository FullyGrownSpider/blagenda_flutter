import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/end_based_controller.dart';
import 'package:flutter/material.dart';

import '../common_items.dart';
import 'ButtonControllers/note_controller.dart';
import 'ScreensControllers/common_screen_controller.dart';
import 'ScreensControllers/observation_screen_controller.dart';

class CountdownDrawer extends StatefulWidget {
  const CountdownDrawer(this.addOrUpdateButton, this.resetScreen)
      : super(key: null);

  final void Function(BasicButtonController) addOrUpdateButton;

  final void Function() resetScreen;

  @override
  State<CountdownDrawer> createState() => _CountdownDrawerState();
}

class _CountdownDrawerState extends State<CountdownDrawer> {
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
    endButtons.addAll((await loading.getEndBasedButtons())
        .where((e) => e.important && e.daysLeft > -1));
    endButtons.sort();
    notes.addAll(
        (await loading.getButtons<NoteController>()).where((e) => e.important));
    widgetList.clear();
    for (int i = 0; i < 4; i++) {
      widgetList.add(splitterTextField);
    }
    widgetList.add(bigSplitterTextField);
    widgetList.add(splitterTextField);
    widgetList.add(splitterTextField);
    for (var note in notes) {
      widgetList.add(containWidgetsPretty([
        blagendaUniformButton(
            false,
            note.color,
            BasicButtonController.displayGenericJob(note.job, 25),
            () => createUnimportantButton(note))
      ]));
      widgetList.add(bigSplitterTextField);
      widgetList.add(splitterTextField);
      widgetList.add(splitterTextField);
    }
    for (var but in endButtons) {
      widgetList.add(containWidgetsPretty([
        blagendaUniformButton(
            false,
            ObservationScreenController.daysToShow < but.daysLeft
                ? but.color
                : lerpIt(but.color),
            BasicButtonController.displayGenericJob(but.gettingTheStringShortWithTime(), 25),
            () => createUnimportantButton(but)),
        createCountDownText(but)
      ]));
      widgetList.add(bigSplitterTextField);
      widgetList.add(splitterTextField);
      widgetList.add(splitterTextField);
    }
    widgetList.add(bigSplitterTextField);
    widgetList.add(bigSplitterTextField);
    widgetList.add(bigSplitterTextField);
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
    return blagendaUniformButton(
        false, usedColors[4], 'In ${it.daysLeft} days.', () {});
  }

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
        child: SingleChildScrollView(child: Column(children: widgetList)));
  }
}
