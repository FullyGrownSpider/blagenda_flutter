import 'dart:math';

import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Screens/adding_screen.dart';
import 'package:blagenda_flutter_simple/Screens/search_screen.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../common_items.dart';
import 'ScreensControllers/common_day_display_screen_controller.dart';
import 'ScreensControllers/common_screen_controller.dart';

class MainDrawer {
  static const TextStyle textStyle = TextStyle(
      fontSize: 35.0,
      height: 1.7,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      decoration: TextDecoration.underline,
      color: Colors.grey);

  static const ListTile listSep = ListTile(
      title: Text('--------------------------------------------',
          style: normalTextStyle));

  MainDrawer(this.getSelectedButton, this.addOrUpdateButton, this.deleteButton,
      this.skipButton, this.resetScreen, this.getNewId);

  final BasicButtonController? Function() getSelectedButton;
  final Function(BasicButtonController) addOrUpdateButton;
  final void Function() deleteButton;
  final void Function() skipButton;
  final void Function() resetScreen;
  final int Function(Type) getNewId;
  static const Color sepColor = Colors.black54;

  Drawer createDrawer(BuildContext context) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        DrawerHeader(
          padding: const EdgeInsets.all(0.0),
          child: Center(
              child: Column(children: [
            Text(
              formatDate(MyDateController.today, bigDateFormat),
              style: textStyle,
            ),
            Text(formatDate(MyDateController.today,['W:', WW]) + " - N:" + (Random(MyDateController.today.hashCode).nextInt(100) + 1).toString(),style: textStyle)
          ])),
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
        Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: const Text('Add Button', style: normalTextStyle),
                    trailing: const Icon(Icons.add, color: Colors.black),
                    onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddingScreen(
                                    null, addOrUpdateButton, getNewId)))
                        .then((v) => Navigator.pop(context)),
                  ),
                  ListTile(
                      title:
                          const Text('Update Button', style: normalTextStyle),
                      trailing: const Icon(Icons.edit, color: Colors.black),
                      onTap: () {
                        var button = getSelectedButton();
                        if (button != null) {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddingScreen(
                                          button, addOrUpdateButton, getNewId)))
                              .then((v) => Navigator.pop(context));
                        }
                      }),
                  ListTile(
                    title: const Text('Delete Button', style: normalTextStyle),
                    trailing: const Icon(Icons.delete, color: Colors.black),
                    onTap: () {
                      deleteButton();
                      Navigator.pop(context);
                    },
                  )
                ]),
            width: double.infinity,
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: sepColor, width: 7)))),
        ListTile(
          title: const Text('Reset Display', style: normalTextStyle),
          trailing: const Icon(Icons.restart_alt_rounded, color: Colors.black),
          onTap: () {
            resetScreen();
            Navigator.pop(context);
          },
        ),
        Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title:
                        const Text('Find Appointment', style: normalTextStyle),
                    trailing: const Icon(Icons.search, color: Colors.black),
                    onTap: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen(
                                      addOrUpdateButton, getNewId)))
                          .then((v) => Navigator.pop(context));
                    },
                  ),
                ]),
            width: double.infinity,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: sepColor, width: 11),
                    top: BorderSide(color: sepColor, width: 9)))),
        ListTile(
          title: const Text('Skip this time', style: normalTextStyle),
          trailing: const Icon(Icons.next_plan_outlined, color: Colors.black),
          onTap: () {
            skipButton();
            Navigator.pop(context);
          },
        ),
        Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title:
                        const Text('Sync Online Data', style: normalTextStyle),
                    trailing: const Icon(Icons.sync, color: Colors.black),
                    onTap: () {
                      syncAction!();
                    },
                  )
                ]),
            width: double.infinity,
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: sepColor, width: 13)))),
      ],
    ));
  }
}
