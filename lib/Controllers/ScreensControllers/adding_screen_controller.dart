import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/deadline_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/note_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:flutter/material.dart';

import '../../Loading/button_conversion.dart';
import '../../common_items.dart';
import 'common_day_display_screen_controller.dart';
import 'common_screen_controller.dart';

class AddingScreenController {
  static const int _againWeekColor = 3;
  static const int _againYearColor = 6;
  static const Map<Type, String> _buttonTypesPart1 = {
    BasicButton: 'Note',
    Deadline: 'Deadline',
    AgainWeekDay: 'Weekly'
  };
  static const Map<Type, String> _buttonTypesPart2 = {
    AgainYearDay: 'Yearly',
    AgainMonthDay: 'Monthly',
    AgainAmountDay: 'Every x days'
  };
  static bool _noCheck(Map<ValuesOfButtons, dynamic> map) => true;
  final List<InputObject> _widgetsOnScreen = [];

  bool Function(Map<ValuesOfButtons, dynamic>) _checks = _noCheck;
  final void Function() _setStateMethod;
  late Type _buttonType;
  BasicButtonController? Function()? getButton;
  Widget? _myDateDayToShow;
  late int _id;
  InputObject<bool>? _chosenStateIsOne;

  final int Function(Type) _getNewId;
  final Map<ValuesOfButtons, dynamic> storedValues = {};

  AddingScreenController(BasicButton? button, this._getNewId,
      this._setStateMethod) {
    if (button == null) {
      _buttonType = BasicButton;
      _id = -1;
      storedValues[ValuesOfButtons.col] =
          usedColors.indexOf(_getDefaultTypeColor(_buttonType));
    } else {
      _buttonType = button.runtimeType;
      _fillStoredValues(button);
      _id = button.id!;
    }
  }

  void _fillStoredValues(dynamic button) {
    storedValues.addAll(buttonToMap(button));
    storedValues[ValuesOfButtons.todo] =
        storedValues[ValuesOfButtons.todo].join('\n');
    storedValues[ValuesOfButtons.col] = usedColors
        .indexWhere((e) => e.value == storedValues[ValuesOfButtons.col].value);
    switch (_buttonType) {
      case Deadline:
        storedValues[ValuesOfButtons.dat] = storedValues[ValuesOfButtons.dat]
            .inputDisplayString(MyDateController.nowDate.year !=
            storedValues[ValuesOfButtons.dat].year);
        break;
      case AgainAmountDay:
        storedValues[ValuesOfButtons.dat] =
            storedValues[ValuesOfButtons.dat].timeLeftUntil().toString();
        break;
    }
  }

  dynamic _getFromStoredValue(ValuesOfButtons it, dynamic value) =>
      storedValues[it] ?? value;

  void _switchButtonType() {
    _myDateDayToShow = null;
    _id = -1;
    storedValues[ValuesOfButtons.col] =
        usedColors.indexOf(_getDefaultTypeColor(_buttonType));
  }

  List<Widget> createScreenWidgets() {
    _widgetsOnScreen.clear();
    Type correctController;
    switch (_buttonType) {
      case Deadline:
        _deadlineFillerList();
        correctController = DeadlineController;
        _checks = (map) => map[ValuesOfButtons.dat] != null;
        break;
      case AgainYearDay:
        _againYearFillerList();
        correctController = AgainYearController;
        _checks = (map) =>
        map[ValuesOfButtons.mon] != null &&
            map[ValuesOfButtons.day] != null;
        break;
      case AgainMonthDay:
        _againMonthFillerList();
        correctController = AgainMonthController;
        _checks = (map) => map[ValuesOfButtons.day] != null;
        break;
      case AgainWeekDay:
        _againWeekFillerList();
        correctController = AgainWeekController;
        _checks = (map) => map[ValuesOfButtons.day] != null;
        break;
      case AgainAmountDay:
        _againAmountFillerList();
        correctController = AgainAmountController;
        _checks = (map) =>
        map[ValuesOfButtons.dat] != null &&
            map[ValuesOfButtons.day] != null;
        break;
      default:
        _defaultFillerList();
        correctController = NoteController;
        _checks = _noCheck;
        break;
    }
    getButton = () {
      var data = Map.fromEntries(
          _widgetsOnScreen.map((e) => MapEntry(e.toFill, e.getValue())));
      if (!_checks(data)) {
        return null;
      }
      data.addAll(
          {ValuesOfButtons.id: _id == -1 ? _getNewId(correctController) : _id});
      return buttonToController(_buttonType, buttonCreator(data, _buttonType));
    };
    List<Widget> widgetList = _buttonTypeSelection();
    for (var it in _widgetsOnScreen) {
      widgetList.add(it.displayWidget);
    }
    if (_myDateDayToShow != null) {
      widgetList.add(_myDateDayToShow!);
    }
    return widgetList;
  }

