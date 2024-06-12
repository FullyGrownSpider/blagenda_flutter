import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:flutter/material.dart';

import '../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import 'ObservationScreen/observation_screen_buttons.dart';
import 'ObservationScreen/observation_screen_options.dart';

class ObservationScreenController {
  final ObservationScreenOptions observationScreenOptions = ObservationScreenOptions();
  @visibleForTesting
  late final ObservationScreenButtons observationScreenButtons;
  @visibleForTesting
  final ButtonNotifier _notifier;

  ///needs to load first use doneLoading to check if done
  ObservationScreenController(Future Function(BasicButtonController) openEntityScreen,
      Future Function(BasicButtonController) openButtonEdit, this._notifier) {
    observationScreenButtons = ObservationScreenButtons(openEntityScreen, openButtonEdit);
    _notifier.addListener(() {
      if (_notifier.hardPoint) deselect();
    });
  }

  void deselect() => observationScreenButtons.resetCounters();

  List<Widget> getWidgetListNote() =>
      observationScreenButtons.getWidgetListNote(observationScreenOptions,
          _notifier.getData().whereType<NoteController>().toList());

  List<Widget> getWidgetListEndBased() =>
      observationScreenButtons.getWidgetListEndBased(
          ObservationScreenOptions.daysToShow, _notifier.getData(), observationScreenOptions);

  void resetSearch() =>
      observationScreenOptions.resetSearch(_resetCounters);

  void _resetCounters() => observationScreenButtons.resetCounters();

  BasicButtonController? getSelectedButton() {
    if (observationScreenButtons.idSelected == -1) return null;
    List correctList = _notifier.getData()
        .where((e) => e.runtimeType == observationScreenButtons.typeOfSelected!)
        .toList();
    return correctList
        .firstWhere((e) => observationScreenButtons.idSelected == e.button.id);
  }

  bool justAddedCheck() => observationScreenButtons.justAddedCheck();

  int getNewId(Type t) => _notifier.getNewId(t);

  List<Widget> getOptionButtons() =>
      observationScreenOptions.getOptionButtons(_resetCounters);
}
