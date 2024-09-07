import 'package:flutter/material.dart';

import '../Loading/button_notifier.dart';
import '../common_items.dart';

final List<Widget> _centerChildren = [];
final BorderSide border = BorderSide(color: usedColors.first, width: 2);

Widget generateDayView(
    List<Widget> Function() getWidgetListEndBased,
    List<Widget> Function() getWidgetListNote,
    ButtonNotifier buttonNotifier,
    ChangeNotifier Function() getOptionsNotifier) {
  return ListenableBuilder(
      listenable: buttonNotifier,
      builder: (BuildContext context, Widget? child) => ListenableBuilder(
          listenable: getOptionsNotifier(),
          builder: (BuildContext context, Widget? child) {
            _resetScreen(getWidgetListEndBased, getWidgetListNote);
            return LayoutBuilder(
                builder: (context, constraint) => SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraint.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            children: _centerChildren,
                          ),
                        ))));
          }));
}

void _resetScreen(List<Widget> Function() getWidgetListEndBased,
    List<Widget> Function() getWidgetListNote) {
  _centerChildren.clear();
  _centerChildren.add(_containWidgetsPretty(getWidgetListEndBased()));
  var notes = getWidgetListNote();
  if (notes.isNotEmpty) _centerChildren.add(_containWidgetsPretty(notes));
}

Widget _containWidgetsPretty(List<Widget> list) {
  return Container(
      padding: const EdgeInsets.only(bottom: 5),
      width: double.infinity,
      decoration: BoxDecoration(border: Border(bottom: border)),
      child: Container(
          padding: const EdgeInsets.only(bottom: 3),
          width: double.infinity,
          decoration: BoxDecoration(border: Border(bottom: border)),
          child: Container(
              padding: const EdgeInsets.only(bottom: 1),
              width: double.infinity,
              decoration: BoxDecoration(border: Border(bottom: border)),
              child: Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border(bottom: border)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: list)))));
}
