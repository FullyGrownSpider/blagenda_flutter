import 'dart:ui';

import 'package:blagenda_flutter_simple/Controllers/my_date_controller.dart';

import 'basic_button.dart';

class Deadline extends BasicButton {
  Deadline([String? job, List<String>? toDos, int? id, Color? color, this.date])
      : super(job, toDos, id, color);

  MyDateController? date;
}
