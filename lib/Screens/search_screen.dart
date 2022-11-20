import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/basic_button_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ButtonControllers/end_based_controller.dart';
import 'package:blagenda_flutter_simple/Controllers/ScreensControllers/search_screen_controller.dart';
import 'package:flutter/material.dart';

import 'adding_screen.dart';

class SearchScreen extends StatefulWidget {
  final int Function(Type) getNewId;

  const SearchScreen(this.addOrUpdateButton, this.getNewId, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchScreenState();

  final Function(BasicButtonController) addOrUpdateButton;
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchScreenController _controller = SearchScreenController(_setStateMethod, _openEdit);

  @override
  Widget build(BuildContext context) {
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
            children: _controller.getFilling(),
          ),
        ));
  }

  void _openEdit(EndBasedController it){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddingScreen(
                it, widget.addOrUpdateButton, widget.getNewId)))
        .then((v) => Navigator.pop(context));
  }
  void _setStateMethod() {
    if (!mounted) return;
    setState(() {});
  }
}
