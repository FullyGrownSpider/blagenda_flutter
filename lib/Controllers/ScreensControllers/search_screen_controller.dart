import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter/material.dart';

import '../ObjectControllers/mix_search_able.dart';
import '../blagenda_uniform_button.dart';
import 'mix_day_creator.dart';
import 'mix_input_handler.dart.dart';

class SearchScreenController<T extends SearchAble>
    with DayCreator, SearchField {
  ///needs to be sorted
  final List<T> _everything;

  String _searchingText = '';
  final Future<dynamic> Function(T) _doActionWithClickedItem;
  @visibleForTesting
  final Map<SearchTypes, InputObject> searches = {};
  @visibleForTesting
  final List<T> foundItems = [];
  final ValueNotifier<List<Widget>> list = ValueNotifier([]);
  DateRange date = const DateRange(0, -1);
  final void Function(T) _reAdd;

  SearchScreenController(
      this._doActionWithClickedItem, this._everything, this._reAdd) {
    Set searchesSet = {};
    for (var e in _everything) {
      searchesSet.addAll(e.possibleSearches());
    }
    for (var key in searchesSet) {
      if (key == SearchTypes.date) {
        searches[key] = dateFinder(onConfirmed, () => date, (s) => date = s);
      } else if (key == SearchTypes.string) {
        searches[key] = stringFinder(onConfirmed);
      } else if (key == SearchTypes.tag) {
        searches[key] = tagFinder(onConfirmed);
      }
    }
    resetSearch();
  }

  static const TextStyle styleDays =
      TextStyle(fontSize: 20.0, height: 2.5, color: Colors.green);

  void onConfirmed() {
    //submitted by pressing enter in the input things
    resetSearch();
  }

  void resetSearch() {
    if (_everything.isEmpty) {
      _searchingText = 'no items';
      return;
    }
    _searchingText = '';
    foundItems.clear();
    Map<T, int> scoreMap = {};
    List<int> notScored = [];
    if (searches.containsKey(SearchTypes.date)) {
      var data = searches[SearchTypes.date]!.getValue() as DateRange;
      searches[SearchTypes.date]!.setValue(searches[SearchTypes.date]!);
      if (data.range > -1) {
        var from = MyDateController.fromDaysFromNow(data.myDateFromNow);
        if (data.range == 0) {
          _searchingText =
              'On ${from.stringFullDisplayWithCal(from.year == MyDateController.today.year)}';
        } else {
          _searchingText =
              '${from.stringFullDisplayWithCal(from.year == MyDateController.today.year)} to ${MyDateController.fromDaysFromNow(data.myDateFromNow + data.range).stringFullDisplayWithCal(from.year == MyDateController.today.year)}';
        }
        for (int i = 0; i < _everything.length; i++) {
          var score = _everything[i].searchHere(SearchTypes.date, data);
          scoreMap[_everything[i]] = score;
          if (score == 0) notScored.add(i);
        }
      }
    }
    if (searches.containsKey(SearchTypes.string)) {
      var data = searches[SearchTypes.string]!.getValue() as String;
      searches[SearchTypes.string]!.setValue(searches[SearchTypes.string]!);
      if (data.isNotEmpty) {
        if (_searchingText.isNotEmpty) _searchingText += '\n and \n';
        _searchingText += data;
        for (int i = 0; i < _everything.length; i++) {
          if (notScored.contains(i)) continue;
          var score = _everything[i].searchHere(SearchTypes.string, data);
          scoreMap[_everything[i]] = score;
          if (score == 0) notScored.add(i);
        }
      }
    }
    if (searches.containsKey(SearchTypes.tag)) {
      var data = searches[SearchTypes.tag]!.getValue() as List<String>;
      if (data.first.isNotEmpty || data.last.isNotEmpty) {
        if (_searchingText.isNotEmpty) _searchingText += '\n and \n';
        _searchingText += '${data[0]} - ${data[1]}';
        for (int i = 0; i < _everything.length; i++) {
          if (notScored.contains(i)) continue;
          var score = _everything[i].searchHere(SearchTypes.tag, data);
          scoreMap[_everything[i]] = score;
          if (score == 0) notScored.add(i);
        }
      }
    }
    if (notScored.length == _everything.length || scoreMap.isEmpty) {
      foundItems.addAll(_everything.where((e) => e.shouldShowWhenStarting()));
      foundItems.sort();
      return;
    }
    for (int i = 0; i < _everything.length; i++) {
      if (notScored.contains(i)) continue;
      foundItems.add(_everything[i]);
    }
    foundItems.sort((a, b) => scoreMap[b]!.compareTo(scoreMap[a]!));
  }

  //Default widgets
  List<Widget> getScreenWidgets() {
    return searches.values.map((e) => e.displayWidget).toList()
      ..addAll(list.value);
  }

  void setScreenSearch() {
    if (_everything.isEmpty) {
      list.value = [const Center(child: Text('No items'))];
      return;
    }
    List<Widget> toFill = [];
    for (var item in searches.values) {
      toFill.add(item.displayWidget);
    }
    toFill.add(smallBlankSplit);
    toFill.add(
        BlagendaUniformButton(usedColors.last, () => 'Search', resetSearch));
    if (_searchingText.isNotEmpty) {
      toFill.add(smallBlankSplit);
      //you searched for X
      toFill.add(BlagendaUniformButton(
          usedColors.last, () => _searchingText, fullSearchReset));

      toFill.add(bigSplitterTextField);
      //fill all found items
      for (var item in foundItems) {
        toFill.add(smallBlankSplit);
        toFill.add(BlagendaUniformButton(
            item.displayColor(),
            item.searchDisplay,
            () => _doActionWithClickedItem(item).then((value) {
                  //if (null) is possible with if (value)
                  if (true == value) {
                    _everything.remove(item);
                    resetSearch();
                  } else if (false == value) {
                    _everything.remove(item);
                    _reAdd(item);
                    resetSearch();
                  }
                })));
      }
    } else if (foundItems.isNotEmpty) {
      toFill.add(bigSplitterTextField);
      toFill.add(
          BlagendaUniformButton(usedColors.last, () => 'Suggestions', () {}));
      toFill.add(bigSplitterTextField);
      for (var item in foundItems) {
        toFill.add(smallBlankSplit);
        toFill.add(BlagendaUniformButton(
            item.displayColor(),
            item.searchDisplay,
            () => _doActionWithClickedItem(item).then((value) {
                  //if (null) is possible with if (value)
                  if (true == value) {
                    _everything.remove(item);
                    resetSearch();
                  }
                })));
      }
    }
    list.value = toFill;
  }

  void fullSearchReset() {
    for (var item in searches.values) {
      item.setValue(null);
    }
    resetSearch();
  }
}
