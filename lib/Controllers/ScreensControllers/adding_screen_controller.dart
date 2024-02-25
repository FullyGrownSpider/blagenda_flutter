import 'package:blagenda_flutter_simple/Commons/Models/Buttons/again.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/deadline.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/skippable_button.dart';
import 'package:blagenda_flutter_simple/Commons/Models/Buttons/weird_again.dart';
import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/weird_again_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/mix_day_creator.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/Loading/conversion_base.dart';
import 'package:flutter/material.dart';

import '../../Loading/mix_loading.dart';
import '../../common_items.dart';
import '../ObjectControllers/ButtonControllers/again_controller.dart';
import '../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../ObjectControllers/ButtonControllers/deadline_controller.dart';
import '../ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../ObjectControllers/ButtonControllers/note_controller.dart';
import '../blagenda_uniform_button.dart';
import 'mix_button_creator.dart';
import 'mix_input_handler.dart.dart';

class AddingScreenController with buttonCreator, dayCreator, inputHandler, loading {
  static const int _againWeekColor = 3;
  static const int _againYearColor = 6;
  static const Map<Type, String> _buttonTypesPart1 = {
    BasicButton: 'Note',
    Deadline: 'Deadline',
    AgainWeekDay: 'Weekly',
    AgainAmountDay: 'Every x days'
  };
  static const Map<Type, String> _buttonTypesPart1NoNote = {
    Deadline: 'Deadline',
    AgainWeekDay: 'Weekly',
    AgainAmountDay: 'Every x days'
  };
  static const Map<Type, String> _buttonTypesPart2 = {
    AgainYearDay: 'Yearly',
    AgainMonthDay: 'Monthly',
    AgainWeird: 'Every xday of month'
  };

  final bool _withNote;

  static bool _noCheck(Map<String, dynamic> map) => true;
  final List<EndBasedController> Function() getEndBasedButtons;

  bool Function(Map<String, dynamic>) _checksAndChanges = _noCheck;
  final void Function() _setStateMethod;
  Widget? _myDateDayToShow;
  InputObject<bool>? _chosenStateIsOne;

  final int Function(Type) _getNewId;
  final List<InputObject> widgetsOnScreen = [];
  @visibleForTesting
  late Type buttonType;
  final Map<String, dynamic> _storedValues = {};
  late int _id;
  late BasicButtonController? Function() getButton;

  AddingScreenController(BasicButton? button, this._getNewId, this._setStateMethod,
      this.getEndBasedButtons, this._withNote) {
    if (button == null) {
      if (_withNote) {
        buttonType = BasicButton;
      } else {
        buttonType = Deadline;
      }
      _id = -1;
      _storedValues[enumToString(enumToString(PossibleValues.col))] =
          usedColors.indexOf(_getDefaultTypeColor(buttonType));
    } else {
      buttonType = button.runtimeType;
      fillStoredValues(button);
      _id = button.id!;
    }
    reCreateScreenWidgets();
  }

  @visibleForTesting
  void fillStoredValues(dynamic button) {
    _storedValues.addAll(itemToStoringMap(button));
    _storedValues[enumToString(PossibleValues.col)] = usedColors.indexWhere(
        (e) => e.value == _storedValues[enumToString(PossibleValues.col)].value);
    if (buttonType == Deadline) {
      _dateDisplay(enumToString(PossibleValues.dat));
    } else if (button is SkippableButton) {
      _dateDisplay(enumToString(PossibleValues.end));
      if (button is AgainWeird) {
        int value = _storedValues[enumToString(PossibleValues.day)] % 7;
        _storedValues[enumToString(PossibleValues.mon)] = value;
        _storedValues[enumToString(PossibleValues.day)] =
            (_storedValues[enumToString(PossibleValues.day)] ~/ 7) + 1;
      } else if (button is AgainAmountDay) {
        if (_storedValues[enumToString(PossibleValues.str)].daysLeftUntil() < 0) {
          _storedValues[enumToString(PossibleValues.str)]
              .addOrRemoveDays(_storedValues[enumToString(PossibleValues.day)]);
        }
      }
      _dateDisplay(enumToString(PossibleValues.str));
    }
  }

  void _dateDisplay(String val) {
    if (_storedValues[val] != null) {
      var toStore = _storedValues[val]!.daysLeftUntil();
      if (toStore < 14) {
        _storedValues[val] = toStore.toString();
      } else if (toStore < 30) {
        StringBuffer weekdayString =
            StringBuffer(MyDateController.daysEn[_storedValues[val]!.weekday - 1]);
        int days = _storedValues[val]!.difference(MyDateController.today).inDays - 7;
        for (int i = 0; i < days; i += 7) {
          weekdayString.write('+');
        }
        _storedValues[val] = weekdayString.toString();
      } else {
        _storedValues[val] = _storedValues[val]
            .inputDisplayString(MyDateController.nowDate.year != _storedValues[val].year);
      }
    }
  }

