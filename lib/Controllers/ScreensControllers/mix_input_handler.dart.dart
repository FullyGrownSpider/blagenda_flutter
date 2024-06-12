import 'package:blagenda_flutter_simple/Controllers/color_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common_items.dart';
import '../blagenda_uniform_button.dart';
import '../my_date_controller.dart';
import 'mix_button_creator.dart';

const TextStyle inputTextStyle = TextStyle(
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.normal,
    decoration: TextDecoration.none,
    color: Colors.white);

mixin InputHandler on ButtonCreator {
  InputObject<String> itemForStringAutoComplete(String hint,
      String Function() get, void Function(String) set, List<String> autoComp) {
    var initValue = TextEditingValue(text: get());
    var autoComplete = notQuiteFull(Autocomplete(
        initialValue: initValue,
        optionsBuilder: (TextEditingValue textEditingValue) async {
          if (textEditingValue.text.length < 3) {
            return const Iterable<String>.empty();
          }
          var list = autoComp.where((String option) => option
              .toLowerCase()
              .startsWith(textEditingValue.text.toLowerCase()));
          set(textEditingValue.text);
          return list;
        },
        onSelected: set,
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return _defaultTextField(textEditingController, set, hint,
              focusNode: focusNode);
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options) {
          return Align(
              alignment: Alignment.topLeft,
              child: Material(
                  elevation: 4.0,
                  child: SizedBox(
                      height: 200.0,
                      child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return GestureDetector(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: ListTile(
                                  title: Text(option),
                                ));
                          }))));
        }));
    return InputObject<String>(autoComplete, get, set);
  }

  TextField _defaultTextField(
    TextEditingController stringController,
    void Function(String) set,
    String hint, {
    int maxLines = 1,
    keyboardType,
    FocusNode? focusNode,
  }) {
    return TextField(
        keyboardType: keyboardType,
        style: inputTextStyle,
        controller: stringController,
        onChanged: set,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint),
        focusNode: focusNode);
  }

  InputObject<String> itemForString(
      String hint, String Function() get, void Function(String) set) {
    TextEditingController stringController = TextEditingController(text: get());
    Widget displayWidget =
        notQuiteFull(_defaultTextField(stringController, set, hint));
    set = (s) {
      set(s);
      stringController.text = s;
    };
    return InputObject<String>(displayWidget, get, set);
  }

  InputObject<MyDateController?> itemForMyDate(String hint,
      MyDateController? Function() get, void Function(MyDateController?) set) {
    TextEditingController stringController =
        TextEditingController(text: _dateDisplay(get()));
    var displayWidget = notQuiteFull(_defaultTextField(
        stringController, (s) => set(MyDateController.translate(s)), hint));
    return InputObject<MyDateController?>(displayWidget, get, set);
  }

  String _dateDisplay(MyDateController? controller) {
    if (controller == null) return '';
    var toStore = controller.daysLeftUntil();
    if (toStore < 14) {
      return toStore.toString();
    } else if (toStore < 30) {
      StringBuffer weekdayString =
          StringBuffer(MyDateController.daysEn[controller.weekday - 1]);
      int days = controller.difference(MyDateController.today).inDays - 7;
      for (int i = 0; i < days; i += 7) {
        weekdayString.write('+');
      }
      return weekdayString.toString();
    } else {
      return controller
          .inputDisplayString(MyDateController.nowDate.year != controller.year);
    }
  }

  InputObject<bool> itemForBoolean(
      String hint, bool Function() get, void Function(bool) set) {
    final myBool = ValueNotifier(get());
    return InputObject<bool>(
        BlagendaUniformButton(
            usedColors.first, () => '${get() ? '⬤' : '◯'} - $hint', () {
          var newBool = !get();
          set(newBool);
          myBool.value = newBool;
        },isSelected: myBool),
        get,
        set);
  }

  InputObject<String> itemForStringList(
      String hint, String Function() get, void Function(String) set) {
    var stringController = TextEditingController(text: get());
    Widget displayWidget = notQuiteFull(_defaultTextField(
        stringController, set, hint,
        maxLines: 5, keyboardType: TextInputType.multiline));
    return InputObject<String>(displayWidget, get, (s) => '${s.trim()}\n');
  }

  InputObject<int> itemForInt(
      String hint, int Function() get, void Function(int) set) {
    var stringController = TextEditingController(text: get().toString());
    var displayWidget = notQuiteFull(_defaultTextField(stringController, (s) {
      var value = int.tryParse(s);
      if (value == null) {
        set(0);
      } else {
        set(value);
      }
    }, hint, keyboardType: TextInputType.number));
    return InputObject<int>(displayWidget, get, set);
  }

  InputObject<int?> itemForIntFromList(List<String> listToShow, String hint,
      int? Function() get, void Function(int?) set) {
    return InputObject<int?>(
        _createDropDown(listToShow, hint, () => get(), (s) => set(s)),
        get,
        set);
  }

  Widget _createDropDown(List<String> listToShow, String hint,
      int? Function() get, void Function(int) set) {
    int? value = get();
    var text = Text(
        value == null ? hint : listToShow[(value - 1) % listToShow.length]);
    return notQuiteFull(DropdownButton<String>(
        hint: text,
        items: listToShow.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (s) => set(listToShow.indexOf(s ?? '') + 1)));
  }

  InputObject<Color> itemForColor(
      Color Function() get, void Function(Color) set) {
    return InputObject<Color>(_widgetForColor(get, set), get, set);
  }

  Widget _widgetForColor(Color Function() get, void Function(Color) set) {
    ValueNotifier<int> colorValue = ValueNotifier(usedColors.indexOf(get()));
    return ColorButtons(colorValue, (_) {
      set(usedColors[colorValue.value]);
    });
  }

  InputObject<dynamic> itemForReferenceAbleList(
      dynamic Function() get,
      void Function(dynamic) set,
      void Function() onThingClick,
      String Function(dynamic) getNickname) {
    var but = BlagendaUniformButton(
        usedColors.first,
        () => get() == null ? "???" : getNickname(get()),
        onThingClick);
    return InputObject<dynamic>(but, get, set);
  }
}

