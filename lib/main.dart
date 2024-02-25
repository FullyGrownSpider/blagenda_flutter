import 'package:blagenda_flutter_simple/Screens/observation_screen.dart';
import 'package:blagenda_flutter_simple/common_items.dart';
import 'package:flutter/material.dart';

import 'Loading/mix_loading.dart';

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
    with SingleTickerProviderStateMixin, loading {
  OverviewScreen overviewScreen = const OverviewScreen();

  @override
  void initState() {
    super.initState();
    syncAction = syncData;

    syncActionLowKey = syncDataLowKey;
  }

  bool done = true; //false for sync possiblity true for testing mode

  void syncData() {
    setState(() {
      done = false;
    });
    downloadDatabaseFiles().then((x) {
      setState(() {
        done = true;
      });
    });
  }

  void syncDataLowKey(setState) {
    downloadDatabaseFilesCarefully().then((x) {
      if (x) {
        setState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: done ? overviewScreen : loadingScreen(),
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
                background: Colors.white24,
                surface: Colors.green,
                onBackground: Colors.white24,
                brightness: Brightness.dark)));
  }
}

//working
Widget loadingScreen() {
  return Container(
      color: Colors.white24,
      child: Column(children: <Widget>[
        const Spacer(),
        Image.asset('icons/logo_full.png'),
        const Spacer(),
      ]));
}
