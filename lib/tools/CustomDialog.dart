import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Global.dart';

typedef ClickCallbackBool = void Function(bool action);
class CustomDialog {
  static Future<void> message(String text,{String? title, ClickCallbackBool? callback, bool left = false})async{
    showCupertinoDialog<void>(
        context: Global.mainContext,
        builder: (_context) {
          return CupertinoAlertDialog(
            title: Text(title ?? "提示信息"),
            content: Text(text,textAlign: left ? TextAlign.left : TextAlign.center,),
            actions: callback == null ? [
              CupertinoDialogAction(
                  child: const Text("确定"),
                  onPressed: () {
                    Navigator.of(_context).pop();
                    callback!(true);
                  })
            ] : [
              CupertinoDialogAction(
                  child: const Text("取消"),
                  onPressed: () {
                    Navigator.of(_context).pop();
                    callback(false);
                  }),
              CupertinoDialogAction(
                  child: const Text("确定"),
                  onPressed: () {
                    Navigator.of(_context).pop();
                    callback(true);
                  }),

            ],
          );
        });
  }
}