import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';

import '../ScreensControllers/common_screen_controller.dart';
import 'basic_button_controller.dart';

class NoteController extends BasicButtonController<BasicButton>
    implements Comparable<NoteController>{
  NoteController(BasicButton button) : super(button);

  @override
  int compareTo(NoteController other) {
    for (var col in usedColors){
      if (col.red == color.red){
        if (col.red == other.color.red){
          return job.compareTo(other.job);
        }
        return -1;
      }
      if (col.red == other.color.red) return 0;
    }
    return 0;
  }
}
