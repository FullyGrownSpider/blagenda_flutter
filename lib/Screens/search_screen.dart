import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/search_screen_controller.dart';
import 'package:flutter/material.dart';

import '../Controllers/ObjectControllers/mix_search_able.dart';
import '../Loading/mix_loading.dart';

class SearchScreen<T extends SearchAble> extends StatefulWidget {
  final int Function(Type) getNewId;
  final List<T> listToUse;
  final bool closeOnAction;
  final Future<T> Function(T) _reAdd;

  const SearchScreen(
      this.doWithClicked, this.getNewId, this.listToUse, this.closeOnAction, this._reAdd,
      {super.key});

  @override
  State<StatefulWidget> createState() => _SearchScreenState<T>();

  final Future<dynamic> Function(SearchAble) doWithClicked;
}

class _SearchScreenState<T extends SearchAble> extends State<SearchScreen<T>>
    with loading {
  late final SearchScreenController _controller = SearchScreenController<T>(
      setStateMethod,
      widget.closeOnAction
          ? (s) {
              var page = widget.doWithClicked(s);
              pop();
              return page;
            }
          : widget.doWithClicked,
      widget.listToUse,
      widget._reAdd);

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
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(10.0),
            child: AppBar(
              backgroundColor: Colors.green,
            )),
        body: SingleChildScrollView(
          // child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _controller.getScreenWidgets(),
          ),
        ));
  }

  void setStateMethod() {
    setState(() {});
  }
}
