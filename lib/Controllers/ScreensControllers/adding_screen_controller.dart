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

import '../../Loading/button_notifier.dart';
import '../../common_items.dart';
import '../ObjectControllers/ButtonControllers/again_controller.dart';
import '../ObjectControllers/ButtonControllers/basic_button_controller.dart';
import '../ObjectControllers/ButtonControllers/deadline_controller.dart';
import '../ObjectControllers/ButtonControllers/end_based_controller.dart';
import '../ObjectControllers/ButtonControllers/note_controller.dart';
import '../blagenda_uniform_button.dart';
import 'mix_button_creator.dart';
import 'mix_input_handler.dart.dart';

class AddingScreenController with ButtonCreator, InputHandler {
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

  final ValueNotifier<Type> buttonType = ValueNotifier(BasicButton);
  final ValueNotifier<MyDateController?> date =
      ValueNotifier(null);
  final ValueNotifier<bool> showFist = ValueNotifier(true);

  final bool _withNote;

  static bool _noCheck(Map<PossibleValues, dynamic> map) => true;

  bool Function(Map<PossibleValues, dynamic>) _checksAndChanges = _noCheck;
  late final Widget _myDateDayToShow = DayShow(date, _notifier);
  late final InputObject<bool> _chosenStateIsOne = itemForBoolean('Type of Item', () => showFist.value, (s) => showFist.value = s);

  final Map<PossibleValues, InputObject> widgetsOnScreen = {};
  final Map<PossibleValues, dynamic> _storedValues = {};
  late int _id;
  late BasicButtonController? Function() getButton;
  final ButtonNotifier _notifier;

  AddingScreenController(BasicButton? button, this._notifier, this._withNote) {
    if (button == null) {
      if (_withNote) {
        buttonType.value = BasicButton;
      } else {
        buttonType.value = Deadline;
      }
      _id = -1;
      _storedValues[PossibleValues.col] =
          usedColors.indexOf(_getDefaultTypeColor(buttonType.value));
    } else {
      buttonType.value = button.runtimeType;
      fillStoredValues(button);
      _id = button.id!;
    }
    reCreateScreenWidgets(buttonType.value);
  }

  @visibleForTesting
  void fillStoredValues(dynamic button) {
    _storedValues.addAll(itemToStoringMap(button).map((key, value) => MapEntry(
        PossibleValues.values.firstWhere((nm) => enumToString(nm) == key),
        value)));
    _storedValues[PossibleValues.col] = usedColors
        .indexWhere((e) => e.value == _storedValues[PossibleValues.col].value);
    if (button is SkippableButton) {
      if (button is AgainWeird) {
        int value = _storedValues[PossibleValues.day] % 7;
        _storedValues[PossibleValues.mon] = value;
        _storedValues[PossibleValues.day] =
            (_storedValues[PossibleValues.day] ~/ 7) + 1;
      } else if (button is AgainAmountDay) {
        if (_storedValues[PossibleValues.str].daysLeftUntil() < 0) {
          _storedValues[PossibleValues.str]
              .addOrRemoveDays(_storedValues[PossibleValues.day]);
        }
      }
    }
  }

  t _getFromStoredValue<t>(PossibleValues it, t defaultValue) {
    if (_storedValues[it] == null || _storedValues[it].runtimeType != t) {
      return defaultValue;
    }
    return _storedValues[it];
  }

  void _setFromStoredValue<t>(PossibleValues it, t value) {
    if (it == PossibleValues.dat && t == MyDateController) {
      date.value = value as MyDateController;
    }
    _storedValues[it] = value;
  }

  @visibleForTesting
  void switchButtonType(Type newType) {
    date.value = null;
    _id = -1;
    _storedValues[PossibleValues.col] =
        usedColors.indexOf(_getDefaultTypeColor(newType));
    reCreateScreenWidgets(newType);
    buttonType.value = newType;
  }

  List<Widget> createScreenWidgets() {
    List<Widget> widgetList = _id == -1 ? _buttonTypeSelection() : [];
    for (var item in PossibleValues.values) {
      var it = widgetsOnScreen[item];
      if (it == null) continue;
      widgetList.add(it.displayWidget);
    }
    widgetList.add(_myDateDayToShow);
    return widgetList;
  }

