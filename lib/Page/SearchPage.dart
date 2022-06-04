
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:movie2/AssetsIcon.dart';
import 'package:movie2/Global.dart';
import 'package:movie2/Module/GeneralRefresh.dart';
import 'package:movie2/Module/InputSearch.dart';
import 'package:movie2/Module/LeftTabBarView.dart';
import 'package:movie2/Module/Top3List.dart';
import 'package:movie2/Page/SearchResultPage.dart';
import 'package:movie2/data/Word.dart';
import 'package:movie2/tools/CustomDialog.dart';
import 'package:movie2/tools/CustomRoute.dart';
import 'package:movie2/tools/Request.dart';
import 'package:url_launcher/url_launcher.dart';
import '../tools/RoundUnderlineTabIndicator.dart';
import '../Style/ListStyle.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPage createState() => _SearchPage();

}
class _SearchPage extends State<SearchPage> with SingleTickerProviderStateMixin{
  late  TabController _innerTabController;
  bool alive = true;
  final _tabKey = const ValueKey('tab');
  int tabIndex = 0;

  List<String> _records = generalModel.words;
  List<Word> _words = [];
  List<Word> _hotMonth = [];
  List<Word> _hotYear = [];
  String text = '';

  @override
  void initState() {
    // Request.test();
    init();
    change(showLoading: false);
    generalModel.addListener(() {
      if(alive){
        setState(() {
          _records = generalModel.words;
        });
      }
    });
    int initialIndex = PageStorage.of(context)?.readState(context, identifier: _tabKey);
    _innerTabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: initialIndex != null ? initialIndex : tabIndex);
    _innerTabController.addListener(handleTabChange);
    super.initState();
  }
  init()async{
    // change();
    Map<String, dynamic> map = await Request.searchLabelHot();
    // print(map);
    if(map != null && map['month'] != null){
      setState(() {
        _hotMonth = (map['month'] as List).map((e) =>Word.fromJson(e)).toList();
        // _hotMonth = _hotMonth.reversed.toList();
      });
    }
    if(map != null && map['year'] != null) {
      setState(() {
        _hotYear = (map['year'] as List).map((e) =>Word.fromJson(e)).toList();
        // _hotYear = _hotYear.reversed.toList();
      });
    }
  }
  change({bool showLoading=true})async{
    Map<String, dynamic> map = await Request.searchLabelAnytime(showLoading: showLoading);
    // print(map);
    if(map != null && map['list'] != null) {
      setState(() {
        _words = (map['list'] as List).map((e) => Word.fromJson(e)).toList();
        // _words = _words.reversed.toList();
      });
    }
  }
  void handleTabChange() {
    tabIndex = _innerTabController.index;
    PageStorage.of(context)?.writeState(context, _innerTabController.index, identifier: _tabKey);
  }
  @override
  Widget build(BuildContext context) {
    return GeneralRefresh(controller: ScrollController(), onRefresh: (){},
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InputSearch(
              text: text,
              callback: (String value){
                _search(value);
              },
            ),
            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10,),
                child: Text('取消'),
              ),
            ),
          ],
        ),
        body: _buildList(),
        refresh: false);
  }
   _search(String text)async{
    this.text = text;
    generalModel.updateWords(text);
    Map<String, dynamic> result = await Request.searchMovie(text);
    if(result != null && result['id'] != null){
      Navigator.push(context, SlideRightRoute(page: SearchResultPage(result['id'])));
    }
  }
  _buildList(){
    List<Widget> widgets = [];
    if(_records.isNotEmpty) {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              // color: Colors.black,
              margin: const EdgeInsets.all(20),
              alignment: Alignment.centerLeft,
              // height: 180,
              child: Text('历史记录'),
            ),
            InkWell(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Center(child: Image.asset(AssetsIcon.clearIcon),),
              ),
              onTap: (){
                CustomDialog.message('确定要清除所有搜索记录吗？', callback: (bool value){
                  if(value){
                    generalModel.clearWords();
                  }
                });
              },
            ),
          ],
        )
      );
      widgets.add(ListStyle.buildHorizontalList(_records, callback: (int index){
        if(index < _records.length){
          _search(_records[index]);
        }
      }));
    }
    if(_words.isNotEmpty) {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              // color: Colors.black,
              margin: const EdgeInsets.all(20),
              alignment: Alignment.centerLeft,
              // height: 180,
              child: Text('热门标签'),
            ),
            InkWell(
              child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Center(child: Image.asset(AssetsIcon.refreshIcon),),
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      Text('换一换'),
                    ],
                  ),
              ),
              onTap: (){
                change();
              },
            ),
          ],
        )
      );
      widgets.add(ListStyle.buildPhalanxList(_words, MediaQuery.of(context).size.width, callback: (int index){
      // widgets.add(ListStyle.buildPhalanxList(_words, callback: (int index){
        if(index < _words.length){
          _search(_words[index].words);
        }
      }));
    }
    widgets.add(const Padding(padding: EdgeInsets.only(top: 20)));
    widgets.add(
      LeftTabBarView(
          controller: _innerTabController,
          tabs: [
            Text('当月热搜榜'),
            Text('年度热搜榜'),
          ],
          children: [
            _buildHotList(_hotMonth),
            _buildHotList(_hotYear),
          ]
      )
    );
    return Column(
      children: widgets,
    );
  }
  _buildHotList(List<Word> list){
    List<Widget> widgets = [];
    for(int i=0;i< list.length;i++){
      widgets.add(Text(list[i].words,style: const TextStyle(fontSize: 15),));
    }
    return Top3List(
      children: widgets,
      callback: (int index){
        _search(list[index].words);
      },
    );
  }
  @override
  void dispose() {
    alive = false;
    _innerTabController.dispose();
    super.dispose();
  }
}