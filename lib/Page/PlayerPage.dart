import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie2/Module/GeneralRefresh.dart';
import 'package:movie2/data/Player.dart';
import 'package:movie2/tools/Request.dart';
import 'package:movie2/tools/VideoPlayerUtils.dart';
import 'package:movie2/tools/widget/LockIcon.dart';
import 'package:movie2/tools/widget/VideoPlayerBottom.dart';
import 'package:movie2/tools/widget/VideoPlayerGestures.dart';
import 'package:movie2/tools/widget/VideoPlayerTop.dart';
import '../tools/TempValue.dart';
import 'dart:ui';
import '../Global.dart';

class PlayerPage extends StatefulWidget {
  int id;

  PlayerPage(this.id, {Key? key}) : super(key: key);

  @override
  _PlayerPage createState() => _PlayerPage();
}

class _PlayerPage extends State<PlayerPage> {
  // 是否全屏
  bool get _isFullScreen =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  Size get _window => MediaQueryData.fromWindow(window).size;

  double get _width => _isFullScreen ? _window.width : _window.width;

  double get _height => _isFullScreen ? _window.height : _window.width * 9 / 16;
  Widget? _playerUI;
  VideoPlayerTop? _top;
  VideoPlayerBottom? _bottom;
  LockIcon? _lockIcon; // 控制是否沉浸式的widget

  final ScrollController _controller = ScrollController();
  bool refresh = true;

  // Widget? _playerUI;
  Player player = Player();

  @override
  void initState() {
    getPlayer();
    super.initState();
  }

  getPlayer() async {
    Map<String, dynamic> map = await Request.videoPlayer(widget.id);
    setState(() {
      refresh = false;
    });
    if (map['error'] != null) {
      if (map['error'] == 'login')
        Global.loginPage().then((value) => getPlayer());
      return;
    }
    if (map['player'] != null) {
      setState(() {
        player = Player.formJson(map['player']);
      });
      // print(player.vodPlayUrl);
      VideoPlayerUtils.playerHandle(player.vodPlayUrl!);
      // 播放新视频，初始化监听
      VideoPlayerUtils.initializedListener(
          key: this,
          listener: (initialize, widget) {
            if (initialize) {
              // 初始化成功后，更新UI
              _top ??= VideoPlayerTop(
                title: player.title,
              );
              _lockIcon ??= LockIcon(
                lockCallback: () {
                  _top!.opacityCallback(!TempValue.isLocked);
                  _bottom!.opacityCallback(!TempValue.isLocked);
                },
              );
              _bottom ??= VideoPlayerBottom();
              _playerUI = widget;
              if (!mounted) return;
              setState(() {});
            }
          });
      VideoPlayerUtils.positionListener(key: this, listener: (int second){
        if(second > 30 && VideoPlayerUtils.state == VideoPlayerState.playing){
          VideoPlayerUtils.lock();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeneralRefresh(
        controller: _controller,
        onRefresh: () {
          setState(() {
            refresh = true;
          });
          getPlayer();
        },
        header: Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: (){
                  //
                },
                child: Icon(Icons.chevron_left_outlined),
              ),
            ],
          ),
        ),
        body: _isFullScreen
            ? safeAreaPlayerUI()
            : Column(
                children: [
                  safeAreaPlayerUI(),
                  // const SizedBox(height: 100,),
                  // InkWell(
                  //   // 切换视频
                  //   onTap: () {},
                  //   child: Container(
                  //     alignment: Alignment.center,
                  //     width: 120, height: 60,
                  //     color: Colors.orangeAccent,
                  //     child: const Text("切换视频",style: TextStyle(fontSize: 18),),
                  //   ),
                  // )
                ],
              ),
        refresh: refresh,
    );
  }

  Widget safeAreaPlayerUI() {
    return SafeArea(
      // 全屏的安全区域
      top: !_isFullScreen,
      bottom: !_isFullScreen,
      left: !_isFullScreen,
      right: !_isFullScreen,
      child: SizedBox(
          height: _height,
          width: _width,
          child: _playerUI != null
              ? VideoPlayerGestures(
                  appearCallback: (appear) {
                    _top!.opacityCallback(appear);
                    _lockIcon!.opacityCallback(appear);
                    _bottom!.opacityCallback(appear);
                  },
                  children: [
                    Center(
                      child: _playerUI,
                    ),
                    _isFullScreen ? _top! : Container(),
                    _lockIcon!,
                    _bottom!
                  ],
                )
              : Container(
                  alignment: Alignment.center,
                  // color: Colors.black26,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(player.picThumb ?? ''),
                    ),
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                )),
    );
  }

  @override
  void dispose() {
    VideoPlayerUtils.playerHandle(player.vodPlayUrl!);
    VideoPlayerUtils.removeInitializedListener(this);
    VideoPlayerUtils.removePositionListener(this);
    VideoPlayerUtils.removeStatusListener(this);
    // VideoPlayerUtils.dispose();
    super.dispose();
  }
}
