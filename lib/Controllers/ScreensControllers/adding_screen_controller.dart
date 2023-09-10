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
  static const TextStyle noDateTextStyle = TextStyle(
      fontSize: 15.0,
      height: 1.7,
      fontWeight: FontWeight.bold,
      color: Colors.black);

  static const Map<Type, String> buttonTypesPart1 = {
    BasicButton: 'Note',
    Deadline: 'Deadline',
    AgainWeekDay: 'Weekly'
  };
  static const Map<Type, String> buttonTypesPart2 = {
    AgainYearDay: 'Yearly',
    AgainMonthDay: 'Monthly',
    AgainAmountDay: 'Every x days'
  };
  List<InputObject> screenToAdd = [];
  static bool Function(Map<ValuesOfButtons, dynamic>) noCheck = (x) => true;

  bool Function(Map<ValuesOfButtons, dynamic>) checks = noCheck;
  bool waitToAddDate = false;
  bool justTyped = false;
  bool updateDateNow = false;
  void Function() setStateMethod;
  late Type buttonType;
  BasicButtonController? Function()? getButton;
  int Function()? getColor;
  Widget? myDateDayToShow;
  late int _id;
  InputObject<bool>? _chosenStateIsOne;

  final int Function(Type) _getNewId;
  final Map<ValuesOfButtons, dynamic> storedValues = {};

  AddingScreenController(
      BasicButton? button, this._getNewId, this.setStateMethod) {
    if (button == null) {
      buttonType = BasicButton;
      _id = -1;
      storedValues[ValuesOfButtons.col] =
          usedColors.indexOf(_getDefaultTypeColor(buttonType));
    } else {
      buttonType = button.runtimeType;
      fillStoredValues(button);
      _id = button.id!;
    }
  }

  void fillStoredValues(dynamic button) {
    storedValues.addAll(buttonToMap(button));
    storedValues[ValuesOfButtons.todo] =
        storedValues[ValuesOfButtons.todo].join('\n');
    storedValues[ValuesOfButtons.col] = usedColors
        .indexWhere((e) => e.value == storedValues[ValuesOfButtons.col].value);
    switch (buttonType) {
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

  dynamic getFromStoredValue(ValuesOfButtons it, dynamic value) =>
      storedValues[it] ?? value;

  void switchButtonType() {
    waitToAddDate = false;
    myDateDayToShow = null;
    _id = -1;
    storedValues[ValuesOfButtons.col] =
        usedColors.indexOf(_getDefaultTypeColor(buttonType));
  }

  List<Widget> createScreenWidgets() {
    Type correctController;
    switch (buttonType) {
      case Deadline:
        _deadlineFillerList();
        correctController = DeadlineController;
        checks = (map) => map[ValuesOfButtons.dat] != null;
        break;
      case AgainYearDay:
        _againYearFillerList();
        correctController = AgainYearController;
        checks = (map) =>
            map[ValuesOfButtons.mon] != null &&
            map[ValuesOfButtons.day] != null;
        break;
      case AgainMonthDay:
        _againMonthFillerList();
        correctController = AgainMonthController;
        checks = (map) => map[ValuesOfButtons.day] != null;
        break;
      case AgainWeekDay:
        _againWeekFillerList();
        correctController = AgainWeekController;
        checks = (map) => map[ValuesOfButtons.day] != null;
        break;
      case AgainAmountDay:
        _againAmountFillerList();
        correctController = AgainAmountController;
        checks = (map) =>
            map[ValuesOfButtons.dat] != null &&
            map[ValuesOfButtons.day] != null;
        break;
      default:
        screenToAdd.clear();
        _defaultFillerList();
        correctController = NoteController;
        checks = noCheck;
        break;
    }
    getButton = () {
      var data = Map.fromEntries(
          screenToAdd.map((e) => MapEntry(e.toFill, e.getValue())));
      if (!checks(data)) {
        return null;
      }
      data.addAll(
          {ValuesOfButtons.id: _id == -1 ? _getNewId(correctController) : _id});
      return buttonToController(buttonType, buttonCreator(data, buttonType));
    };
    List<Widget> widgetList = _buttonTypeSelection();
    for (var it in screenToAdd) {
      widgetList.add(it.displayWidget);
    }
    if (myDateDayToShow != null) {
      widgetList.add(myDateDayToShow!);
    }
    return widgetList;
  }

  List<Widget> _addButtonsForButtonType(
    Map<Type, String> typeList,
  ) {
    List<Widget> widgetList = [];
    typeList.forEach((type, stringValue) =>
        widgetList.add(blagendaUniformButton(
            buttonType == type, _getDefaultTypeColor(type), stringValue, () {
          buttonType = type;
          switchButtonType();
          setStateMethod();
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
    screenToAdd.addAll([
      _itemForStringList(getFromStoredValue(ValuesOfButtons.todo, ''),
          'Extra Info', ValuesOfButtons.todo),
      _itemForColor()
    ]);
    screenToAdd.insert(
        0,
        _itemForString(getFromStoredValue(ValuesOfButtons.job, ''), 'Title',
            ValuesOfButtons.job));
  }

  void _deadlineFillerList() {
    screenToAdd = [
      _itemForMyDate(getFromStoredValue(ValuesOfButtons.dat, ''), 'Date')
    ];
    _defaultFillerList();
  }

  void _againAmountFillerList() {
    screenToAdd = [
      _itemForMyDate(getFromStoredValue(ValuesOfButtons.dat, ''), 'Next time'),
      _itemForInt(getFromStoredValue(ValuesOfButtons.day, 0), 'Days amount',
          ValuesOfButtons.day)
    ];
    _defaultFillerList();
  }

  void _againWeekFillerList() {
    screenToAdd = [
      _itemIntFromList(MyDateController.daysEn, 'Weekday', ValuesOfButtons.day),
    ];
    _defaultFillerList();
  }

  void _againMonthFillerList() {
    screenToAdd = [
      _itemIntFromList(
          MyDateController.monthDays, 'Day of month', ValuesOfButtons.day),
    ];
    _defaultFillerList();
  }

  void _againYearFillerList() {
    screenToAdd = [
      _itemIntFromList(MyDateController.months, 'Month', ValuesOfButtons.mon),
      _itemIntFromList(
          MyDateController.monthDays, 'Day of month', ValuesOfButtons.day),
    ];
    _defaultFillerList();
  }

  InputObject<String> _itemForString(
      String preObject, String hint, ValuesOfButtons itemsIn) {
    TextEditingController stringController =
        TextEditingController(text: preObject);
    var displayWidget = TextField(
        controller: stringController,
        onChanged: (s) {
          storedValues[itemsIn] = s;
          justTyped = true;
        },
        onTap: () => forceMakeDateView(),
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
          justTyped = true;
          storedValues[ValuesOfButtons.dat] = s;
          var date =
              MyDateController.translate(storedValues[ValuesOfButtons.dat]);
          if (date != null) {
            makeDateView();
          }
        },
        onTap: () => updateDateNow = true,
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
      setStateMethod();
      updateDateNow = true;
    });
    return InputObject<bool>.filled(displayWidget, () {
      return switchState;
    }, ValuesOfButtons.job);
  }

  InputObject<Color> _itemForColor() {
    var column = Column(
        children: globalCreateColorButtons(setStateMethod, _colorButtonPressed,
            storedValues[ValuesOfButtons.col]));
    return InputObject<Color>.filled(column, () {
      return usedColors[storedValues[ValuesOfButtons.col]];
    }, ValuesOfButtons.col);
  }

  void _colorButtonPressed(int index) =>
      storedValues[ValuesOfButtons.col] = index;

  InputObject<List<String>> _itemForStringList(
      String stringList, String hint, ValuesOfButtons itemsIn) {
    var stringController = TextEditingController(text: stringList);
    var displayWidget = TextField(
        controller: stringController,
        keyboardType: TextInputType.multiline,
        onChanged: (s) {
          storedValues[itemsIn] = s;
          justTyped = true;
        },
        onTap: () => updateDateNow = true,
        maxLines: 5,
        decoration: InputDecoration(
            hintText: hint, border: const OutlineInputBorder(gapPadding: 2)));
    return InputObject<List<String>>.filled(displayWidget, () {
      return stringController.text.trim().split('\n');
    }, itemsIn);
  }

  InputObject<int> _itemForInt(
      int preObject, String hint, ValuesOfButtons itemsIn) {
    var stringController = TextEditingController(text: preObject.toString());
    var displayWidget = TextField(
        controller: stringController,
        onChanged: (s) {
          storedValues[itemsIn] = int.tryParse(s);
          justTyped = true;
        },
        onTap: () => updateDateNow = true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            hintText: hint, border: const OutlineInputBorder(gapPadding: 2)));
    return InputObject<int>.filled(displayWidget, () {
      return int.parse(stringController.text);
    }, itemsIn);
  }

  InputObject<int> _itemIntFromList(
      List<String> listToShow, String hint, ValuesOfButtons itemsIn) {
    var displayWidget = DropdownButton<String>(
        hint: Text(storedValues[itemsIn] ?? hint),
        items: listToShow.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (s) {
          justTyped = true;
          storedValues[itemsIn] = s;
          setStateMethod();
        },
        onTap: () => updateDateNow = true);
    return InputObject<int>.filled(displayWidget, () {
      return listToShow.indexOf(storedValues[itemsIn]) + 1;
    }, itemsIn);
  }

  List<Widget> _buttonTypeSelection() {
    List<Widget> widgetList = [];
    _chosenStateIsOne = _itemForBoolean(
        _chosenStateIsOne?.getValue() ??
            buttonTypesPart1.containsKey(buttonType),
        'Type of Item');
    widgetList.add(_chosenStateIsOne!.displayWidget);
    widgetList.addAll(_addButtonsForButtonType(
        _chosenStateIsOne!.getValue() ? buttonTypesPart1 : buttonTypesPart2));
    return widgetList;
  }

  void forceMakeDateView() {
    updateDateNow = true;
    makeDateView();
  }

  Future<void> makeDateView() async {
    if (updateDateNow) {
      var date = storedValues[ValuesOfButtons.dat];
      if (date == null) {
        updateDateNow = false;
      } else {
        _createMyDateDayToShow();
        updateDateNow = false;
      }
      waitToAddDate = false;
      return;
    }
    if (waitToAddDate) return;
    waitToAddDate = true;
    while (justTyped) {
      justTyped = false;
      await Future.delayed(const Duration(seconds: 2));
      if (justTyped) {
        _createMyDateDayToShow();
        return;
      } else if (!waitToAddDate) {
        return;
      }
    }
  }

  Future<void> _createMyDateDayToShow() async {
    var date = MyDateController.translate(storedValues[ValuesOfButtons.dat]);
    List<EndBasedController> everythingList =
        await loading.getEndBasedButtons();
    if (!waitToAddDate) return;
    if (date == null) {
      myDateDayToShow = const Text('Date not found', style: noDateTextStyle);
    } else {
      var timeLeftUntil = date.timeLeftUntil();
      myDateDayToShow = Column(
          children: createADay(
              MyDateController.nowDate,
              everythingList,
              timeLeftUntil,
              setStateMethod,
              (c, o) => _addEndBasedButton(c),
              timeLeftUntil < 7));
    }
    setStateMethod();
    waitToAddDate = false;
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

  String titleGenerator(String title) => title.isEmpty ? 'No title' : title;
}

class InputObject<t> {
  InputObject();

  InputObject.filled(this.displayWidget, this.getValue, this.toFill);

  late Widget displayWidget;
  late t Function() getValue;
  late ValuesOfButtons toFill;
}
