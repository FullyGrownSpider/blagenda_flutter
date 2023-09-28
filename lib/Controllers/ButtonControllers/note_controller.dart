import 'package:flutter/material.dart';

import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';

import '../ScreensControllers/common_screen_controller.dart';
import 'basic_button_controller.dart';

class NoteController extends BasicButtonController<BasicButton>
    implements Comparable<NoteController> {
  NoteController(BasicButton button) : super(button);

  @override
  int compareTo(NoteController other) {
    for (int i = 0; i < usedColors.length; i++) {
      if (usedColors[i].red == color.red &&
          usedColors[i].green == color.green &&
          usedColors[i].blue == color.blue) {
        if (usedColors[i].red == other.color.red &&
            usedColors[i].green == other.color.green &&
            usedColors[i].blue == other.color.blue) {
          return 0;
        }
        return -1;
      }
      if (usedColors[i].red == other.color.red &&
          usedColors[i].green == other.color.green &&
          usedColors[i].blue == other.color.blue) {
        return 1;
      }
    }
    return 0;
  }

  static List<NoteController> chosenSort(
      List<NoteController> toSort, int maxSize) {
    Map<Color, List<NoteController>> groupedBalls = {};

    for (var ball in toSort) {
      groupedBalls.putIfAbsent(ball.color, () => []).add(ball);
    }
    toSort.clear();
    List<List<NoteController>> groupedAndSorted = groupedBalls.values.toList();
    groupedAndSorted.sort((la, lb) => la
        .where((e) => e.theStringLongestLength > (maxSize / 2))
        .length
        .compareTo(
            lb.where((e) => e.theStringLongestLength > (maxSize / 2)).length));
    for (int i = 0; i < groupedAndSorted.length; i++) {
      if (i % 2 == 0) {
        groupedAndSorted[i].sort((a, b) => _noteSmallSort(b, a));
      } else {
        groupedAndSorted[i].sort((a, b) => _noteSmallSort(a, b));
      }
      toSort.addAll(groupedAndSorted[i]);
    }
    return toSort;
  }

  static _noteSmallSort(NoteController a, NoteController b) {
    return a.theStringLongestLength.compareTo(b.theStringLongestLength);
  }
}