  dynamic _getFromStoredValue(String it, dynamic value) => _storedValues[it] ?? value;

  @visibleForTesting
  void switchButtonType() {
    _myDateDayToShow = null;
    _id = -1;
    _storedValues[enumToString(PossibleValues.col)] =
        usedColors.indexOf(_getDefaultTypeColor(buttonType));
    reCreateScreenWidgets();
    _setStateMethod();
  }

  List<Widget> createScreenWidgets() {
    List<Widget> widgetList = _id == -1 ? _buttonTypeSelection() : [];
    for (var it in widgetsOnScreen) {
      it.onReset(it);
      widgetList.add(it.displayWidget);
    }
    if (_myDateDayToShow != null) {
      widgetList.add(_myDateDayToShow!);
    }
    return widgetList;
  }

  void reCreateScreenWidgets() {
    widgetsOnScreen.clear();
    Type correctController;
    switch (buttonType) {
      case const (Deadline):
        _deadlineFillerList();
        correctController = DeadlineController;
        _checksAndChanges = (map) => map[enumToString(PossibleValues.dat)] != null;
        break;
      case const (AgainYearDay):
        _againYearFillerList();
        correctController = AgainYearController;
        _checksAndChanges = (map) =>
            map[enumToString(PossibleValues.mon)] != null &&
            map[enumToString(PossibleValues.day)] != null;
        break;
      case const (AgainWeird):
        _againWeirdFillerList();
        correctController = AgainWeirdController;
        _checksAndChanges = (map) {
          var passed = map[enumToString(PossibleValues.mon)] != null &&
              map[enumToString(PossibleValues.day)] != null;
          if (passed) {
            map[enumToString(PossibleValues.day)] =
                map.remove(enumToString(PossibleValues.mon)) +
                    (map[enumToString(PossibleValues.day)] - 1) * 7;
          }
          return passed;
        };
        break;
      case const (AgainMonthDay):
        _againMonthFillerList();
        correctController = AgainMonthController;
        _checksAndChanges = (map) => map[enumToString(PossibleValues.day)] != null;
        break;
      case const (AgainWeekDay):
        _againWeekFillerList();
        correctController = AgainWeekController;
        _checksAndChanges = (map) => map[enumToString(PossibleValues.day)] != null;
        break;
      case const (AgainAmountDay):
        _againAmountFillerList();
        correctController = AgainAmountController;
        _checksAndChanges = (map) =>
            map[enumToString(PossibleValues.str)] != null &&
            map[enumToString(PossibleValues.day)] != null;
        break;
      default:
        _defaultFillerList();
        correctController = NoteController;
        _checksAndChanges = _noCheck;
        break;
    }
    getButton = () {
      Map<String, dynamic> data =
          Map.fromEntries(widgetsOnScreen.map((e) => MapEntry(e.toFill, e.getValue())));
      if (!_checksAndChanges(data)) {
        return null;
      }
      data.addAll({
        enumToString(PossibleValues.id): _id == -1 ? _getNewId(correctController) : _id
      });
      return dataToController(map2Data(data, buttonType));
    };
  }

  List<Widget> _addButtonsForButtonType(Map<Type, String> typeList) {
    List<Widget> widgetList = [];
    typeList.forEach((type, stringValue) => widgetList.add(BlagendaUniformButton(
            buttonType == type, _getDefaultTypeColor(type), stringValue, () {
          buttonType = type;
          switchButtonType();
          _setStateMethod();
        })));
    var valuesList = typeList.values.toList();
    return addAsRow(
        (i) => widgetList[i], typeList.values.length, (i) => valuesList[i].length, 35);
  }

  static Color _getDefaultTypeColor(Type type) {
    Color col;
    switch (type) {
      case const (AgainWeekDay):
        col = usedColors[_againWeekColor];
        break;
      case const (AgainYearDay):
        col = usedColors[_againYearColor];
        break;
      default:
        col = usedColors.first;
        break;
    }
    return col;
  }

  void _defaultFillerList() {
    widgetsOnScreen.addAll([
      itemForStringList(
          _getFromStoredValue(enumToString(PossibleValues.todo), ''),
          'Extra Info',
          enumToString(PossibleValues.todo),
          _createMyDateDayToShow,
          _storedValues),
      itemForColor(_setStateMethod, _colorButtonPressed, _storedValues,
          enumToString(PossibleValues.col)),
      itemForBoolean(
          _getFromStoredValue(enumToString(PossibleValues.imp), false),
          'Is Important?',
          enumToString(PossibleValues.imp),
          _storedValues,
          _setStateMethod,
          _createMyDateDayToShow)
    ]);
    //everything has a job(name) so i want it at the top because its the most important
    widgetsOnScreen.insert(
        0,
        itemForString(_getFromStoredValue(enumToString(PossibleValues.job), ''), 'Title',
            _storedValues, _createMyDateDayToShow, enumToString(PossibleValues.job)));
  }

