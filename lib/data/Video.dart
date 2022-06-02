import 'dart:convert';

class Video {
  int id = 0;
  String title = '';
  String vodContent = '';
  String picThumb = '';
  int vodDuration = 0;
  int price = 0;
  int plays = 0;
  int likes = 0;

  Video();

  Video.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        vodContent = json["content"],
        picThumb = json["pic_thumb"],
        price = json["price"],
        plays = json["plays"],
        likes = json["likes"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'vodContent': vodContent,
        'picThumb': picThumb,
        'price': price,
        'plays': plays,
        'likes': likes,
      };

  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode(toJson());
  }
}
