import 'package:flutter/material.dart';

class BasicButton {
  BasicButton([this.job, this.toDos, this.id, this.color, this.important = false]);

  int? id;
  Color? color;
  String? job;
  List<String>? toDos;
  bool important;
}
