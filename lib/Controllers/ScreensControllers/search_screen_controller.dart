import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/end_based_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common_items.dart';
import '../my_date_controller.dart';
import 'common_day_display_screen_controller.dart';
import 'common_screen_controller.dart';

class SearchScreenController {
  late List<EndBasedController>? everything;

  List<Widget> Function()? toCallNext;

  final List<Widget> itemList = [];
  final void Function() setStateMethod;
  final void Function(EndBasedController) openEdit;
  final TextEditingController stringController =
      TextEditingController(text: '');
  final TextEditingController dateController = TextEditingController(text: '');
  final TextEditingController extraDatesController =
      TextEditingController(text: '');

  SearchScreenController(this.setStateMethod, this.openEdit) {
    loading.getEndBasedButtons().then((value) {
      everything = value;
      everything!.sort();
    });
  }

  static const TextStyle styleDays =
      TextStyle(fontSize: 20.0, height: 2.5, color: Colors.green);

  ///there are 4 things possible
  ///1 you have a date and nothing else. then we'll show the date
  ///2 you have text. then we'll show you the days with an item containing text like that
  ///3 you have a date and extra time. you will see multiple days with all items
  ///4 you have a date, extra time and text, you will see days but only items in those days with that text
  List<Widget> searchAll(int? daysLeftUntil, String text, int extraTime) {
    List<Widget> a = [];
    if (daysLeftUntil == null) {
      if (text == "") return [];
      var everythingFound = everything!
          .where((EndBasedController e) => _stringSearch(e, text))
          .toList();
      List<int> datesOfFoundItems = everythingFound
          .map((e) => e.dateController.daysLeftUntil())
          .toSet()
          .toList();
      for (int i = 0; i < datesOfFoundItems.length; i++) {
        var list = _searchDay(datesOfFoundItems[i],
            everything!.toList()..removeWhere((e) => _stringSearch(e, text)));
        for (int ii = 0; ii < everythingFound.length; ii++) {
          if (!everythingFound[ii]
              .isHappeningOnDayFromNow(datesOfFoundItems[i])) continue;
          list.insert(
              2,
              Container(
                  decoration: BoxDecoration(
                      color: Colors.pink[900],
                      border: Border.all(
                        width: 7,
                        color: const Color.fromARGB(255, 0x88, 0xe, 0x4f),
                      ),
                      // Make rounded corners
                      borderRadius: BorderRadius.circular(30)),
                  child: buttonCreator(everythingFound[ii])));
          list.insert(3, smallBlankSplit);
        }
        a.addAll(list);
      }
    } else {
      for (int i = 0; i < extraTime; i++) {
        var toDisplayDuringDay = everything!;
        if (text != "") {
          toDisplayDuringDay =
              toDisplayDuringDay.where((e) => _stringSearch(e, text)).toList();
        }
        a.addAll(_searchDay(daysLeftUntil + i, toDisplayDuringDay));
      }
    }
    return a;
  }

  List<Widget> _searchDay(int time, List<EndBasedController> list) =>
      (createADay(MyDateController.today, list, time, setStateMethod,
          (c, o) => buttonCreator(c), false));

  String _getCorrectString(MyDateController? date, [int extraData = 0]) {
    StringBuffer buf = StringBuffer();
    if (stringController.text != '') {
      buf.write(stringController.text);
    }
    if (date != null) {
      if (stringController.text != '') {
        buf.write('\n');
      }
      buf.write(date.fullDisplayWithCal());
      if (extraData > 0) {
        buf.write('\n till \n');
        buf.write(date.addOrRemoveDays(extraData).fullDisplayWithCal());
      }
    }
    return buf.toString();
  }

  bool _stringSearch(EndBasedController<BasicButton> e, String text) {
    text = text.toLowerCase();
    return e.job.toLowerCase().contains(text) ||
        e.toDos.any((element) => element.toLowerCase().contains(text));
  }

  Widget dateFinder() {
    return TextField(
        controller: dateController,
        onSubmitted: (s) {
          onConfirmed();
        },
        decoration: const InputDecoration(
            hintText: 'date to look up',
            border: OutlineInputBorder(gapPadding: 2)));
  }

  Widget textFinder() {
    return TextField(
        controller: stringController,
        onSubmitted: (s) {
          onConfirmed();
        },
        decoration: const InputDecoration(
            hintText: 'text finder',
            border: OutlineInputBorder(gapPadding: 2)));
  }

  Widget extraDatesFinder() {
    return TextField(
        controller: extraDatesController,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9]?[mM]?'))
        ],
        onSubmitted: (s) {
          if (dateController.text == "") {
            return;
          }
          onConfirmed();
        },
        decoration: const InputDecoration(
            hintText: '+ numb or m',
            border: OutlineInputBorder(gapPadding: 3)));
  }

  void onConfirmed() {
    stringController.text = stringController.text.trim();
    var date = MyDateController.translate(dateController.text);
    int? awns = date?.daysLeftUntil();
    var extraTime = awns == null
        ? 0
        : extraDatesController.text.toLowerCase().contains('m')
            ? MyDateController.monthCalc(awns)
            : int.tryParse(extraDatesController.text) ?? 1;
    timerCheck(() => searchAll(awns, stringController.text, extraTime),
        _getCorrectString(date, extraTime));
  }

  void timerCheck(List<Widget> Function() toCall, String s) {
    toCallNext = toCall;
    fillingFunction(setStateMethod, s);
  }

  Future<void> fillingFunction(void Function() setStateMethod, String s) async {
    var calcList = toCallNext!();
    stringController.text =
        dateController.text = extraDatesController.text = '';
    itemList.clear();
    itemList.add(_createTextButton(s));
    for (var itemToAdd in calcList) {
      itemList.add(itemToAdd);
    }
    setStateMethod();
  }

  Widget _createTextButton(String s) =>
      blagendaUniformButton(false, usedColors.first, s, () {
        itemList.clear();
        setStateMethod();
      });

  Widget buttonCreator(EndBasedController it) => blagendaUniformButton(
      false, it.color, it.gettingTheStringSelected(), () => openEdit(it));

  List<Widget> getScreenWidgets() {
    List<Widget> widgets = [
      Row(children: [
        Expanded(flex: 3, child: dateFinder()),
        Expanded(flex: 2, child: extraDatesFinder())
      ]),
      textFinder(),
      const Text(' ')
    ];
    widgets.addAll(itemList);
    return widgets;
  }
}
