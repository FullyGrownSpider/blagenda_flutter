import 'package:blagenda_flutter_simple/Controllers/ObjectControllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter/material.dart';

import '../../Loading/button_notifier.dart';
import '../ObjectControllers/mix_search_able.dart';
import '../blagenda_uniform_button.dart';
import 'mix_day_creator.dart';
import 'mix_input_handler.dart.dart';

class SearchScreenController<T extends SearchAble> extends ChangeNotifier
    with DayCreator, SearchField {
  String _searchingText = '';
  final Future<dynamic> Function(T) _doActionWithClickedItem;
  @visibleForTesting
  final Map<SearchTypes, InputObject> searches = {};
  @visibleForTesting
  final List<T> foundItems = [];
  final List<Widget> _list = [];
  DateRange date = const DateRange(0, -1, []);
  late final Widget searchBut =
      BlagendaUniformButton(usedColors.last, () => 'Search', resetSearch);

  StoreAbleNotifier<SearchAble> notifier;

  SearchScreenController(this._doActionWithClickedItem, this.notifier) {
    Set searchesSet = {};
    for (var e in notifier.getData().whereType<T>()) {
      searchesSet.addAll(e.possibleSearches());
    }
    for (var key in searchesSet) {
      if (key == SearchTypes.date) {
        searches[key] = dateFinder(resetSearch, () => date, (s) => date = s);
      } else if (key == SearchTypes.string) {
        searches[key] = stringFinder(resetSearch);
      } else if (key == SearchTypes.tag) {
        searches[key] = tagFinder(resetSearch);
      }
    }
    resetSearch();
  }

  static const TextStyle styleDays =
      TextStyle(fontSize: 20.0, height: 2.5, color: Colors.green);

  @visibleForTesting
  void resetSearch() {
    if (notifier.getData().whereType<T>().isEmpty) {
      _searchingText = 'no items';
      return;
    }
    var everyThingCopy = [...notifier.getData().whereType<T>()];
    _searchingText = '';
    foundItems.clear();
    Map<T, int> scoreMap = {};
    if (searches.containsKey(SearchTypes.date)) {
      var data = searches[SearchTypes.date]!.getValue() as DateRange;
      if (data.range > -1) {
        var from = MyDateController.fromDaysFromNow(data.myDateFromNow);
        if (data.weekdays.isNotEmpty) {
          _searchingText =
              'Every {weekday(s)} ${data.range == 0 ? '' : 'for ${data.range} weeks'}';
        } else if (data.range == 0) {
          _searchingText =
              'On ${from.stringFullDisplayWithCal(from.year == MyDateController.today.year)}';
        } else {
          _searchingText =
              '${from.stringFullDisplayWithCal(from.year == MyDateController.today.year)} to ${MyDateController.fromDaysFromNow(data.myDateFromNow + data.range).stringFullDisplayWithCal(from.year == MyDateController.today.year)}';
        }
        for (int i = 0; i < everyThingCopy.length; i++) {
          var score = everyThingCopy[i].searchHere(SearchTypes.date, data);
          if (score == 0) {
            everyThingCopy.removeAt(i);
            i--;
          } else {
            scoreMap[everyThingCopy[i]] = score;
          }
        }
      }
    }
    if (searches.containsKey(SearchTypes.string)) {
      var data = searches[SearchTypes.string]!.getValue() as String;
      if (data.isNotEmpty) {
        if (_searchingText.isNotEmpty) _searchingText += '\n and \n';
        _searchingText += data;
        for (int i = 0; i < everyThingCopy.length; i++) {
          var score = everyThingCopy[i].searchHere(SearchTypes.string, data);
          if (score == 0) {
            everyThingCopy.removeAt(i);
            i--;
          } else {
            if (scoreMap[everyThingCopy[i]] == null) {
              scoreMap[everyThingCopy[i]] = 0;
            }
            scoreMap[everyThingCopy[i]] = score;
          }
        }
      }
    }
    if (searches.containsKey(SearchTypes.tag)) {
      var data = searches[SearchTypes.tag]!.getValue() as List<String>;
      if (data.first.isNotEmpty || data.last.isNotEmpty) {
        if (_searchingText.isNotEmpty) _searchingText += '\n and \n';
        _searchingText += '${data[0]} - ${data[1]}';
        for (int i = 0; i < everyThingCopy.length; i++) {
          var score = everyThingCopy[i].searchHere(SearchTypes.tag, data);
          if (score == 0) {
            everyThingCopy.removeAt(i);
            i--;
          } else {
            if (scoreMap[everyThingCopy[i]] == null) {
              scoreMap[everyThingCopy[i]] = 0;
            }
            scoreMap[everyThingCopy[i]] = score;
          }
        }
      }
    }
    //reset with no search
    if (_searchingText.isEmpty) {
      foundItems
        ..addAll(notifier
            .getData()
            .whereType<T>()
            .where((e) => e.shouldShowWhenStarting()))
        ..sort();
    } else {
      foundItems
        ..addAll(everyThingCopy)
        ..sort((a, b) => scoreMap[b]!.compareTo(scoreMap[a]!));
    }
    _foundToWidget();
  }

  //Default widgets
  List<Widget> getScreenWidgets() {
    return searches.values.map((e) => e.displayWidget).toList()
      ..add(smallBlankSplit)
      ..add(searchBut)
      ..addAll(_list);
  }

  void _foundToWidget() {
    _list.clear();
    if (notifier.getData().whereType<T>().isEmpty) {
      _list.add(const Center(child: Text('No items')));
      return;
    }
    List<Widget> toFill = [];
    if (foundItems.isNotEmpty) {
      if (_searchingText.isNotEmpty) {
        toFill.add(smallBlankSplit);
        //you searched for X
        toFill.add(BlagendaUniformButton(
            usedColors.last, () => _searchingText, fullSearchReset));

        toFill.add(bigSplitterTextField);
        //fill all found items
        if (foundItems.first is EndBasedController) {
          DateRange range = searches[SearchTypes.date]!.getValue();
          _buttonDateSearchFill(range, toFill);
        } else {
          _defaultShow(toFill);
        }
      } else if (foundItems.isNotEmpty) {
        _noSearchButSuggestions(toFill);
      }
    }
    _list
      ..clear()
      ..addAll(toFill);

    notifyListeners();
  }

  void _defaultShow(List<Widget> toFill) {
    for (var item in foundItems) {
      toFill.add(smallBlankSplit);
      toFill.add(
          BlagendaUniformButton(item.displayColor(), item.searchDisplay, () {
        _doActionWithClickedItem(item).then((value) {
          if (true == value) {
            notifier.delete(item);
          } else if (false == value) {
            notifier.addOrUpdate(item);
          }
          resetSearch();
        });
      }));
    }
  }

  void _buttonDateSearchFill(DateRange range, List<Widget> toFill) {
    if (range.weekdays.isNotEmpty) {
      for (int i = 0; i <= range.range; i++) {
        var tempController = MyDateController.today.add(Duration(days: i * 7));
        for (var weekday in range.weekdays) {
          var superTempController = tempController
              .add(Duration(days: weekday - MyDateController.today.weekday));
          toFill.addAll(createDayThingy(superTempController));
        }
      }
    } else {
      if (range.range == -1) {
        foundItems.sort((SearchAble a, SearchAble b) {
          if (a is! EndBasedController || b is! EndBasedController) {
            return -1;
          }
          return a.daysLeft.compareTo(b.daysLeft);
        });
        int lastFromNow = -10;
        for (var item in foundItems.whereType<EndBasedController>()) {
          if (lastFromNow == item.daysLeft) {
            continue;
          }
          lastFromNow = item.daysLeft;
          var tempController =
              MyDateController.today.add(Duration(days: lastFromNow));
          toFill.addAll(createDayThingy(tempController));
        }
      } else {
        //fill with days you selected
        for (int i = range.myDateFromNow;
            i <= range.myDateFromNow + range.range;
            i++) {
          var tempController = MyDateController.today.add(Duration(days: i));
          toFill.addAll(createDayThingy(tempController));
        }
      }
    }
  }

  void _noSearchButSuggestions(List<Widget> toFill) {
    toFill.add(bigSplitterTextField);
    toFill.add(
        BlagendaUniformButton(usedColors.last, () => 'Suggestions', () {}));
    toFill.add(bigSplitterTextField);
    for (var item in foundItems) {
      toFill.add(smallBlankSplit);
      toFill.add(
          BlagendaUniformButton(item.displayColor(), item.searchDisplay, () {
        _doActionWithClickedItem(item).then((value) {
          if (true == value) {
            notifier.delete(item);
            resetSearch();
          }
        });
      }));
    }
  }

  List<Widget> createDayThingy(MyDateController tempDate) {
    return createADay(
        MyDateController.today,
        notifier.getData().whereType<EndBasedController>().toList(),
        tempDate.daysLeftUntil(),
        (item, _) => BlagendaUniformButton(
                item.displayColor(),
                () =>
                    item.searchDisplay() +
                    (foundItems.any((e) =>
                            item.id == e.id &&
                            item.runtimeType == e.runtimeType)
                        ? '\n\n----'
                        : ''), () {
              _doActionWithClickedItem(item as T).then((value) {
                if (true == value) {
                  notifier.delete(item as T);
                } else if (false == value) {
                  notifier.addOrUpdate(item as T);
                }
                resetSearch();
              });
            }),
        false,
        false);
  }

  void fullSearchReset() {
    for (var item in searches.values) {
      item.resetInput();
    }
    resetSearch();
  }
}
