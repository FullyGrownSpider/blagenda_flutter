import 'package:flutter/material.dart';

import '../../common_items.dart';
import 'ScreensControllers/mix_button_creator.dart';
import 'blagenda_uniform_button.dart';

///will automatically change selected based on which was clicked last
///in "selected" field
class ColorButtons extends StatefulWidget {
  static const String smollButStartText = '••';

  const ColorButtons(this.selected, this.pressed, {super.key});

  final void Function(bool) pressed;
  final ValueNotifier<int> selected;

  @override
  State<StatefulWidget> createState() => _ColorButtons();
}

class _ColorButtons extends State<ColorButtons> with ButtonCreator {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.selected,
        builder: (context, selected, child) => Column(
            children: addAsRow(
                (i) => _createColorButton(i, widget.selected.value),
                usedColors.length)));
  }

  Widget _createColorButton(int index, int beforeIndex) {
    final ValueNotifier<bool> myBool = ValueNotifier(beforeIndex == index);
    return BlagendaUniformButton(usedColors[index], () => '', () {
      if (widget.selected.value == index) {
        widget.pressed(true);
        myBool.value = widget.selected.value == index;
        return;
      }
      widget.selected.value = index;
      myBool.value = true;
      widget.pressed(false);
    }, isSelected: myBool);
  }
}
