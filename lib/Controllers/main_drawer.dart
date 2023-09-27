import 'dart:math';

import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/photo_deadline.dart';
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

  MainDrawer(
      this.getSelectedButton,
      this.addOrUpdateButton,
      this.deleteButton,
      this.skipButton,
      this.searchResetScreen,
      this.getNewId,
      this.fullReset,
      this.flipImportant);

  final BasicButtonController? Function() getSelectedButton;
  final Function(BasicButtonController) addOrUpdateButton;
  final void Function() deleteButton;
  final void Function() skipButton;
  final void Function() searchResetScreen;
  final void Function() fullReset;
  final void Function() flipImportant;
  final int Function(Type) getNewId;
  static const Color sepColor = Colors.black54;
  final int funnyNumber =
      Random(MyDateController.today.hashCode).nextInt(100) + 1;

  Drawer createDrawer(BuildContext context) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        DrawerHeader(
          padding: const EdgeInsets.all(0.0),
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Center(
              child: Column(children: [
            Text(
              formatDate(MyDateController.today, bigDateFormat),
              style: textStyle,
            ),
            Text(
                "${formatDate(MyDateController.today, [
                      'W:',
                      WW
                    ])} - N:$funnyNumber",
                style: textStyle)
          ])),
        ),
        Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: sepColor, width: 7))),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: _dumbJoke('Add Button'),
                    trailing: const Icon(Icons.add, color: Colors.black),
                    onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddingScreen(
                                    null, addOrUpdateButton, getNewId)))
                        .then((v) => Navigator.pop(context)),
                  ),
                  ListTile(
                      title: _dumbJoke('Update Button'),
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
                    title: _dumbJoke('Delete Button'),
                    trailing: const Icon(Icons.delete, color: Colors.black),
                    onTap: () {
                      deleteButton();
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                      title: _dumbJoke('Camera Add'),
                      trailing:
                          const Icon(Icons.camera_alt, color: Colors.black),
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PhotoScreen(
                                        addOrUpdateButton, getNewId)))
                            .then((v) => Navigator.pop(context));
                      }),
                ])),
        ListTile(
          title: _dumbJoke('Reset Display'),
          trailing: const Icon(Icons.restart_alt_rounded, color: Colors.black),
          onTap: () {
            searchResetScreen();
            Navigator.pop(context);
          },
        ),
        Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: sepColor, width: 11),
                    top: BorderSide(color: sepColor, width: 9))),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: _dumbJoke('Find Appointment'),
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
                ])),
        ListTile(
          title: _dumbJoke('Skip this time'),
          trailing: const Icon(Icons.next_plan_outlined, color: Colors.black),
          onTap: () {
            skipButton();
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: _dumbJoke('Flip Important'),
          trailing: const Icon(Icons.notifications, color: Colors.black),
          onTap: () {
            flipImportant();
            Navigator.pop(context);
          },
        ),
        Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: sepColor, width: 13))),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: _dumbJoke('Sync Online Data'),
                    trailing: const Icon(Icons.sync, color: Colors.black),
                    onTap: () {
                      syncAction!();
                    },
                  )
                ])),
      ],
    ));
  }

  Widget _dumbJoke(String s) {
    // for(int i = 1;i < 100;i++) {
    //   if (s.hashCode % i == 0)
    //     print(s);
    // }
    if (s.hashCode % funnyNumber == 0) {
      var calc =
          Random(MyDateController.today.hashCode).nextInt(dumberJoke.length);
      var usdCol = usedColors[calc % (usedColors.length - 1) + 1];
      return Row(children: [
        Text('$s  ', style: normalTextStyle),
        Container(
            decoration: BoxDecoration(
                color: usdCol,
                border: Border.all(
                  color: usdCol,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Text(dumberJoke[calc],
                style: const TextStyle(color: Colors.white, fontSize: 8)))
      ]);
    }
    return Text(s, style: normalTextStyle);
  }

  var dumberJoke = ['Alpha', 'Beta', 'Gamma', 'Delta', 'Delta', 'Zeta'];
}
