import 'dart:convert';


class Profile {
  Profile();

  Profile.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() => {};
  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode(toJson());
  }
}
