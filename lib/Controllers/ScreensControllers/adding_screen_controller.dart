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

  bool waitToAddDate = false;
  bool typed = false;
  bool sendAlready = false;

  final int Function(Type) _getNewId;
  final Map<ItemsIn, dynamic> storedValues = {};

  AddingScreenController(BasicButton? button, this._getNewId) {
    if (button == null) {
      buttonType = BasicButton;
      id = -1;
      storedValues[ItemsIn.color] =
          usedColors.indexOf(_getCorrectColor(buttonType));
    } else {
      buttonType = button.runtimeType;
      fillStoredValues(button);
      id = button.id;
    }
  }

  void fillStoredValues(BasicButton button) {
    storedValues[ItemsIn.title] = button.job;
    storedValues[ItemsIn.extraInfo] = button.toDos.join('\n');
    storedValues[ItemsIn.color] =
        usedColors.indexWhere((e) => e.value == button.color.value);
    dynamic but = button;
    switch (buttonType) {
      case Deadline:
        storedValues[ItemsIn.date] = but.date
            .inputDisplayString(MyDateController.nowDate.year != but.date.year);
        break;
      case AgainAmountDay:
        storedValues[ItemsIn.f] = but.day;
        storedValues[ItemsIn.date] = but.date.timeLeftUntil().toString();
        break;
      case AgainYearDay:
        var date = MyDateController.fromDMNextTime(but.month, but.day);
        storedValues[ItemsIn.f] = MyDateController.months[date.month - 1];
        storedValues[ItemsIn.s] = MyDateController.monthDays[date.day - 1];
        break;
      case AgainMonthDay:
        storedValues[ItemsIn.f] = MyDateController.monthDays[but.day - 1];
        break;
      case AgainWeekDay:
        storedValues[ItemsIn.f] = MyDateController.daysEn[but.day - 1];
        break;
    }
  }

  dynamic getFromStoredValue(ItemsIn it, dynamic value) =>
      storedValues[it] ?? value;

  late Type buttonType;
  BasicButtonController? Function()? getButton;
  int Function()? getColor;
  bool showTop = false;
  Widget? myDateDayToShow;
  late int id;

  void switchButtonType() {
    waitToAddDate = false;
    myDateDayToShow = null;
    storedValues[ItemsIn.f] = null;
    storedValues[ItemsIn.s] = null;
    id = -1;
    storedValues[ItemsIn.color] =
        usedColors.indexOf(_getCorrectColor(buttonType));
  }

  List<Widget> createButton(void Function() setStateMethod) {
    List<Widget> widgetList = _buttonTypeSelection(setStateMethod);
    List<InputObject> itemList;
    switch (buttonType) {
      case Deadline:
        itemList = _deadline(setStateMethod);
        getButton = () {
          var date = itemList[1].getValue();
          if (date == null) return null;
          if (id == -1) id = _getNewId(DeadlineController);
          return DeadlineController(Deadline(
              titleGenerator(itemList[0].getValue()),
              itemList[2].getValue(),
              id,
              itemList.last.getValue(),
              date,
              ''));
        };
        break;
      case AgainYearDay:
        itemList = _againYear(setStateMethod);
        getButton = () {
          if (itemList[2].getValue() == null ||
              itemList[1].getValue() == null) {
            return null;
          }
          if (id == -1) id = _getNewId(AgainYearController);
          return AgainYearController(AgainYearDay(
              titleGenerator(itemList[0].getValue()),
              itemList[3].getValue(),
              id,
              itemList.last.getValue(),
              itemList[2].getValue() + 1,
              itemList[1].getValue() + 1,
              null));
        };
        break;
      case AgainMonthDay:
        itemList = _againMonth(setStateMethod);
        getButton = () {
          if (itemList[1].getValue() == null) {
            return null;
          }
          if (id == -1) id = _getNewId(AgainMonthController);
          return AgainMonthController(AgainMonthDay(
              titleGenerator(itemList[0].getValue()),
              itemList[2].getValue(),
              id,
              itemList.last.getValue(),
              itemList[1].getValue() + 1,
              null));
        };
        break;
      case AgainWeekDay:
        itemList = _againWeek(setStateMethod);
        getButton = () {
          if (itemList[1].getValue() == null) {
            return null;
          }
          if (id == -1) id = _getNewId(AgainWeekController);
          return AgainWeekController(AgainWeekDay(
              titleGenerator(itemList[0].getValue()),
              itemList[2].getValue(),
              id,
              itemList.last.getValue(),
              itemList[1].getValue() + 1,
              null));
        };
        break;
      case AgainAmountDay:
        itemList = _againAmount(setStateMethod);
        getButton = () {
          var date = itemList[1].getValue();
          if (date == null) return null;
          if (id == -1) id = _getNewId(AgainAmountController);
          return AgainAmountController(AgainAmountDay(
              titleGenerator(itemList[0].getValue()),
              itemList[3].getValue(),
              id,
              itemList.last.getValue(),
              date,
              itemList[2].getValue(),
              null));
        };
        break;
      default:
        itemList = _note(setStateMethod);
        getButton = () {
          if (id == -1) id = _getNewId(NoteController);
          return NoteController(BasicButton(
              titleGenerator(itemList[0].getValue()),
              itemList[1].getValue(),
              id,
              itemList[2].getValue()));
        };
        break;
    }
    for (var it in itemList) {
      widgetList.add(it.displayWidget);
    }
    if (myDateDayToShow != null) {
      widgetList.add(myDateDayToShow!);
    }
    return widgetList;
  }

  List<Widget> _addButtonsForButtonType(
      Map<Type, String> typeList, void Function() setStateMethod) {
    List<Widget> widgetList = [];
    typeList.forEach((type, stringValue) => widgetList.add(
            blagendaUniformButton(
                buttonType == type, _getCorrectColor(type), stringValue, () {
          buttonType = type;
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

  static Color _getCorrectColor(Type type) {
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

  List<InputObject> _note(void Function() setStateMethod) {
    return [
      _itemForString(
          getFromStoredValue(ItemsIn.title, ''), 'Title', ItemsIn.title),
      _itemForStringList(getFromStoredValue(ItemsIn.extraInfo, ''),
          'Extra Info', ItemsIn.extraInfo),
      _itemForColor(setStateMethod)
    ];
  }

  List<InputObject> _deadline(void Function() setStateMethod) {
    return [
      _itemForString(
          getFromStoredValue(ItemsIn.title, ''), 'Title', ItemsIn.title),
      _itemForMyDate(getFromStoredValue(ItemsIn.date, ''), 'Date', ItemsIn.date,
          setStateMethod),
      _itemForStringList(getFromStoredValue(ItemsIn.extraInfo, ''),
          'Extra Info', ItemsIn.extraInfo),
      _itemForColor(setStateMethod)
    ];
  }

  List<InputObject> _againAmount(void Function() setStateMethod) {
    return [
      _itemForString(
          getFromStoredValue(ItemsIn.title, ''), 'Title', ItemsIn.title),
      _itemForMyDate(getFromStoredValue(ItemsIn.date, ''), 'Next time',
          ItemsIn.date, setStateMethod),
      _itemForInt(getFromStoredValue(ItemsIn.f, 0), 'Days amount', ItemsIn.f),
      _itemForStringList(getFromStoredValue(ItemsIn.extraInfo, ''),
          'Extra Info', ItemsIn.extraInfo),
      _itemForColor(setStateMethod)
    ];
  }

  List<InputObject> _againWeek(void Function() setStateMethod) {
    return [
      _itemForString(
          getFromStoredValue(ItemsIn.title, ''), 'Title', ItemsIn.title),
      _itemIntFromList(setStateMethod, getFromStoredValue(ItemsIn.f, 'Weekday'),
          MyDateController.daysEn, ItemsIn.f),
      _itemForStringList(getFromStoredValue(ItemsIn.extraInfo, ''),
          'Extra Info', ItemsIn.extraInfo),
      _itemForColor(setStateMethod)
    ];
  }

  List<InputObject> _againMonth(void Function() setStateMethod) {
    return [
      _itemForString(
          getFromStoredValue(ItemsIn.title, ''), 'Title', ItemsIn.title),
      _itemIntFromList(
          setStateMethod,
          getFromStoredValue(ItemsIn.f, 'Day of month'),
          MyDateController.monthDays,
          ItemsIn.f),
      _itemForStringList(getFromStoredValue(ItemsIn.extraInfo, ''),
          'Extra Info', ItemsIn.extraInfo),
      _itemForColor(setStateMethod)
    ];
  }

  List<InputObject> _againYear(void Function() setStateMethod) {
    return [
      _itemForString(
          getFromStoredValue(ItemsIn.title, ''), 'Title', ItemsIn.title),
      _itemIntFromList(setStateMethod, getFromStoredValue(ItemsIn.f, 'Month'),
          MyDateController.months, ItemsIn.f),
      _itemIntFromList(
          setStateMethod,
          getFromStoredValue(ItemsIn.s, 'Day of month'),
          MyDateController.monthDays,
          ItemsIn.s),
      _itemForStringList(getFromStoredValue(ItemsIn.extraInfo, ''),
          'Extra Info', ItemsIn.extraInfo),
      _itemForColor(setStateMethod)
    ];
  }

  InputObject<String> _itemForString(
      String preObject, String hint, ItemsIn itemsIn) {
    TextEditingController stringController =
        TextEditingController(text: preObject);
    var displayWidget = TextField(
        controller: stringController,
        onChanged: (s) {
          storedValues[itemsIn] = s;
          typed = true;
        },
        onTap: () => sendAlready = true,
        decoration: InputDecoration(
            hintText: hint, border: const OutlineInputBorder(gapPadding: 2)));
    return InputObject<String>.filled(displayWidget, () {
      return stringController.text;
    });
  }

  InputObject<MyDateController?> _itemForMyDate(String preObject, String hint,
      ItemsIn itemsIn, void Function() setStateMethod) {
    TextEditingController stringController =
        TextEditingController(text: preObject);
    var displayWidget = TextField(
        controller: stringController,
        onChanged: (s) {
          typed = true;
          storedValues[itemsIn] = s;
          var date = MyDateController.translate(storedValues[itemsIn]);
          if (date != null) {
            makeDateView(
                () => MyDateController.translate(stringController.text),
                setStateMethod);
          }
        },
        onTap: () => sendAlready = true,
        decoration: InputDecoration(
            hintText: hint, border: const OutlineInputBorder(gapPadding: 2)));
    return InputObject<MyDateController?>.filled(displayWidget, () {
      return MyDateController.translate(stringController.text);
    });
  }

  InputObject<bool> _itemForBoolean(void Function() setStateMethod,
      bool preObject, String hint, ItemsIn itemsIn) {
    storedValues[itemsIn] = preObject;
    var displayWidget = blagendaUniformButton(
        !preObject, usedColors.first, (!preObject ? "⬤" : "◯") + hint, () {
      storedValues[itemsIn] = preObject ? false : true;
      setStateMethod();
      sendAlready = true;
    });
    return InputObject<bool>.filled(displayWidget, () {
      return storedValues[itemsIn];
    });
  }

  InputObject<Color> _itemForColor(void Function() setStateMethod) {
    var column = Column(
        children: globalCreateColorButtons(
            setStateMethod, _colorButtonPressed, storedValues[ItemsIn.color]));
    return InputObject<Color>.filled(column, () {
      return usedColors[storedValues[ItemsIn.color]];
    });
  }

  void _colorButtonPressed(int index) => storedValues[ItemsIn.color] = index;

  InputObject<List<String>> _itemForStringList(
      String stringList, String hint, ItemsIn itemsIn) {
    var stringController = TextEditingController(text: stringList);
    var displayWidget = TextField(
        controller: stringController,
        keyboardType: TextInputType.multiline,
        onChanged: (s) {
          storedValues[itemsIn] = s;
          typed = true;
        },
        onTap: () => sendAlready = true,
        maxLines: 5,
        decoration: InputDecoration(
            hintText: hint, border: const OutlineInputBorder(gapPadding: 2)));
    return InputObject<List<String>>.filled(displayWidget, () {
      return stringController.text.trim().split('\n');
    });
  }

  InputObject<int> _itemForInt(int preObject, String hint, ItemsIn itemsIn) {
    var stringController = TextEditingController(text: preObject.toString());
    var displayWidget = TextField(
        controller: stringController,
        onChanged: (s) {
          storedValues[itemsIn] = int.tryParse(s);
          typed = true;
        },
        onTap: () => sendAlready = true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            hintText: hint, border: const OutlineInputBorder(gapPadding: 2)));
    return InputObject<int>.filled(displayWidget, () {
      return int.parse(stringController.text);
    });
  }

  InputObject<int> _itemIntFromList(void Function() setStateMethod,
      String displayValue, List<String> listToShow, ItemsIn itemsIn) {
    var displayWidget = DropdownButton<String>(
        hint: Text(storedValues[itemsIn] ?? displayValue),
        items: listToShow.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (s) {
          typed = true;
          storedValues[itemsIn] = s;
          setStateMethod();
        },
        onTap: () => sendAlready = true);
    return InputObject<int>.filled(displayWidget, () {
      return listToShow.indexOf(storedValues[itemsIn]);
    });
  }

  List<Widget> _buttonTypeSelection(void Function() setStateMethod) {
    List<Widget> widgetList = [];
    storedValues[ItemsIn.showTop] = getFromStoredValue(
        ItemsIn.showTop, buttonTypesPart1.containsKey(buttonType));
    var itemSwitch = _itemForBoolean(setStateMethod,
        storedValues[ItemsIn.showTop], 'Type of Item', ItemsIn.showTop);
    widgetList.add(itemSwitch.displayWidget);
    widgetList.addAll(_addButtonsForButtonType(
        storedValues[ItemsIn.showTop] ? buttonTypesPart1 : buttonTypesPart2,
        () {
      switchButtonType();
      setStateMethod();
    }));
    return widgetList;
  }

  Future<void> makeDateView(MyDateController? Function() caller,
      void Function() setStateMethod) async {
    sendAlready = false;
    if (waitToAddDate) return;
    waitToAddDate = true;
    while (typed) {
      typed = false;
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (sendAlready) {
          makeDateViewOverride(caller, setStateMethod);
          sendAlready = false;
          return;
        }
      }
    }
    makeDateViewOverride(caller, setStateMethod);
  }

  Future<void> makeDateViewOverride(MyDateController? Function() caller,
      void Function() setStateMethod) async {
    var date = caller();
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

  InputObject.filled(this.displayWidget, this.getValue);

  late Widget displayWidget;
  late t Function() getValue;
}

enum ItemsIn { title, extraInfo, date, color, f, s, showTop }
