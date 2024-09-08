import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/entity_controller.dart';
import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:blagenda_flutter_simple/Loading/entity_notifier.dart';
import 'package:flutter/material.dart';

import '../Controllers/ScreensControllers/adding_entity_screen_controller.dart';
import '../Controllers/blagenda_uniform_button.dart';
import '../common_items.dart';

class MiniAddEntityScreen {
  MiniAddEntityScreen(this._entity, this._openButtonSearch, this._openButtonEdit,
      this._buttonNotifier, this._entityNotifier);

  final EntityController? _entity;

  final Future<BasicButtonController?> Function() _openButtonSearch;
  final void Function(dynamic) _openButtonEdit;

  final ButtonNotifier _buttonNotifier;
  final EntityNotifier _entityNotifier;

  late final AddingEntityScreenController _screenController =
      AddingEntityScreenController(_entity, _entityNotifier, _buttonNotifier,
          _openButtonSearch, _openButtonEdit);

  Widget makeAddingEntityScreen() {
    return ListenableBuilder(
        listenable: _screenController,
        builder: (context, child) => SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                smallBlankSplit,
                ..._screenController.createScreenWidgets(),
                BlagendaUniformButton(usedColors.first, () => _entity == null ? 'Add' : 'Update', () {
                  EntityController? controller = _screenController.getEntity();
                  if (controller == null) {
                    if (_entity != null) _entityNotifier.delete(_entity);
                    return;
                  }
                  _entityNotifier.addOrUpdate(controller);
                })
              ],
            )));
  }

  EntityController? getEntity() =>  _screenController.getEntity();
}
