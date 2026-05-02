import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/adding_screen_controller.dart';
import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:flutter/material.dart';

import '../Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';

class AddingScreen extends StatefulWidget {
  final BasicButtonController? button;
  final ButtonNotifier _notifier;

  final bool _withNote;

  const AddingScreen(this.button, this._notifier, this._withNote, {super.key});

  @override
  State<AddingScreen> createState() => _AddingScreenState();
}

class _AddingScreenState extends State<AddingScreen> {
  late final AddingScreenController _screenController = AddingScreenController(
      widget.button?.button, widget._notifier, widget._withNote);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white24,
        appBar: AppBar(backgroundColor: Colors.green, title: const Text('Adding'), actions: <Widget>[
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
                    widget._notifier.delete(controller);
                    Navigator.pop(context, true);
                  })
              : const Text(''),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                BasicButtonController? controller =
                    _screenController.getButton();
                if (controller == null) return;
                controller.touched = true;
                widget._notifier.addOrUpdate(controller);
                Navigator.pop(context, false);
              }),
        ]),
        body: SingleChildScrollView(
            child: ListenableBuilder(
                listenable: _screenController.buttonType,
                builder: (BuildContext context, Widget? child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _screenController.createScreenWidgets(),
                  );
                })));
  }
}
