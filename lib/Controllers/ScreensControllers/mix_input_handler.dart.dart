import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common_items.dart';
import '../my_date_controller.dart';
import 'mix_button_creator.dart';

const TextStyle inputTextStyle = TextStyle(
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.normal,
    decoration: TextDecoration.none,
    color: Colors.white);

mixin inputHandler on buttonCreator {
  InputObject<String> itemForStringAutoComplete(
      String preObject,
      String hint,
      Map<String, dynamic> storedValues,
      void Function() doWhenPossible,
      String index,
      List<String> autoComp,
      void Function() setState) {
    var initValue = TextEditingValue(text: preObject);
    var autoComplete = notQuiteFull(Autocomplete(
        initialValue: initValue,
        optionsBuilder: (TextEditingValue textEditingValue) async {
          if (textEditingValue.text.length < 3) {
            return const Iterable<String>.empty();
          }
          var list = autoComp.where((String option) =>
              option.toLowerCase().startsWith(textEditingValue.text.toLowerCase()));
          storedValues[index] = textEditingValue.text;

          return list;
        },
        onSelected: (String selection) {
          storedValues[index] = selection;
        },
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return _defaultTextField(
              textEditingController, storedValues, index, doWhenPossible, hint,
              onChanged: (_) {
            setState();
          }, focusNode: focusNode);
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
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
    return InputObject<String>(autoComplete, () {
      return storedValues[index];
    }, index, (_) {});
  }

  TextField _defaultTextField(
    TextEditingController stringController,
    Map<String, dynamic> storedValues,
    String index,
    void Function() doWhenPossible,
    String hint, {
    void Function(String)? onChanged,
    int maxLines = 1,
    keyboardType,
    FocusNode? focusNode,
  }) {
    onChanged ??= (s) {
      storedValues[index] = s;
    };
    return TextField(
        keyboardType: keyboardType,
        style: inputTextStyle,
        controller: stringController,
        onChanged: onChanged,
        onTap: () => doWhenPossible(),
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint),
        focusNode: focusNode);
  }

  InputObject<String> itemForString(String preObject, String hint,
      Map<String, dynamic> storedValues, void Function() doWhenPossible, String index) {
    TextEditingController stringController = TextEditingController(text: preObject);
    Widget displayWidget = notQuiteFull(
        _defaultTextField(stringController, storedValues, index, doWhenPossible, hint));
    return InputObject<String>(displayWidget, () {
      return stringController.text;
    }, index, (_) {});
  }

  InputObject<MyDateController?> itemForMyDate(
      String hint,
      String text,
      Map<String, dynamic> storedValues,
      void Function() createMyDateDayToShow,
      String index) {
    TextEditingController stringController = TextEditingController(text: text);
    var displayWidget = notQuiteFull(_defaultTextField(
        stringController, storedValues, index, createMyDateDayToShow, hint));

    return InputObject<MyDateController?>(displayWidget, () {
      return MyDateController.translate(stringController.text);
    }, index, (_) {});
  }

  InputObject<bool> itemForBoolean(
      bool preObject,
      String hint,
      String index,
      Map<String, dynamic> storedValues,
      Function setStateMethod,
      Function doWhenPossible) {
    return InputObject<bool>(
        _booleanButton(
            preObject, hint, index, storedValues, setStateMethod, doWhenPossible),
        () {
          //just in case its like 45 or '9' or whatever don't remove the == true
          return storedValues[index] == true;
        },
        index,
        (input) {
          input.displayWidget = _booleanButton(
              preObject, hint, index, storedValues, setStateMethod, doWhenPossible);
        });
  }

  Widget _booleanButton(
      bool preObject,
      String hint,
      String index,
      Map<String, dynamic> storedValues,
      Function setStateMethod,
      Function doWhenPossible) {
    return blagendaUniformButton(
        preObject, usedColors.first, '${preObject ? '⬤' : '◯'} - $hint', () {
      storedValues[index] = !preObject;
      setStateMethod();
    });
  }

  InputObject<String> itemForStringList(String stringList, String hint, String index,
      void Function() doWhenPossible, Map<String, dynamic> storedValues) {
    var stringController = TextEditingController(text: stringList);
    Widget displayWidget = notQuiteFull(_defaultTextField(
        stringController, storedValues, index, doWhenPossible, hint,
        maxLines: 5, keyboardType: TextInputType.multiline));
    return InputObject<String>(displayWidget, () {
      return '${stringController.text.trim()}\n';
    }, index, (_) {});
  }

  InputObject<int> itemForInt(int preObject, String hint, String index,
      Map<String, dynamic> storedValues, void Function() doWhenPossible) {
    var stringController = TextEditingController(text: preObject.toString());
    var displayWidget = notQuiteFull(_defaultTextField(
        stringController, storedValues, index, doWhenPossible, hint, onChanged: (s) {
      storedValues[index] = int.tryParse(s);
    }, keyboardType: TextInputType.number));
    return InputObject<int>(displayWidget, () {
      return int.parse(stringController.text);
    }, index, (_) {});
  }

  InputObject<int> itemForIntFromList(
      List<String> listToShow,
      String hint,
      String index,
      Map<String, dynamic> storedValues,
      Function setStateMethod,
      Function doWhenPossible) {
    return InputObject<int>(
        _createDropDown(
            listToShow, hint, index, storedValues, setStateMethod, doWhenPossible), () {
      return storedValues[index] as int;
    },
        index,
        (input) => input.displayWidget = _createDropDown(
            listToShow, hint, index, storedValues, setStateMethod, doWhenPossible));
  }

  Widget _createDropDown(
      List<String> listToShow,
      String hint,
      String index,
      Map<String, dynamic> storedValues,
      Function setStateMethod,
      Function doWhenPossible) {
    var text = Text(storedValues[index] == null
        ? hint
        : listToShow[(storedValues[index] - 1) % listToShow.length]);
    return notQuiteFull(DropdownButton<String>(
        hint: text,
        items: listToShow.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (s) {
          storedValues[index] = listToShow.indexOf(s ?? '') + 1;
          setStateMethod();
        },
        onTap: () => doWhenPossible()));
  }

  InputObject<Color> itemForColor(
      Function() setStateMethod,
      void Function(int) colorButtonPressed,
      Map<String, dynamic> storedValues,
      String index) {
    return InputObject<Color>(
        _widgetForColor(setStateMethod, colorButtonPressed, storedValues, index), () {
      return usedColors[storedValues[index]];
    },
        index,
        (input) => input.displayWidget =
            _widgetForColor(setStateMethod, colorButtonPressed, storedValues, index));
  }

  Widget _widgetForColor(Function() setStateMethod, void Function(int) colorButtonPressed,
      Map<String, dynamic> storedValues, String index) {
    return Column(
        children: globalCreateColorButtons(
            setStateMethod, colorButtonPressed, storedValues[index]));
  }

  InputObject<dynamic> itemForReferenceAbleList(
      String index,
      Map<String, dynamic> storedValues,
      void Function() onThingClick,
      String Function(dynamic) getNickname) {
    var but = blagendaUniformButton(
        false,
        usedColors.first,
        storedValues[index] == null ? "???" : getNickname(storedValues[index]),
        onThingClick);
    return InputObject<dynamic>(but, () {
      return storedValues[index];
    }, index, (_) {});
  }
}

mixin searchField {
  InputObject<DateRange> dateFinder(void Function() onConfirmed) {
    TextEditingController dateController = TextEditingController(),
        rangeController = TextEditingController();
    return InputObject(
        notQuiteFull(Row(children: [
          Expanded(flex: 3, child: _dateFinder(onConfirmed, dateController)),
          Expanded(flex: 2, child: _extraDatesFinder(onConfirmed, rangeController))
        ])),
        () {
          var dateBefore = MyDateController.translate(dateController.text);
          if (dateBefore == null && rangeController.text.isEmpty) {
            return const DateRange(0, -1);
          }
          var date = dateBefore ?? MyDateController.today;
          var dateRange = DateRange(
              date.daysLeftUntil(), _rangeCalculator(rangeController.text, date) ?? 0);
          return dateRange;
        },
        '',
        (_) {
          dateController.clear();
          rangeController.clear();
        });
  }

  InputObject<String> stringFinder(void Function() onConfirmed) {
    var textController = TextEditingController();
    return InputObject(notQuiteFull(_textFinder(textController, onConfirmed)), () {
      var toReturn = textController.text.toLowerCase();
      return toReturn;
    }, '', (_) => textController.clear());
  }

  InputObject<List<String>> tagFinder(void Function() onConfirmed) {
    TextEditingController nameController = TextEditingController(),
        dataController = TextEditingController();
    return InputObject(
        Row(children: [
          const Spacer(),
          Expanded(
              flex: 7, child: _textFinder(nameController, onConfirmed, 'Tag name', 3)),
          Expanded(
              flex: 7, child: _textFinder(dataController, onConfirmed, 'Tag data', 3)),
          const Spacer()
        ]),
        () {
          return [
            nameController.text.toLowerCase().trim(),
            dataController.text.toLowerCase().trim()
          ];
        },
        '',
        (_) {
          nameController.clear();
          dataController.clear();
        });
  }

  Widget _dateFinder(Function() onConfirmed, TextEditingController dateController) {
    return TextField(
        style: inputTextStyle,
        controller: dateController,
        onSubmitted: (s) {
          onConfirmed();
        },
        decoration: const InputDecoration(
            hintText: 'date to look up', border: OutlineInputBorder(gapPadding: 2)));
  }

  Widget _extraDatesFinder(
      Function() onConfirmed, TextEditingController rangeController) {
    return TextField(
        style: inputTextStyle,
        controller: rangeController,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]?[mw+]?'))],
        onSubmitted: (s) {
          onConfirmed();
        },
        decoration: const InputDecoration(
            hintText: '+ numb or m/w', border: OutlineInputBorder(gapPadding: 3)));
  }

  Widget _textFinder(TextEditingController stringController, Function() onConfirmed,
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
    var total =
        int.tryParse(text.replaceAll('m', '').replaceAll('w', '').replaceAll('+', ''));
    if (total == null) return null;
    var months = text.allMatches('m').length;
    if (months != 0) {
      months = MyDateController(date.year, date.month + months, date.day).daysLeftUntil();
    }
    return total +
        months +
        (text.allMatches('w').length + text.allMatches('+').length) * 7;
  }
}

Row notQuiteFull(Widget widget) => Row(
    children: [const Spacer(flex: 1), Expanded(flex: 14, child: widget), const Spacer()]);

class InputObject<t> {
  InputObject(this.displayWidget, this.getValue, this.toFill, this.onReset);

  Widget displayWidget;
  t Function() getValue;
  String toFill;

  void Function(InputObject) onReset;
}

final class DateRange {
  final int myDateFromNow;
  final int range;

  const DateRange(this.myDateFromNow, this.range);
}
