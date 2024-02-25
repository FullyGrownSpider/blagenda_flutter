import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:flutter/material.dart';

import '../Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../Controllers/ScreensControllers/adding_entity_screen_controller.dart';

class AddingEntityScreen extends StatefulWidget {
  final EntityController? entity;
  final Function(EntityController) _addingFunction;
  final int Function() _getNewId;

  final List<EntityController> Function() _getEntities;
  final List<BasicButtonController> Function() _getButtons;

  final Future<dynamic> Function(Future<dynamic> Function(dynamic)) _openSearchButton;
  final Future<dynamic> Function(dynamic) _openButtonEdit;

  const AddingEntityScreen(this.entity, this._addingFunction, this._getNewId,
      this._getButtons, this._getEntities, this._openSearchButton, this._openButtonEdit,
      {super.key});

  @override
  State<AddingEntityScreen> createState() => _AddingEntityScreenState();
}

class _AddingEntityScreenState extends State<AddingEntityScreen> {
  late final AddingEntityScreenController _screenController =
      AddingEntityScreenController(
          widget.entity,
          widget._getNewId,
          _setStateMethod,
          widget._getEntities(),
          widget._getButtons(),
          widget._openSearchButton,
          widget._openButtonEdit);

  late final List<Widget> _itemList = [];

  @override
  Widget build(BuildContext context) {
    _itemList.clear();
    _itemList.addAll(_screenController.createScreenWidgets());

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
                    widget._addingFunction(controller..tags.clear());
                    Navigator.pop(context, true);
                  })
              : const Text(''),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                EntityController? controller = _screenController.getEntity!();
                if (controller == null) return;
                widget._addingFunction(controller);
                Navigator.pop(context, false);
              }),
        ]),
        body: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _itemList,
        )));
  }

  void _setStateMethod() {
    if (!mounted) return;
    setState(() {});
  }
}
