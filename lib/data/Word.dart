import 'dart:convert';

class Word {
  Word();
  int id = 0;
  String text = '';
  Word.fromJson(Map<String, dynamic> json):
      id = json['id'],
  text = json['text'];
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
  };
  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode(toJson());
  }
}