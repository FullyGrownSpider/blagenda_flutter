import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/adding_screen_controller.dart';
import 'package:flutter/material.dart';

class AddingScreen extends StatefulWidget {
  final BasicButtonController? button;
  final Function(BasicButtonController) addingFunction;
  final int Function(Type) getNewId;

  const AddingScreen(this.button, this.addingFunction, this.getNewId,
      {Key? key})
      : super(key: key);

  @override
  State<AddingScreen> createState() => _AddingScreenState();
}

class _AddingScreenState extends State<AddingScreen> {
  late final AddingScreenController _screenController = AddingScreenController(
      widget.button?.button, widget.getNewId, _setStateMethod);

  late final List<Widget> _itemList = [];

  @override
  Widget build(BuildContext context) {
    _itemList.clear();
    _itemList.addAll(_screenController.createScreenWidgets());

    return Scaffold(
        backgroundColor: Colors.white24,
        appBar: AppBar(title: const Text('Adding'), actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                BasicButtonController? controller =
                    _screenController.getButton!();
                if (controller == null) return;
                widget.addingFunction(controller);
                Navigator.pop(context);
              })
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
