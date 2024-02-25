import 'dart:math';

import 'package:blagenda_flutter_simple/Commons/Models/Buttons/basic_button.dart';
import 'package:flutter/material.dart';

import '../../../Loading/conversion_base.dart';
import '../../ObjectControllers/mix_search_able.dart';
import '../../ScreensControllers/mix_input_handler.dart.dart';

abstract class BasicButtonController<t extends BasicButton> extends SearchAble
    with searchField {
  ///if this was edited but is also used if it was deleted while coming from the edit screen
  bool touched = false;

  static const String entityIndicator = '◟';
  static const int maxValueCheck = 38;
  t _button;

  int theStringLongestLength = 1;

  BasicButtonController(this._button) {
    calculateLength();
  }

  t get button => _button;

  @protected
  set button(t newButton) => _button = newButton;

  String get job => _button.job!;

  bool get important => _button.important;

  String get toDos => _button.toDos!;

  int get id => _button.id!;

  int entitied = -1;

  String displayGenericText(String job, int max) => splitByLength(job, max);

  Color get color => _button.color!;

  String gettingTheStringShort() =>
      (entitied != -1 ? entityIndicator : '') + splitByLength(job, maxValueCheck);

  String gettingTheStringSelected() =>
      '${gettingTheStringShortSplit()}\n\n${todosToString()}';

  String gettingTheStringShortSplit() {
    return splitByLength(job, maxValueCheck);
  }

  String writeEmpty() => emogjiList[job.hashCode % emogjiList.length];

  bool colorCheck(Color c) => color.value == c.value;

  void flipImportant() {
    _button.important = !_button.important;
  }

  static String splitByLength(String input, int maxLengthTodos) {
    if (input.length < maxLengthTodos) return input;
    StringBuffer buf = StringBuffer();
    var blimputs = input.split('\n');
    for (var blimput in blimputs) {
      var data = blimput.split(' ');
      bool firstWord = true;
      int sentenceLength = 0;
      for (int i = 0; i < data.length; i++) {
        if (data[i].contains('\n')) {
          firstWord = true;
          sentenceLength = 0;
          buf.write(data[i]);
        } else if (firstWord) {
          if (data[i].length > maxLengthTodos) {
            //tried to add the word but its the first word of a sentence and
            //longer than the max
            maxLengthTodos -= 3;
            int size = 0;
            while (size + maxLengthTodos < data[i].length) {
              buf.write('${data[i].substring(size, size + maxLengthTodos)}...\n');
              size += maxLengthTodos;
            }
            buf.write('${data[i].substring(size, data[i].length)} ');
            maxLengthTodos += 3;
          } else {
            //add item to todos string
            buf.write('${data[i]} ');
            sentenceLength = data[i].length;
            firstWord = false;
          }
        } else {
          if (data[i].length + sentenceLength < maxLengthTodos) {
            //add it to the sentence
            buf.write('${data[i]} ');
            sentenceLength += data[i].length + 1;
          } else {
            buf.write('\n');
            i--;
            firstWord = true;
            sentenceLength = 0;
          }
        }
      }
      buf.write('\n');
    }
    return buf.toString().replaceAll(' \n', '\n').trim();
  }

  void calculateLength() {
    theStringLongestLength = min(job.length, maxValueCheck);
    for (var todo in toDos.split('\n')) {
      if (todo.length > theStringLongestLength) {
        theStringLongestLength = todo.length;
      }
    }
  }

  @override
  List<SearchTypes> possibleSearches() {
    return [SearchTypes.string];
  }

  @override
  int searchHere(SearchTypes searchType, dynamic value) {
    if (searchType == SearchTypes.string) {
      return (job.toLowerCase().contains(value) ? 9 : 0) +
          (toDos.toLowerCase().contains(value) ? 1 : 0);
    }
    return 0;
  }

  @override
  Color displayColor() => color;

  @override
  String searchDisplay() => gettingTheStringShort();

  String todosToString() {
    if (toDos.trim().isEmpty) return writeEmpty();
    return splitByLength(toDos, maxValueCheck);
  }

  @override
  bool shouldShowWhenStarting() {
    return touched;
  }

  static bool equals(dynamic b1, dynamic b2) =>
      b1 is BasicButton &&
      b1.runtimeType == b2.runtimeType &&
      exportGenerator(b1) == exportGenerator(b2);
}

const List<String> emogjiList = [
  '(❁´◡`❁)',
  '╰(*°▽°*)╯',
  '(┬┬﹏┬┬)',
  'ᓚᘏᗢ',
  'ಥ_ಥ',
  '^_^',
  '(￣y▽￣)╭ Ohohoho.....',
  '(❁´◡`❁)',
  '(〃￣︶￣)人(￣︶￣〃)',
  '(((o(*ﾟ▽ﾟ*)o)))',
  '(￣o￣) . z Z',
  'd=====(￣▽￣*)b',
  '👈(⌒▽⌒)👉',
  '👈(ﾟヮﾟ👈)(👉ﾟヮﾟ)👉',
  '( •_•)>⌐■-■ -> (⌐■_■)',
  '(̯̿ ̿)',
  '( ﾉ ﾟｰﾟ)ﾉ(^人^)',
  '(❤️´艸｀❤️)',
  '(⓿_⓿)',
  '✍️(◔◡◔)',
  '༼ つ ◕_◕ ༽つ',
  'ฅʕ•̫͡•ʔฅ',
  '(◉Θ◉)',
  '(^◕.◕^)',
  '( ͡• ͜ʖ ͡• )',
  '≡(▔﹏▔)≡',
  '⊙﹏⊙∥',
  '〒▽〒',
  '(≧﹏ ≦)',
  'ಥ_ಥ',
  '(。﹏。*)',
  '(╬▔皿▔)╯',
  '（︶^︶）',
  '( ˘︹˘ )',
  '(⊙ˍ⊙)',
  '🐕',
  '🐅',
  '🐆',
  '🐎',
  '🦓',
  '🐪',
  '🐫',
  '🦙',
  '🦒',
  '🐘',
  '🦏',
  '🐁',
  '🐀',
  '🐇',
  '🐿',
  '🦔',
  '🦇',
  '🐓',
  '🐦',
  '🐧',
  '🦆',
  '🦉',
  '🦜',
  '🐢',
  '🦎',
  '🐍',
  '🦕',
  '🦖',
  '🐋',
  '🐬',
  '🐟',
  '🐠',
  '🦀',
  '🦞',
  '🦐',
  '🐌',
  '🦋',
  '🐛',
  '🐜',
  '🐝',
  '🐞',
  '🦗',
  '🕷',
  '🦂',
  '🦟',
  '🧩',
  '♠',
  '♥',
  '♦',
  '♣',
  '♟',
  '🖼',
  '🏵',
  '🌻',
  '🌼',
  '🌷',
  '🌲',
  '🌳',
  '🌴',
  '🌵',
  '🍀',
  '🍁',
  '💎',
  '🔍',
  '🕯',
  '💡',
  '📄',
  '📦',
];
