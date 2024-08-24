import 'dart:io';

import 'package:blagenda_flutter_simple/Loading/button_notifier.dart';
import 'package:blagenda_flutter_simple/Loading/entity_notifier.dart';
import 'package:blagenda_flutter_simple/ScreensPhone/observation_screen.dart';
import 'package:flutter/material.dart';

import 'ScreensBigger/overview_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TabBarInsideAppBarPage());
}

class TabBarInsideAppBarPage extends StatefulWidget {
  const TabBarInsideAppBarPage({super.key});

  @override
  State<TabBarInsideAppBarPage> createState() => _TabBarInsideAppBarPageState();
}

class _TabBarInsideAppBarPageState extends State<TabBarInsideAppBarPage>
    with SingleTickerProviderStateMixin {
  final EntityNotifier entityNotifier = EntityNotifier();
  late final ButtonNotifier buttonNotifier = ButtonNotifier(entityNotifier);

  @override
  void initState() {
    super.initState();
    entityNotifier.init();
    buttonNotifier.init();
  }

  bool done = true; //false for sync possiblity true for testing mode

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isPhone() ? OverviewScreen(buttonNotifier, entityNotifier) : DesktopOverviewScreen(buttonNotifier, entityNotifier),
        title: 'Blagenda',
        theme: ThemeData(
            canvasColor: Colors.green[800],
            fontFamily: 'JetbrainsMonoNL',
            colorScheme: const ColorScheme.dark(
                primary: Colors.green,
                onPrimary: Colors.black,
                onSecondary: Colors.black,
                onSurface: Colors.black,
                secondary: Colors.green,
                surface: Colors.green,
                brightness: Brightness.dark)));
  }
}



bool isPhone(){
  return Platform.isAndroid || Platform.isIOS;
}
