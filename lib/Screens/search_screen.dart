import 'package:blagenda_flutter_simple/Commons/store_able.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/search_screen_controller.dart';
import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:flutter/material.dart';

import '../Controllers/ObjectControllers/mix_search_able.dart';

class SearchScreen<T extends SearchAble> extends StatefulWidget {
  final StoreAbleNotifier<StoreAble> notifier;
  final Future<dynamic> Function(SearchAble) doWithClicked;

  const SearchScreen(this.doWithClicked, this.notifier, {super.key});

  @override
  State<StatefulWidget> createState() => _SearchScreenState<T>();
}

class _SearchScreenState<T extends SearchAble> extends State<SearchScreen<T>> {
  late final SearchScreenController _controller = SearchScreenController<T>(
      (s) {
    var page = widget.doWithClicked(s);
    return page;
  }, widget.notifier.getData().whereType<T>().toList(),
      widget.notifier.addOrUpdate);

  BuildContext? _currentContext;

  void pop() {
    if (mounted && _currentContext != null) {
      Navigator.pop(_currentContext!);
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentContext = context;
    return Scaffold(
        backgroundColor: Colors.white24,
        appBar: AppBar(title: const Text('Search')),
        body: ListenableBuilder(
            listenable: _controller,
            builder: (BuildContext context, Widget? child) =>
                SingleChildScrollView(
                    // child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _controller.getScreenWidgets(),
                ))));
  }
}
