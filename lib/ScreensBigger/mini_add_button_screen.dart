import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/adding_screen_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/blagenda_uniform_button.dart';
import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter/material.dart';

import '../Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';

class MiniAddButtonScreen {
  MiniAddButtonScreen(this.button, this._notifier, this._withNote);

  final BasicButtonController? button;
  final ButtonNotifier _notifier;

  final bool _withNote;

  late final AddingScreenController _screenController =
      AddingScreenController(button?.button, _notifier, _withNote);

  Widget makeAddingButtonScreen(Function() switchOnAdd) {
    return SingleChildScrollView(
        child: ListenableBuilder(
            listenable: _screenController.buttonType,
            builder: (BuildContext context, Widget? child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ..._screenController.createScreenWidgets(),
                  BlagendaUniformButton(usedColors.first, () => 'Add', () {
                    BasicButtonController? controller =
                        _screenController.getButton();
                    if (controller == null) return;
                    controller.touched = true;
                    _notifier.addOrUpdate(controller);
                    switchOnAdd();
                  })
                ],
              );
            }));
  }
}