  void reCreateScreenWidgets(Type newType) {
    widgetsOnScreen.clear();
    Type correctController;
    switch (newType) {
      case const (Deadline):
        _deadlineFillerList();
        correctController = DeadlineController;
        _checksAndChanges = (map) => map[PossibleValues.dat] != null;
        break;
      case const (AgainYearDay):
        _againYearFillerList();
        correctController = AgainYearController;
        _checksAndChanges = (map) =>
            map[PossibleValues.mon] != null && map[PossibleValues.day] != null;
        break;
      case const (AgainWeird):
        _againWeirdFillerList();
        correctController = AgainWeirdController;
        _checksAndChanges = (map) {
          var passed = map[PossibleValues.mon] != null &&
              map[PossibleValues.day] != null;
          if (passed) {
            map[PossibleValues.day] = map.remove(PossibleValues.mon) +
                (map[PossibleValues.day] - 1) * 7;
          }
          return passed;
        };
        break;
      case const (AgainMonthDay):
        _againMonthFillerList();
        correctController = AgainMonthController;
        _checksAndChanges = (map) => map[PossibleValues.day] != null;
        break;
      case const (AgainWeekDay):
        _againWeekFillerList();
        correctController = AgainWeekController;
        _checksAndChanges = (map) => map[PossibleValues.day] != null;
        break;
      case const (AgainAmountDay):
        _againAmountFillerList();
        correctController = AgainAmountController;
        _checksAndChanges = (map) =>
            map[PossibleValues.str] != null && map[PossibleValues.day] != null;
        break;
      default:
        _defaultFillerList();
        correctController = NoteController;
        _checksAndChanges = _noCheck;
        break;
    }
    getButton = () {
      Map<PossibleValues, dynamic> data =
          widgetsOnScreen.map((k, e) => MapEntry(k, e.getValue()));
      if (!_checksAndChanges(data)) {
        return null;
      }
      data.addAll({
        PossibleValues.id:
            _id == -1 ? _notifier.getNewId(correctController) : _id
      });
      return dataToController(map2Data(
          data.map(((k, e) => MapEntry(enumToString(k), e.getValue()))),
          buttonType.value));
    };
  }

  List<Widget> _addButtonsForButtonType(Map<Type, String> typeList) {
    List<Widget> widgetList = [];
    typeList.forEach((type, stringValue) =>
        widgetList.add(BlagendaUniformButton(
            buttonType.value == type, _getDefaultTypeColor(type), stringValue,
            () {
          switchButtonType(type);
        })));
    var valuesList = typeList.values.toList();
    return addAsRow((i) => widgetList[i], typeList.values.length,
        (i) => valuesList[i].length, 35);
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
    widgetsOnScreen.addAll({
      PossibleValues.job: itemForString(
          'Title',
          () => _getFromStoredValue(PossibleValues.job, ''),
          (s) => _setFromStoredValue(PossibleValues.job, s)),
      PossibleValues.todo: itemForStringList(
          'Extra Info',
          () => _getFromStoredValue(PossibleValues.todo, ''),
          (s) => _setFromStoredValue(PossibleValues.todo, s)),
      PossibleValues.col: itemForColor(
          () => _getFromStoredValue(PossibleValues.col, usedColors.first),
          (s) => _setFromStoredValue(PossibleValues.col, s)),
      PossibleValues.imp: itemForBoolean(
          'Is Important?',
          () => _getFromStoredValue(PossibleValues.imp, false),
          (s) => _setFromStoredValue(PossibleValues.imp, s))
    });
  }

  void _skippableFillerList() {
    widgetsOnScreen.addAll({
      PossibleValues.str: itemForMyDate(
          'Starts on',
          () =>
              _getFromStoredValue<MyDateController?>(PossibleValues.str, null),
          (s) => _setFromStoredValue(PossibleValues.str, s)),
      PossibleValues.end: itemForMyDate(
          'Stops on',
          () =>
              _getFromStoredValue<MyDateController?>(PossibleValues.end, null),
          (s) => _setFromStoredValue(PossibleValues.end, s))
    });
  }

  void _deadlineFillerList() {
    widgetsOnScreen.addAll({
      PossibleValues.dat: itemForMyDate(
          'Date',
          () =>
              _getFromStoredValue<MyDateController?>(PossibleValues.dat, null),
          (s) => _setFromStoredValue(PossibleValues.dat, s))
    });
    _defaultFillerList();
  }

