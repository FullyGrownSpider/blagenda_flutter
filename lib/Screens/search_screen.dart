import 'package:blagenda_flutter_simple/Commons/store_able.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/search_screen_controller.dart';
import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:flutter/material.dart';

import '../Controllers/ObjectControllers/mix_search_able.dart';

class SearchScreen<T extends SearchAble> extends StatefulWidget {
  final StoreAbleNotifier<StoreAble> notifier;
  final Future<dynamic> Function(T)? doWithClicked;
  final bool closeOnClickDone;

  const SearchScreen(this.doWithClicked, this.notifier, this.closeOnClickDone,
      {super.key});

  @override
  State<StatefulWidget> createState() => _SearchScreenState<T>();
}

class _SearchScreenState<T extends SearchAble> extends State<SearchScreen<T>> {
  late final SearchScreenController _controller = SearchScreenController<T>(
      doPopLogic,
      widget.notifier as StoreAbleNotifier<SearchAble>);

  Future<dynamic> doPopLogic(T item) async {
    if (widget.doWithClicked != null) {
      return widget.doWithClicked!(item).then((v) {
        if (widget.closeOnClickDone) {
          if (mounted && _currentContext != null) {
            Navigator.pop(_currentContext!, item);
          }
        }
      });
    } else if (widget.closeOnClickDone) {
      if (mounted && _currentContext != null) {
        Navigator.pop(_currentContext!, item);
      }
    }
  }

  BuildContext? _currentContext;

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