  void _skippableFillerList() {
    widgetsOnScreen.add(itemForMyDate(
        'Starts on',
        _getFromStoredValue(enumToString(PossibleValues.str), ''),
        _storedValues,
        _createMyDateDayToShow,
        enumToString(PossibleValues.str)));
    widgetsOnScreen.add(itemForMyDate(
        'Stops on',
        _getFromStoredValue(enumToString(PossibleValues.end), ''),
        _storedValues,
        _createMyDateDayToShow,
        enumToString(PossibleValues.end)));
  }

  void _deadlineFillerList() {
    widgetsOnScreen.add(itemForMyDate(
        'Date',
        _getFromStoredValue(enumToString(PossibleValues.dat), ''),
        _storedValues,
        _createMyDateDayToShow,
        enumToString(PossibleValues.dat)));
    _defaultFillerList();
  }

  void _againAmountFillerList() {
    widgetsOnScreen.addAll([
      itemForMyDate(
          'Next time',
          _getFromStoredValue(enumToString(PossibleValues.str), ''),
          _storedValues,
          _createMyDateDayToShow,
          enumToString(PossibleValues.str)),
      itemForInt(_getFromStoredValue(enumToString(PossibleValues.day), 0), 'Days amount',
          enumToString(PossibleValues.day), _storedValues, _setStateMethod),
      itemForMyDate('Stops on', _getFromStoredValue(enumToString(PossibleValues.end), ''),
          _storedValues, _createMyDateDayToShow, enumToString(PossibleValues.end))
    ]);
    _defaultFillerList();
  }

  void _againWeekFillerList() {
    widgetsOnScreen.add(
      itemForIntFromList(
          MyDateController.daysEn,
          'Weekday',
          enumToString(PossibleValues.day),
          _storedValues,
          _setStateMethod,
          _createMyDateDayToShow),
    );
    _skippableFillerList();
    _defaultFillerList();
  }

  void _againMonthFillerList() {
    widgetsOnScreen.add(
      itemForIntFromList(
          MyDateController.monthDays,
          'Day of month',
          enumToString(PossibleValues.day),
          _storedValues,
          _setStateMethod,
          _createMyDateDayToShow),
    );
    _skippableFillerList();
    _defaultFillerList();
  }

  void _againYearFillerList() {
    widgetsOnScreen.addAll([
      itemForIntFromList(
          MyDateController.months,
          'Month',
          enumToString(PossibleValues.mon),
          _storedValues,
          _setStateMethod,
          _createMyDateDayToShow),
      itemForIntFromList(
          MyDateController.monthDays,
          'Day of month',
          enumToString(PossibleValues.day),
          _storedValues,
          _setStateMethod,
          _createMyDateDayToShow),
    ]);
    _defaultFillerList();
  }

  void _againWeirdFillerList() {
    widgetsOnScreen.addAll([
      itemForIntFromList(
          MyDateController.daysEn,
          'Weekday',
          enumToString(PossibleValues.mon),
          _storedValues,
          _setStateMethod,
          _createMyDateDayToShow),
      itemForIntFromList(['1st', '2nd', '3d'], '- day', enumToString(PossibleValues.day),
          _storedValues, _setStateMethod, _createMyDateDayToShow),
    ]);
    _skippableFillerList();
    _defaultFillerList();
  }

  void _colorButtonPressed(int index) =>
      _storedValues[enumToString(PossibleValues.col)] = index;

  List<Widget> _buttonTypeSelection() {
    List<Widget> widgetList = [];
    _chosenStateIsOne = itemForBoolean(
        _chosenStateIsOne?.getValue() ?? _buttonTypesPart2.containsKey(buttonType),
        'Type of Item',
        '-1',
        _storedValues,
        _setStateMethod,
        _createMyDateDayToShow);
    widgetList.add(_chosenStateIsOne!.displayWidget);
    widgetList.addAll(_addButtonsForButtonType(_chosenStateIsOne!.getValue()
        ? _buttonTypesPart2
        : _withNote
            ? _buttonTypesPart1
            : _buttonTypesPart1NoNote));
    return widgetList;
  }

  Future<void> _createMyDateDayToShow() async {
    var date = _storedValues[enumToString(PossibleValues.dat)];
    if (date is String) {
      date = MyDateController.translate(date);
    }
    if (date == null) return;
    List<EndBasedController> everythingList = getEndBasedButtons();
    var timeLeftUntil = date.daysLeftUntil();
    _myDateDayToShow = Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.lightGreenAccent, width: 4))),
        child: Column(
            children: createADay(MyDateController.nowDate, everythingList, timeLeftUntil,
                _setStateMethod, (c, o) => _addEndBasedButton(c), timeLeftUntil < 7)));
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
        child: Text(' ${controller.gettingTheStringShort()} ', style: normalTextStyle));
  }
}
