import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/adding_screen_controller.dart';
import 'package:flutter/material.dart';

import '../Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';

class AddingScreen extends StatefulWidget {
  final BasicButtonController? button;
  final Function(dynamic) addingFunction;
  final int Function(Type) getNewId;

  final List<EndBasedController> Function() getEndBasedButtons;

  final bool _withNote;

  const AddingScreen(this.button, this.addingFunction, this.getNewId,
      this.getEndBasedButtons, this._withNote,
      {super.key});

  @override
  State<AddingScreen> createState() => _AddingScreenState();
}

class _AddingScreenState extends State<AddingScreen> {
  late final AddingScreenController _screenController = AddingScreenController(
      widget.button?.button,
      widget.getNewId,
      _setStateMethod,
      widget.getEndBasedButtons,
      widget._withNote);

  late final List<Widget> _itemList = [];

  @override
  Widget build(BuildContext context) {
    _itemList.clear();
    _itemList.addAll(_screenController.createScreenWidgets());

    return Scaffold(
        backgroundColor: Colors.white24,
        appBar: AppBar(title: const Text('Adding'), actions: <Widget>[
          widget.button != null
              ? IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    BasicButtonController? controller = widget.button;
                    if (controller == null) {
                      //should never happen
                      Navigator.pop(context, true);
                      return;
                    }
                    controller.touched = true;
                    widget.addingFunction(controller);
                    Navigator.pop(context, true);
                  })
              : const Text(''),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                BasicButtonController? controller = _screenController.getButton();
                if (controller == null) return;
                controller.touched = false;
                widget.addingFunction(controller);
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
