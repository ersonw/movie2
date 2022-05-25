import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:movie2/AssetsIcon.dart';
import 'package:url_launcher/url_launcher.dart';
import'dart:html';
import'dart:js' as js;
import 'Global.dart';
import 'data/SwiperData.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPage createState() => _SearchPage();

}
class _SearchPage extends State<SearchPage>{
  final TextEditingController _textEditingController = TextEditingController();
  List<SwiperData> _swipers = [];
  String _text = '';

  @override
  void initState() {
    SwiperData data = SwiperData();
    data.image = 'https://23porn.oss-cn-hangzhou.aliyuncs.com/c030c05a-5ca4-4ad9-af02-6048ab526010.png';
    data.url = data.image;
    _swipers.add(data);
    data = SwiperData();
    data.image = 'https://23porn.oss-cn-hangzhou.aliyuncs.com/d95661e1-b1d2-4363-b263-ef60b965612d.png';
    data.url = data.image;
    _swipers.add(data);
    if(kIsWeb){
      var uri = Uri.dataFromString(window.location.href);
      var queryParameters = uri.queryParameters;
      if(queryParameters != null){
        if(queryParameters['code'] != null) Global.codeInvite = queryParameters['code'];
        if(queryParameters['channel'] != null) Global.channelCode = queryParameters['channel'];
      }
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181921),
      body: Stack(
        children: [
          ListView(
            children: _buildList(),
          ),
        ],
      ),
    );
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
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      controller: _textEditingController,
                      autofocus: true,
                      // style: TextStyle(color: Colors.white38),
                      onEditingComplete: () {
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: '搜索您喜欢的内容',
                        hintStyle: TextStyle(color: Colors.white30,fontSize: 13,fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.only(top: 14,bottom: 14),
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
    if(_swipers.isNotEmpty) {
      widgets.add(Container(
        // color: Colors.black,
        margin: const EdgeInsets.only(top: 15,bottom: 15,left: 20,right: 20),
        height: 180,
        child: Swiper(
          loop: true,
          autoplay: true,
          itemCount: _swipers.length,
          itemBuilder: _buildSwiper,
          pagination: const SwiperPagination(),
          control: const SwiperControl(color: Colors.white),
        ),
      ));
    }
    widgets.add(
        Container(
          width: ((MediaQuery.of(context).size.width) / 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: (){},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.all(Radius.circular(40)),
                      //   image: DecorationImage(
                      //     image: AssetImage(AssetsIcon.diamondTagBK),
                      //     fit: BoxFit.fill
                      //   ),
                      // ),
                      width: ((MediaQuery.of(context).size.width) / 5),
                      child: Center(
                        child: Image.asset(AssetsIcon.diamondIcon),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    const Center(child: Text('钻石尊享',style: TextStyle(fontSize: 12),),),
                  ],
                ),
              ),
              InkWell(
                onTap: (){},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.all(Radius.circular(40)),
                      //   image: DecorationImage(
                      //     image: AssetImage(AssetsIcon.diamondTagBK),
                      //     fit: BoxFit.fill
                      //   ),
                      // ),
                      width: ((MediaQuery.of(context).size.width) / 5),
                      child: Center(
                        child: Image.asset(AssetsIcon.jingPinIcon),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    const Center(child: Text('精品专区',style: TextStyle(fontSize: 12),),),
                  ],
                ),
              ),
              InkWell(
                onTap: (){},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.all(Radius.circular(40)),
                      //   image: DecorationImage(
                      //     image: AssetImage(AssetsIcon.diamondTagBK),
                      //     fit: BoxFit.fill
                      //   ),
                      // ),
                      width: ((MediaQuery.of(context).size.width) / 5),
                      child: Center(
                        child: Image.asset(AssetsIcon.VIPIcon),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    const Center(child: Text('VIP专区',style: TextStyle(fontSize: 12),),),
                  ],
                ),
              ),
              InkWell(
                onTap: (){},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.all(Radius.circular(40)),
                      //   image: DecorationImage(
                      //     image: AssetImage(AssetsIcon.diamondTagBK),
                      //     fit: BoxFit.fill
                      //   ),
                      // ),
                      width: ((MediaQuery.of(context).size.width) / 5),
                      child: Center(
                        child: Image.asset(AssetsIcon.popularIcon),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    const Center(child: Text('热门榜单',style: TextStyle(fontSize: 12),),),
                  ],
                ),
              ),
            ],
          ),
        )
    );
    return widgets;
  }
  Widget _buildSwiper(BuildContext context, int index) {
    SwiperData _swiper = _swipers[index];
    return InkWell(
      onTap: () {
        _handlerSwiper(_swiper);
      },
      child: Container(
        // height: 120,
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          image: DecorationImage(
            image: NetworkImage(_swiper.image),
            fit: BoxFit.fill,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
  _handlerSwiper(SwiperData data){
    switch(data.type){
      case SwiperData.OPEN_WEB_OUTSIDE:
        launchUrl(Uri.parse(data.url));
        break;
      case SwiperData.OPEN_WEB_INSIDE:
        Global.openWebview(data.url, inline: true);
        break;
    }
  }
}