mixin SearchField {
  InputObject<DateRange> dateFinder(void Function() onConfirmed,
      DateRange Function() get, void Function(DateRange) set) {
    TextEditingController dateController = TextEditingController(),
        rangeController = TextEditingController();
    return InputObject(
        notQuiteFull(Row(children: [
          Expanded(flex: 3, child: _dateFinder(onConfirmed, dateController)),
          Expanded(
              flex: 2, child: _extraDatesFinder(onConfirmed, rangeController))
        ])),
        get, (s) {
      var dateBefore = MyDateController.translate(dateController.text);
      if (dateBefore == null && rangeController.text.isEmpty) {
        set(const DateRange(0, -1));
        return;
      }
      var date = dateBefore ?? MyDateController.today;
      var dateRange = DateRange(date.daysLeftUntil(),
          _rangeCalculator(rangeController.text, date) ?? 0);
      set(dateRange);
    });
  }

  InputObject<String> stringFinder(void Function() onConfirmed) {
    var textController = TextEditingController();
    return InputObject(notQuiteFull(_textFinder(textController, onConfirmed)),
        () => textController.text.toLowerCase(), (s) {
      textController.text = s;
    });
  }

  InputObject<List<String>> tagFinder(void Function() onConfirmed) {
    TextEditingController nameController = TextEditingController(),
        dataController = TextEditingController();
    return InputObject(
        Row(children: [
          const Spacer(),
          Expanded(
              flex: 7,
              child: _textFinder(nameController, onConfirmed, 'Tag name', 3)),
          Expanded(
              flex: 7,
              child: _textFinder(dataController, onConfirmed, 'Tag data', 3)),
          const Spacer()
        ]), () {
      return [
        nameController.text.toLowerCase().trim(),
        dataController.text.toLowerCase().trim()
      ];
    }, (list) {
      if (list.isEmpty) {
        nameController.text = dataController.text = '';
      } else {
        nameController.text = list.first;
        dataController.text = list.last;
      }
    });
  }

  Widget _dateFinder(
      Function() onConfirmed, TextEditingController dateController) {
    return TextField(
        style: inputTextStyle,
        controller: dateController,
        onSubmitted: (s) {
          onConfirmed();
        },
        decoration: const InputDecoration(
            hintText: 'date to look up',
            border: OutlineInputBorder(gapPadding: 2)));
  }

  Widget _extraDatesFinder(
      Function() onConfirmed, TextEditingController rangeController) {
    return TextField(
        style: inputTextStyle,
        controller: rangeController,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9]?[mw+]?'))
        ],
        onSubmitted: (s) {
          onConfirmed();
        },
        decoration: const InputDecoration(
            hintText: '+ numb or m/w',
            border: OutlineInputBorder(gapPadding: 3)));
  }

  Widget _textFinder(
      TextEditingController stringController, Function() onConfirmed,
      [String hint = 'text finder', int maxLines = 1]) {
    return TextField(
        style: inputTextStyle,
        controller: stringController,
        maxLines: maxLines,
        onSubmitted: (s) {
          onConfirmed();
        },
        decoration: InputDecoration(
            hintText: hint, border: const OutlineInputBorder(gapPadding: 2)));
  }

  int? _rangeCalculator(String text, MyDateController date) {
    var total = int.tryParse(
        text.replaceAll('m', '').replaceAll('w', '').replaceAll('+', ''));
    if (total == null) return null;
    var months = text.allMatches('m').length;
    if (months != 0) {
      months = MyDateController(date.year, date.month + months, date.day)
          .daysLeftUntil();
    }
    return total +
        months +
        (text.allMatches('w').length + text.allMatches('+').length) * 7;
  }
}

Row notQuiteFull(Widget widget) => Row(children: [
      const Spacer(flex: 1),
      Expanded(flex: 14, child: widget),
      const Spacer()
    ]);

class InputObject<t> {
  InputObject(this.displayWidget, this.getValue, this.setValue);

  Widget displayWidget;
  t Function() getValue;
  void Function(t) setValue;
}

final class DateRange {
  final int myDateFromNow;
  final int range;

  const DateRange(this.myDateFromNow, this.range);
}
