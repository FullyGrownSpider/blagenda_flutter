import 'package:flutter/material.dart';

import '../../Commons/store_able.dart';

abstract class SearchAble extends StoreAble {
  String searchDisplay();

  List<SearchTypes> possibleSearches();

  int searchHere(SearchTypes searchType, dynamic value);

  Color displayColor();

  bool shouldShowWhenStarting();
}

enum SearchTypes { string, date, tag }
