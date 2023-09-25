import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';

import '../ScreensControllers/common_screen_controller.dart';
import 'basic_button_controller.dart';

class NoteController extends BasicButtonController<BasicButton>
    implements Comparable<NoteController> {
  NoteController(BasicButton button) : super(button);

  @override
  int compareTo(NoteController other) {
    for (var col in usedColors) {
      if (col.red == color.red &&
          col.green == color.green &&
          col.blue == color.blue) {
        if (col.red == other.color.red &&
            col.green == other.color.green &&
            col.blue == other.color.blue) {
          return job.compareTo(other.job);
        }
        return -1;
      }
      if (col.red == other.color.red &&
          col.green == other.color.green &&
          col.blue == other.color.blue) {
        return 1;
      }
    }
    return 0;
  }
}