  void _againAmountFillerList() {
    widgetsOnScreen.addAll({
      PossibleValues.str: itemForMyDate(
          'Next time',
          () =>
              _getFromStoredValue<MyDateController?>(PossibleValues.str, null),
          (s) => _setFromStoredValue(PossibleValues.str, s)),
      PossibleValues.day: itemForInt(
          'Days amount',
          () => _getFromStoredValue(PossibleValues.day, 0),
          (s) => _setFromStoredValue(PossibleValues.day, s)),
      PossibleValues.end: itemForMyDate(
          'Stops on',
          () =>
              _getFromStoredValue<MyDateController?>(PossibleValues.end, null),
          (s) => _setFromStoredValue(PossibleValues.end, s))
    });
    _defaultFillerList();
  }

  void _againWeekFillerList() {
    widgetsOnScreen.addAll({
      PossibleValues.day: itemForIntFromList(
          MyDateController.daysEn,
          'Weekday',
          () => _getFromStoredValue<int?>(PossibleValues.day, null),
          (s) => _setFromStoredValue(PossibleValues.day, s))
    });
    _skippableFillerList();
    _defaultFillerList();
  }

  void _againMonthFillerList() {
    widgetsOnScreen.addAll({
      PossibleValues.day: itemForIntFromList(
          MyDateController.monthDays,
          'Day of month',
          () => _getFromStoredValue<int?>(PossibleValues.day, null),
          (s) => _setFromStoredValue(PossibleValues.day, s))
    });
    _skippableFillerList();
    _defaultFillerList();
  }

  void _againYearFillerList() {
    widgetsOnScreen.addAll({
      PossibleValues.mon: itemForIntFromList(
          MyDateController.months,
          'Month',
          () => _getFromStoredValue<int?>(PossibleValues.day, null),
          (s) => _setFromStoredValue(PossibleValues.day, s)),
      PossibleValues.day: itemForIntFromList(
          MyDateController.monthDays,
          'Day of month',
          () => _getFromStoredValue<int?>(PossibleValues.day, null),
          (s) => _setFromStoredValue(PossibleValues.day, s))
    });
    _defaultFillerList();
  }

  void _againWeirdFillerList() {
    widgetsOnScreen.addAll({
      PossibleValues.mon: itemForIntFromList(
          MyDateController.daysEn,
          'Weekday',
          () => _getFromStoredValue<int?>(PossibleValues.day, null),
          (s) => _setFromStoredValue(PossibleValues.day, s)),
      PossibleValues.day: itemForIntFromList(
          ['1st', '2nd', '3d'],
          '- day',
          () => _getFromStoredValue<int?>(PossibleValues.day, null),
          (s) => _setFromStoredValue(PossibleValues.day, s))
    });
    _skippableFillerList();
    _defaultFillerList();
  }

  List<Widget> _buttonTypeSelection() {
    List<Widget> widgetList = [];
    widgetList.add(_chosenStateIsOne.displayWidget);
    widgetList.addAll(_addButtonsForButtonType(_chosenStateIsOne.getValue()
        ? _buttonTypesPart2
        : _withNote
            ? _buttonTypesPart1
            : _buttonTypesPart1NoNote));
    return widgetList;
  }
}

class DayShow extends StatefulWidget {
  const DayShow(this.date, this.notifier, {super.key});

  final ValueNotifier<MyDateController?> date;
  final ButtonNotifier notifier;

  @override
  State<StatefulWidget> createState() => _DayShow();
}

class _DayShow extends State<DayShow> with DayCreator {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.date,
        builder: (context, newDate, child) {
          if (newDate == null) {
            return const Text('');
          }
          var left = newDate.daysLeftUntil();
          return Container(
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Colors.lightGreenAccent, width: 4))),
              child: Column(
                  children: createADay(
                      MyDateController.nowDate,
                      widget.notifier.getEndbasedData(),
                      left,
                      _addEndBasedButton,
                      left < 7,
                      true)));
        });
  }

  Container _addEndBasedButton(EndBasedController controller, bool isExtra) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            color: controller.color,
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Text(
            '${isExtra ? BlagendaUniformButton.smollButStartText : ''} ${controller.gettingTheStringShort()} ',
            style: normalTextStyle));
  }
}