  List<Widget> _addButtonsForButtonType(Map<Type, String> typeList,) {
    List<Widget> widgetList = [];
    typeList.forEach((type, stringValue) =>
        widgetList.add(blagendaUniformButton(
            _buttonType == type, _getDefaultTypeColor(type), stringValue, () {
          _buttonType = type;
          _switchButtonType();
          _setStateMethod();
        })));
    widgetList = [
      Row(children: [
        const Spacer(),
        widgetList[0],
        widgetList[1],
        const Spacer()
      ]),
      Row(children: [
        const Spacer(),
        widgetList[2],
        widgetList.length > 3 ? widgetList[3] : const Text(''),
        const Spacer()
      ])
    ];
    return widgetList;
  }

  static Color _getDefaultTypeColor(Type type) {
    Color col;
    switch (type) {
      case AgainWeekDay:
        col = usedColors[_againWeekColor];
        break;
      case AgainYearDay:
        col = usedColors[_againYearColor];
        break;
      default:
        col = usedColors.first;
        break;
    }
    return col;
  }

  void _defaultFillerList() {
    _widgetsOnScreen.addAll([
      _itemForStringList(_getFromStoredValue(ValuesOfButtons.todo, ''),
          'Extra Info', ValuesOfButtons.todo),
      _itemForColor()
    ]);
    _widgetsOnScreen.insert(
        0,
        _itemForString(_getFromStoredValue(ValuesOfButtons.job, ''), 'Title',
            ValuesOfButtons.job));
  }

  void _deadlineFillerList() {
    _widgetsOnScreen.add(
      _itemForMyDate(_getFromStoredValue(ValuesOfButtons.dat, ''), 'Date')
    );
    _defaultFillerList();
  }

  void _againAmountFillerList() {
    _widgetsOnScreen.addAll([
      _itemForMyDate(_getFromStoredValue(ValuesOfButtons.dat, ''), 'Next time'),
      _itemForInt(_getFromStoredValue(ValuesOfButtons.day, 0), 'Days amount',
          ValuesOfButtons.day)]
    );
    _defaultFillerList();
  }

  void _againWeekFillerList() {
    _widgetsOnScreen.add(
      _itemIntFromList(MyDateController.daysEn, 'Weekday', ValuesOfButtons.day),
    );
    _defaultFillerList();
  }

  void _againMonthFillerList() {
    _widgetsOnScreen.add(
      _itemIntFromList(
          MyDateController.monthDays, 'Day of month', ValuesOfButtons.day),
    );
    _defaultFillerList();
  }

  void _againYearFillerList() {
    _widgetsOnScreen.addAll([
      _itemIntFromList(MyDateController.months, 'Month', ValuesOfButtons.mon),
      _itemIntFromList(
          MyDateController.monthDays, 'Day of month', ValuesOfButtons.day),
    ]);
    _defaultFillerList();
  }

  InputObject<String> _itemForString(String preObject, String hint,
      ValuesOfButtons itemsIn) {
    TextEditingController stringController =
    TextEditingController(text: preObject);
    var displayWidget = TextField(
        controller: stringController,
        onChanged: (s) {
          storedValues[itemsIn] = s;
        },
        onTap: () => _createMyDateDayToShow(),
        decoration: InputDecoration(
            hintText: hint, border: const OutlineInputBorder(gapPadding: 2)));
    return InputObject<String>.filled(displayWidget, () {
      return stringController.text;
    }, itemsIn);
  }

  InputObject<MyDateController?> _itemForMyDate(String preObject, String hint) {
    TextEditingController stringController =
    TextEditingController(text: preObject);
    var displayWidget = TextField(
        controller: stringController,
        onChanged: (s) {
          storedValues[ValuesOfButtons.dat] = s;
        },
        onTap: () => _createMyDateDayToShow(),
        decoration: InputDecoration(
            hintText: hint, border: const OutlineInputBorder(gapPadding: 2)));
    return InputObject<MyDateController?>.filled(displayWidget, () {
      return MyDateController.translate(stringController.text);
    }, ValuesOfButtons.dat);
  }

