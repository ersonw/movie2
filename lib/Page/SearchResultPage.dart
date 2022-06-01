import 'package:flutter/cupertino.dart';
import 'package:movie2/tools/Request.dart';

class SearchResultPage extends StatefulWidget {
  String id;
  SearchResultPage(this.id ,{Key? key}) : super(key: key);
  @override
  _SearchResultPage createState() => _SearchResultPage();
}
class _SearchResultPage extends State<SearchResultPage>{
  int page = 1;
  int total = 1;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container();
  }
  @override
  void deactivate() {
    Request.searchMovieCancel(widget.id).then((value) => super.deactivate());
  }
}