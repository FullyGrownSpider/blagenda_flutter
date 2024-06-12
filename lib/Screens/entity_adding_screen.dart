import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:blagenda_flutter_simple/Loading/entity_notifier.dart';
import 'package:flutter/material.dart';

import '../Controllers/ScreensControllers/adding_entity_screen_controller.dart';

class AddingEntityScreen extends StatefulWidget {
  final EntityController? entity;

  final Future<dynamic> Function()
      _openButtonSearch;
  final Future<dynamic> Function(dynamic) _openButtonEdit;

  final ButtonNotifier _buttonNotifier;

  final EntityNotifier _entityNotifier;

  const AddingEntityScreen(this.entity, this._buttonNotifier,
      this._entityNotifier, this._openButtonSearch, this._openButtonEdit,
      {super.key});

  @override
  State<AddingEntityScreen> createState() => _AddingEntityScreenState();
}

class _AddingEntityScreenState extends State<AddingEntityScreen> {
  late final AddingEntityScreenController _screenController =
      AddingEntityScreenController(widget.entity, widget._entityNotifier, widget._buttonNotifier,
          widget._openButtonSearch, widget._openButtonEdit);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white24,
        appBar: AppBar(title: const Text('Adding'), actions: <Widget>[
          widget.entity != null
              ? IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    EntityController? controller = widget.entity;
                    if (controller == null) {
                      Navigator.pop(context, true);
                      return; //should never happen
                    }
                    widget._entityNotifier.addOrUpdate(controller..tags.clear());
                    Navigator.pop(context, true);
                  })
              : const Text(''),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                EntityController? controller = _screenController.getEntity();
                if (controller == null) return;
                widget._entityNotifier.addOrUpdate(controller);
                Navigator.pop(context, false);
              }),
        ]),
        body: ListenableBuilder(
            listenable: _screenController.screenWidgets,
            builder: (context, child) => SingleChildScrollView(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _screenController.screenWidgets.value,
                ))));
  }
}
