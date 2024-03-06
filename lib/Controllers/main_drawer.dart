import 'dart:math';

import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Screens/adding_screen.dart';
import 'package:blagenda_flutter_simple/Screens/search_screen.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../Screens/entity_adding_screen.dart';
import '../common_items.dart';
import 'ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'blagenda_uniform_button.dart';

class MainDrawer {
  static const TextStyle textStyle = TextStyle(
      fontSize: 35.0,
      height: 1.7,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      decoration: TextDecoration.underline,
      color: Colors.grey);

  static const ListTile listSep = ListTile(
      title:
          Text('--------------------------------------------', style: normalTextStyle));

  MainDrawer(
      this._getSelectedButton,
      this._addOrUpdateItem,
      this._deleteButton,
      this._skipButton,
      this._getNewId,
      this._getNewEntityID,
      this._fullReset,
      this._getEndbasedButtons,
      this._getEntitiesButtons,
      this._getButtonCopy,
      this._getEntityCopy);

  final Future<EndBasedController> Function(EndBasedController) _getButtonCopy;
  final Future<EntityController> Function(EntityController) _getEntityCopy;
  final BasicButtonController? Function() _getSelectedButton;
  final void Function(dynamic) _addOrUpdateItem;
  final void Function() _deleteButton;
  final void Function() _skipButton;
  final void Function() _fullReset;
  final List<EndBasedController> Function() _getEndbasedButtons;
  final List<EntityController> Function() _getEntitiesButtons;
  final int Function(Type) _getNewId;
  final int Function() _getNewEntityID;
  static const Color sepColor = Colors.black54;
  final int funnyNumber = Random(MyDateController.today.hashCode).nextInt(100) + 1;

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
              formatDate(MyDateController.today, [D, ', ', M, ' ', d]),
              style: textStyle,
            ),
            Text('${formatDate(MyDateController.today, ['W:', WW])} - N:$funnyNumber',
                style: textStyle)
          ])),
        ),
        Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: sepColor, width: 7))),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ListTile(
                  title: _dumbJoke('Add Button'),
                  trailing: const Icon(Icons.add, color: Colors.black),
                  onTap: () => _openEdit(context, null, true, _addOrUpdateItem)
                      .then((v) => Navigator.pop(context))),
              ListTile(
                  title: _dumbJoke('Update Button'),
                  trailing: const Icon(Icons.edit, color: Colors.black),
                  onTap: () {
                    var button = _getSelectedButton();
                    if (button != null) {
                      _openEdit(context, button, true, _addOrUpdateItem)
                          .then((v) => Navigator.pop(context));
                    }
                  }),
              ListTile(
                title: _dumbJoke('Delete Button'),
                trailing: const Icon(Icons.delete, color: Colors.black),
                onTap: () {
                  _deleteButton();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: _dumbJoke('Skip this time'),
                trailing: const Icon(Icons.next_plan_outlined, color: Colors.black),
                onTap: () {
                  _skipButton();
                  Navigator.pop(context);
                },
              ),
            ])),
        ListTile(
            title: _dumbJoke('Find Appointment'),
            trailing: const Icon(Icons.search, color: Colors.black),
            onTap: () => _openButtonSearch(
                    context, (it) => _openEdit(context, it, false, _addOrUpdateItem))
                .then((v) => Navigator.pop(context))),
        ListTile(
          title: _dumbJoke('Add Entity'),
          trailing: const Icon(Icons.add_circle_outline, color: Colors.black),
          onTap: () => _openEntityEdit(context, null).then((v) => Navigator.pop(context)),
        ),
        ListTile(
            title: _dumbJoke('Entities Search'),
            trailing: const Icon(Icons.manage_search, color: Colors.black),
            onTap: () =>
                _openEntitySearch(-1, context, (it) => _openEntityEdit(context, it))
                    .then((v) => Navigator.pop(context))),
        Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: sepColor, width: 9))),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ListTile(
                title: _dumbJoke('Reset Display'),
                trailing: const Icon(Icons.restart_alt_rounded, color: Colors.black),
                onTap: () {
                  _fullReset();
                  Navigator.pop(context);
                },
              ),
            ])),
        ListTile(
            title: _dumbJoke('Sync Online Data'),
            trailing: const Icon(Icons.sync, color: Colors.black),
            onTap: () => syncAction!())
      ],
    ));
  }

  Future<dynamic> _openEntitySearch(int numb, BuildContext context,
      [Future<dynamic> Function(dynamic)? addOrUpdateItem, bool closeOnAction = false]) {
    addOrUpdateItem ??= (item) async {
      _addOrUpdateItem(item);
    };
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchScreen(
                addOrUpdateItem!,
                _getNewId,
                _getEntitiesButtons().where((e) => e.id != numb).toList(),
                closeOnAction,
                _getEntityCopy)));
  }

  Future<dynamic> _openButtonSearch(BuildContext context,
      [Future<dynamic> Function(dynamic)? addOrUpdateItem, bool closeOnAction = false]) {
    addOrUpdateItem ??= (item) async {
      _addOrUpdateItem(item);
    };
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchScreen(addOrUpdateItem!, _getNewId,
                _getEndbasedButtons(), closeOnAction, _getButtonCopy)));
  }

  Widget _dumbJoke(String s) {
    if (s.hashCode % funnyNumber == 0) {
      var calc = Random(MyDateController.today.hashCode).nextInt(dumberJoke.length);
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

  Future<dynamic> _openEntityEdit(BuildContext context, EntityController? c) =>
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddingEntityScreen(
                  c,
                  _addOrUpdateItem,
                  _getNewEntityID,
                  _getEndbasedButtons,
                  _getEntitiesButtons,
                  (toUse) => _openButtonSearch(context, toUse, true),
                  (toGet) => _openEdit(context, null, false, (t) {
                        toGet(t);
                        return _addOrUpdateItem(t);
                      }))));

  Future<dynamic> _openEdit(BuildContext context, BasicButtonController? it,
          bool withNote, dynamic Function(dynamic) doWith) =>
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AddingScreen(it, doWith, _getNewId, _getEndbasedButtons, withNote)));
}
