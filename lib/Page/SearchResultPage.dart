import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:movie2/Module/GeneralRefresh.dart';
import 'package:movie2/Module/GeneralVideoList.dart';
import 'package:movie2/data/Video.dart';
import 'package:movie2/tools/CustomRoute.dart';
import 'package:movie2/tools/Request.dart';

import '../AssetsIcon.dart';
import '../Global.dart';

class SearchResultPage extends StatefulWidget {
  String id;
  SearchResultPage(this.id ,{Key? key}) : super(key: key);
  @override
  _SearchResultPage createState() => _SearchResultPage();
}
class _SearchResultPage extends State<SearchResultPage>{
  final ScrollController _controller = ScrollController();
  bool refresh = true;
  int page = 1;
  String text = "";
  int total = 1;
  List<Video> _list = [];
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels ==
          _controller.position.maxScrollExtent) {
        setState(() {
          page++;
        });
        getResult();
      }
    });
    getResult();
  }
  getResult()async{
    if (page > total) {
      page--;
      return;
    }
    Map<String, dynamic> result = await Request.searchResult(widget.id,page: page);
    setState(() {
      refresh = false;
    });
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
    return GeneralRefresh(
      controller: _controller,
      onRefresh: (){
        setState(() {
          refresh = true;
        });
        page = 1;
        total = 1;
        getResult();
      },
      body: buildList(),
      refresh: refresh,
      header: SizedBox(
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
                    width: ((MediaQuery.of(context).size.width) / 1.2),
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
      ),
      footer: Container(
        margin: const EdgeInsets.only(top:30,bottom: 30),
        child: Center(child: total > page ? _getLoading() : (Text(_list.isEmpty ? '找不到搜索结果' : '没有更多了')),),
      ),
    );
  }
  _getLoading(){
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SpinKitFadingCircle(
                color: Colors.white,
                size: 46.0,
              )
            ],
          ),
        ),
      ),
    );
  }
  buildList(){
    List<Widget> widgets = [];
    for (int i = 0; i < _list.length; i++) {
      widgets.add(GeneralVideoList(video: _list[i]));
    }
    return Column(children: widgets,);
  }
  @override
  void deactivate() {
    Request.searchMovieCancel(widget.id).then((value) => super.deactivate());
  }
}