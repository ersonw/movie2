import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie2/data/Video.dart';
import 'package:movie2/tools/CustomRoute.dart';
import 'package:movie2/tools/Request.dart';

import '../AssetsIcon.dart';

class SearchResultPage extends StatefulWidget {
  String id;
  SearchResultPage(this.id ,{Key? key}) : super(key: key);
  @override
  _SearchResultPage createState() => _SearchResultPage();
}
class _SearchResultPage extends State<SearchResultPage>{
  late Timer _timer;
  int page = 1;
  String text = "";
  int total = 1;
  List<Video> _list = [];
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _timer.cancel();
      getResult();
    });
  }
  getResult({bool showLoading = true})async{
    if (page > total) {
      return;
    }
    Map<String, dynamic> result = await Request.searchResult(widget.id,page: page, showLoading: showLoading);
    // print(result);
    if(result != null){
      if (result['total'] != null) total = result['total'];
      if (result['text'] != null) text = result['text'];
      if (result['list'] != null){
        List<Video> list = (result['list'] as List).map((e) => Video.fromJson(e)).toList();
        if(page == 1 || _list.isEmpty){
          setState(() {
            _list = list;
          });
        }else{
          setState(() {
            _list.addAll(list);
          });
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181921),
      body: ListView(
        children: _buildList(),
      ),
    );
  }
  _buildList(){
    List<Widget> widgets = [];
    widgets.add(SizedBox(
      // color: Colors.red,
      // height: 45,
      width: ((MediaQuery.of(context).size.width) / 1),
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Row(
            children: [
              const Padding(padding: EdgeInsets.only(left: 20,)),
              Center(child: Image.asset(AssetsIcon.searchTag,height: 15,),),
              InkWell(
                child: Container(
                  width: ((MediaQuery.of(context).size.width) / 1.1),
                  margin: const EdgeInsets.only(top: 10,bottom: 10),
                  alignment: Alignment.center,
                  child: Text(text,style:  TextStyle(fontSize: 13,color: Colors.grey.withOpacity(0.6)),),
                ),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
            ]
        ),
      ),
    ));
    // widgets.add(buildList());
    return widgets;
  }
  buildList(){
    List<Widget> widgets = [];
    for (int i = 0; i < _list.length; i++) {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_list[i].picThumb)),
              ),
            ),
          ],
        )
      );
    }
    return Column(children: widgets,);
  }
  @override
  void deactivate() {
    Request.searchMovieCancel(widget.id).then((value) => super.deactivate());
  }
}