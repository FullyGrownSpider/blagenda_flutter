import 'package:flutter/cupertino.dart';

import '../Controllers/ScreensControllers/search_screen_controller.dart';

Widget search(ChangeNotifier notifier, SearchScreenController controller) {
  return ListenableBuilder(
      listenable: notifier,
      builder: (BuildContext context, Widget? child) {
        controller.fullSearchReset();
        return ListenableBuilder(
            listenable: controller,
            builder: (BuildContext context, Widget? child) {
              // controller.fullSearchReset();
              return SingleChildScrollView(
                  // child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: controller.getScreenWidgets()));
            });
      });
}
