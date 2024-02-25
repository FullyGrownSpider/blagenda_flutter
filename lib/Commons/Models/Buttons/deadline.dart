import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';

import 'basic_button.dart';

class Deadline extends BasicButton {
  Deadline([super.job, super.toDos, super.id, super.color, this.date, super.important]);

  MyDateController? date;
}
