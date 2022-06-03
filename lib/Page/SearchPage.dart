
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:movie2/AssetsIcon.dart';
import 'package:movie2/Global.dart';
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
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late  TabController _innerTabController;
  bool alive = true;
  final _tabKey = const ValueKey('tab');
  int tabIndex = 0;

  List<String> _records = generalModel.words;
  List<Word> _words = [];
  List<Word> _hotMonth = [];
  List<Word> _hotYear = [];

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
    return Scaffold(
      backgroundColor: const Color(0xff181921),
      body: ListView(
        children: _buildList(),
      ),
    );
  }
   _search()async{
    _focusNode.unfocus();
    generalModel.updateWords(_textEditingController.text);
    Map<String, dynamic> result = await Request.searchMovie(_textEditingController.text);
    if(result != null && result['id'] != null){
      Navigator.push(context, SlideRightRoute(page: SearchResultPage(result['id'])));
    }
  }
  _buildList(){
    List<Widget> widgets = [];
    widgets.add(const Padding(padding: EdgeInsets.only(top: 10)));
    widgets.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          // color: Colors.red,
          // height: 45,
          width: ((MediaQuery.of(context).size.width) / 1.2),
          child: Container(
            margin: const EdgeInsets.only(left: 15),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Row(
                children: [
                  const Padding(padding: EdgeInsets.only(left: 20,)),
                  Center(child: Image.asset(AssetsIcon.searchTag,height: 15,),),
                  Flexible(
                    child: TextField(
                      focusNode: _focusNode,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      controller: _textEditingController,
                      autofocus: true,
                      // style: TextStyle(color: Colors.white38),
                      onEditingComplete: () {
                        _search();
                      },
                      // onSubmitted: (String text) {
                      //   _search();
                      // },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: '搜索您喜欢的内容',
                        hintStyle: TextStyle(color: Colors.white30,fontSize: 13,fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.only(top: 10,bottom: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                ]
            ),
          ),
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
    ));
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
          _textEditingController.text = _records[index];
          _search();
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
          _textEditingController.text = _words[index].words;
          _search();
        }
      }));
    }
    widgets.add(const Padding(padding: EdgeInsets.only(top: 20)));
    widgets.add(
      Container(
        color: Colors.transparent,
        height: MediaQuery.of(context).size.height / 2,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: _innerTabController,
                    labelStyle: const TextStyle(fontSize: 18),
                    unselectedLabelStyle: const TextStyle(fontSize: 15),
                    padding: const EdgeInsets.only(right: 0),
                    indicatorPadding: const EdgeInsets.only(right: 0),
                    labelColor: Colors.white,
                    labelPadding: const EdgeInsets.only(left: 0, right: 0),
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    indicator: const RoundUnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 3,
                          color: Colors.deepOrangeAccent,
                        )),
                    tabs: [
                      Text('当月热搜榜'),
                      Text('年度热搜榜'),
                    ],
                  ),
                  Expanded(
                      child: TabBarView(
                        controller: _innerTabController,
                        children: [
                          _buildHotList(_hotMonth),
                          _buildHotList(_hotYear),
                        ],
                      )),
                ],
              ),
            ),
          ],
        )
      )
    );
    return widgets;
  }
  _buildHotList(List<Word> list){
    List<Widget> widgets = [];
    for(int i=0;i< list.length;i++){
      if(i==0){
        widgets.add(
          InkWell(
            onTap: (){
              _textEditingController.text = list[i].words;
              _search();
            },
            child: Container(
              margin: const EdgeInsets.only(left: 20,top: 20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('1',style: TextStyle(color: Colors.deepOrange,fontSize: 18,fontWeight: FontWeight.bold),),
                    const Padding(padding: EdgeInsets.only(left: 20)),
                    Text(list[i].words,style: TextStyle(fontSize: 15),),
                  ]
              ),
            ),
          )
        );
      }
      if(i==1){
        widgets.add(
            InkWell(
              onTap: (){
                _textEditingController.text = list[i].words;
                _search();
              },
              child: Container(
                margin: const EdgeInsets.only(left: 20,top: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('2',style: TextStyle(color: Colors.orangeAccent,fontSize: 18,fontWeight: FontWeight.bold),),
                      const Padding(padding: EdgeInsets.only(left: 20)),
                      Text(list[i].words,style: TextStyle(fontSize: 15),),
                    ]
                ),
              ),
            )

        );
      }
      if(i==2){
        widgets.add(
            InkWell(
              onTap: (){
                _textEditingController.text = list[i].words;
                _search();
              },
              child: Container(
                margin: const EdgeInsets.only(left: 20,top: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('3',style: TextStyle(color: Colors.blue,fontSize: 18,fontWeight: FontWeight.bold),),
                      const Padding(padding: EdgeInsets.only(left: 20)),
                      Text(list[i].words,style: TextStyle(fontSize: 15),),
                    ]
                ),
              ),
            )

        );
      }
      if(i>2){
        widgets.add(
            InkWell(
              onTap: (){
                _textEditingController.text = list[i].words;
                _search();
              },
              child: Container(
                margin: const EdgeInsets.only(left: 20,top: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('${i+1}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      const Padding(padding: EdgeInsets.only(left: 20)),
                      Text(list[i].words,style: TextStyle(fontSize: 15),),
                    ]
                ),
              ),
            )

        );
      }
    }
    return ListView(
      children: widgets,
    );
  }
  @override
  void dispose() {
    alive = false;
    _innerTabController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }
}