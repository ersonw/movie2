import 'dart:convert';

import 'package:movie2/data/Config.dart';
import 'package:movie2/data/User.dart';


class Profile {
  Profile();
  List<String> words = [];
  Config config = Config();
  User user = User();
  Profile.fromJson(Map<String, dynamic> json):
      config = Config.formJson(json['config']),
  user = User.formJson(json['user']),
  words = (json['words'] as List).map((e) => e.toString()).toList();

  Map<String, dynamic> toJson() => {
    'config': config,
    'user': user,
    'words' : words,
  };
  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode(toJson());
  }
}