  InputObject<bool> _itemForBoolean(bool preObject, String hint) {
    var switchState = preObject;
    var displayWidget = blagendaUniformButton(
        !preObject, usedColors.first, (!preObject ? "⬤" : "◯") + hint, () {
      switchState = !preObject;
      _setStateMethod();
    });
    return InputObject<bool>.filled(displayWidget, () {
      return switchState;
    }, ValuesOfButtons.job);
  }

  InputObject<Color> _itemForColor() {
    var column = Column(
        children: globalCreateColorButtons(_setStateMethod, _colorButtonPressed,
            storedValues[ValuesOfButtons.col]));
    return InputObject<Color>.filled(column, () {
      return usedColors[storedValues[ValuesOfButtons.col]];
    }, ValuesOfButtons.col);
  }

  void _colorButtonPressed(int index) =>
      storedValues[ValuesOfButtons.col] = index;

  InputObject<List<String>> _itemForStringList(String stringList, String hint,
      ValuesOfButtons itemsIn) {
    var stringController = TextEditingController(text: stringList);
    var displayWidget = TextField(
        controller: stringController,
        keyboardType: TextInputType.multiline,
        onChanged: (s) {
          storedValues[itemsIn] = s;
        },
        onTap: () => _createMyDateDayToShow(),
        maxLines: 5,
        decoration: InputDecoration(
            hintText: hint, border: const OutlineInputBorder(gapPadding: 2)));
    return InputObject<List<String>>.filled(displayWidget, () {
      return stringController.text.trim().split('\n');
    }, itemsIn);
  }

  InputObject<int> _itemForInt(int preObject, String hint,
      ValuesOfButtons itemsIn) {
    var stringController = TextEditingController(text: preObject.toString());
    var displayWidget = TextField(
        controller: stringController,
        onChanged: (s) {
          storedValues[itemsIn] = int.tryParse(s);
        },
        onTap: () => _createMyDateDayToShow(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            hintText: hint, border: const OutlineInputBorder(gapPadding: 2)));
    return InputObject<int>.filled(displayWidget, () {
      return int.parse(stringController.text);
    }, itemsIn);
  }

  InputObject<int> _itemIntFromList(List<String> listToShow, String hint,
      ValuesOfButtons itemsIn) {
    var displayWidget = DropdownButton<String>(
        hint: Text(storedValues[itemsIn] ?? hint),
        items: listToShow.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (s) {
          storedValues[itemsIn] = s;
          _setStateMethod();
        },
        onTap: () => _createMyDateDayToShow());
    return InputObject<int>.filled(displayWidget, () {
      return listToShow.indexOf(storedValues[itemsIn]) + 1;
    }, itemsIn);
  }

  List<Widget> _buttonTypeSelection() {
    List<Widget> widgetList = [];
    _chosenStateIsOne = _itemForBoolean(
        _chosenStateIsOne?.getValue() ??
            _buttonTypesPart1.containsKey(_buttonType),
        'Type of Item');
    widgetList.add(_chosenStateIsOne!.displayWidget);
    widgetList.addAll(_addButtonsForButtonType(
        _chosenStateIsOne!.getValue() ? _buttonTypesPart1 : _buttonTypesPart2));
    return widgetList;
  }

  Future<void> _createMyDateDayToShow() async {
    var date = storedValues[ValuesOfButtons.dat];
    if (date == null) return;
    List<EndBasedController> everythingList =
    await loading.getEndBasedButtons();
    var timeLeftUntil = date.timeLeftUntil();
    _myDateDayToShow = Column(
        children: createADay(
            MyDateController.nowDate,
            everythingList,
            timeLeftUntil,
            _setStateMethod,
                (c, o) => _addEndBasedButton(c),
            timeLeftUntil < 7));
    _setStateMethod();
  }

  Container _addEndBasedButton(EndBasedController controller) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            color: controller.color,
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Text(' ${controller.displayWithTimeJob()} ',
            style: normalTextStyle));
  }
}

class InputObject<t> {
  InputObject();

  InputObject.filled(this.displayWidget, this.getValue, this.toFill);

  late Widget displayWidget;
  late t Function() getValue;
  late ValuesOfButtons toFill;
}
