import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:flutter/material.dart';

abstract class BasicButtonController<t extends BasicButton> {
  static const int maxValueCheck = 38;
  t _button;

  int gettingTheStringLongLength = 1;

  BasicButtonController(this._button) {
    gettingTheStringLongLength = gettingTheStringSelected().length;
  }

  t get button => _button;

  @protected
  set button(t newButton) => _button = newButton;

  String get job => _button.job!;

  List<String> get toDos => _button.toDos!;

  int get id => _button.id!;

  static String displayGenericJob(String job, int max) =>
      job.length > max ? '${job.substring(0, max)}...' : job;

  Color get color => _button.color!;

  String gettingTheStringShort() => displayGenericJob(job, maxValueCheck);

  String gettingTheStringSelected() =>
      gettingTheStringShort() + todosToString();

  String todosToString() {
    StringBuffer buf = StringBuffer();
    for (int i = 0; i < toDos.length; i++) {
      if (toDos[i].isEmpty && i == 0) continue;
      buf.write('\n');
      if (toDos[i].length < _maxLengthTodos) {
        buf.write(toDos[i]);
      } else {
        buf.write(splitByLength(toDos[i]));
      }
    }
    if (buf.toString().trim().isEmpty) {
      buf.clear();
      buf.write(writeEmpty());
    }
    return buf.toString();
  }

  String writeEmpty() => "\n${emogjiList[job.hashCode % emogjiList.length]}";

  bool colorCheck(Color c) => color.value == c.value;

  static String splitByLength(String input) {
    StringBuffer buf = StringBuffer();
    var data = input.split(' ');
    bool firstWord = true;
    int sentenceLength = 0;
    for (int i = 0; i < data.length; i++) {
      if (data[i].contains('\n')) {
        firstWord = true;
        sentenceLength = 0;
        buf.write(data[i]);
      } else if (firstWord) {
        if (data[i].length > _maxLengthTodos) {
          //tried to add the word but its the first word of a sentence and
          //longer than the max
          buf.write('${data[i].substring(0, _maxLengthTodos - 3)}...');
          buf.write('${data[i]}\n');
        } else {
          //add item to todos string
          buf.write(data[i]);
          sentenceLength = data[i].length;
          firstWord = false;
        }
      } else {
        if (data[i].length + sentenceLength < _maxLengthTodos) {
          //add it to the sentence
          buf.write(' ${data[i]}');
          sentenceLength += data[i].length + 1;
        } else {
          buf.write('\n');
          i--;
          firstWord = true;
          sentenceLength = 0;
        }
      }
    }
    // [substring(0, _maxLengthTodos), substring(_maxLengthTodos)]
    return buf.toString();
  }
}

const _maxLengthTodos = 50;

const List<String> emogjiList = [
  "🐕",
  "🐅",
  "🐆",
  "🐎",
  "🦓",
  "🐪",
  "🐫",
  "🦙",
  "🦒",
  "🐘",
  "🦏",
  "🐁",
  "🐀",
  "🐇",
  "🐿",
  "🦔",
  "🦇",
  "🐓",
  "🐦",
  "🐧",
  "🦆",
  "🦉",
  "🦜",
  "🐢",
  "🦎",
  "🐍",
  "🦕",
  "🦖",
  "🐋",
  "🐬",
  "🐟",
  "🐠",
  "🦀",
  "🦞",
  "🦐",
  "🐌",
  "🦋",
  "🐛",
  "🐜",
  "🐝",
  "🐞",
  "🦗",
  "🕷",
  "🕸",
  "🦂",
  "🦟",
  "🦠",
  "🔮",
  "🧿",
  "🧩",
  "♠",
  "♥",
  "♦",
  "♣",
  "♟",
  "🃏",
  "🖼",
  "🎨",
  "🧵",
  "🧶",
  "🏵",
  "🌻",
  "🌼",
  "🌷",
  "🌲",
  "🌳",
  "🌴",
  "🌵",
  "🍀",
  "🍁",
  "💎",
  "🔍",
  "🕯",
  "💡",
  "📕",
  "📖",
  "📗",
  "📘",
  "📙",
  "📄",
  "📦",
  "📂",
];
