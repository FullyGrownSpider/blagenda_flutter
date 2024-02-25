import 'package:flutter/material.dart';

import '../../store_able.dart';

class BasicButton extends StoreAble {
  BasicButton([this.job, this.toDos, super.id, this.color, this.important = false]);

  Color? color;
  String? job;
  String? toDos;

  ///weather it should be shown in the "important" sidebar
  bool important;
}
