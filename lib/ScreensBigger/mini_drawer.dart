import 'dart:math';

import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../Controllers/ScreensControllers/countdown_drawer_controller.dart';
import '../Controllers/blagenda_uniform_button.dart';
import '../common_items.dart';
import 'overview_screen.dart';

const TextStyle infoTextStyle = TextStyle(
    fontSize: 35.0,
    height: 1.7,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    decoration: TextDecoration.underline,
    color: Colors.grey);

const TextStyle functionTextStyle = TextStyle(
    fontSize: 18.0,
    height: 1.3,
    fontWeight: FontWeight.bold,
    color: Colors.white);

final int _funnyNumber =
    Random(MyDateController.today.hashCode).nextInt(100) + 1;

Widget generateMenu(
    CountDownDrawerController countDownController,
    ButtonNotifier buttonNotifier,
    BasicButtonController? Function() getSelectedButton,
    void Function(BasicButtonController?, bool) openEdit,
    void Function() openEntityEdit,
    List<Widget> Function(bool) getOptionButtons,
    void Function() showImportant,
    void Function() showSearchOrOverview,
    ButState butState,
    EntityState entityState) {
  return LayoutBuilder(
      builder: (context, constraint) => Container(
          decoration: const BoxDecoration(
              border: Border.fromBorderSide(
                  BorderSide(width: 2, color: Colors.green))),
          child: SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
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
                                      ])} - N:$_funnyNumber',
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
                                  onTap: () {
                                    openEdit(null, true);
                                  }),
                              ListTile(
                                  title: const Text('Update Button',
                                      style: functionTextStyle),
                                  trailing: const Icon(Icons.edit,
                                      color: Colors.white),
                                  onTap: () {
                                    var button = getSelectedButton();
                                    if (button != null) {
                                      openEdit(button, true);
                                    }
                                  }),
                              ListTile(
                                title: const Text('Delete Button',
                                    style: functionTextStyle),
                                trailing: const Icon(Icons.delete,
                                    color: Colors.white),
                                onTap: () {
                                  var button = getSelectedButton();
                                  if (button != null) {
                                    buttonNotifier.delete(button);
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
                                  var button = getSelectedButton();
                                  if (button == null) return;
                                  if (button is SkippableEndBasedController) {
                                    buttonNotifier.skipButton(
                                        button, button.altLeft);
                                  } else {
                                    buttonNotifier.delete(button);
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                  title: Text(
                                      entityState == EntityState.search
                                          ? 'Add Entity'
                                          : 'Finish Entity',
                                      style: functionTextStyle),
                                  trailing: const Icon(Icons.add,
                                      color: Colors.white),
                                  onTap: () {
                                    openEntityEdit();
                                  }),
                              ListTile(
                                  title: const Text('Sync Online Data',
                                      style: functionTextStyle),
                                  trailing: const Icon(Icons.sync,
                                      color: Colors.white),
                                  onTap: () => buttonNotifier.dataSync())
                            ])),
                        smallBlankSplit,
                        BlagendaUniformButton(usedColors[7], () {
                          switch (butState) {
                            case ButState.overView:
                              return 'Search';
                            default:
                              return 'Show Calendar';
                          }
                        }, showSearchOrOverview),
                        smallBlankSplit,
                        smallBlankSplit,
                        BlagendaUniformButton(usedColors[4],
                            () => 'Search Important', showImportant),
                        smallBlankSplit,
                        smallBlankSplit,
                        smallBlankSplit,
                        countDownController.updateButtonsButtons(() {
                          var but = getSelectedButton();
                          buttonNotifier.flipImportant(but);
                        }, () {
                          var but = getSelectedButton();
                          buttonNotifier.changeDays(but, 1);
                        }, () {
                          var but = getSelectedButton();
                          buttonNotifier.changeDays(but, -1);
                        }),
                        ...bOptions(getOptionButtons(false)),
                        smallBlankSplit
                      ]))))));
}

List<Widget> bOptions(List<Widget> options) {
  var clone = [...options];
  int oldLength = options.length;
  //1, (1,1) 3, (2,2) 5, (3,3) 7
  for (int i = 0; i < oldLength; i++) {
    clone.insert(i * 2 + 1, smallBlankSplit);
  }
  return clone;
}
