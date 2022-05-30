import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class Loading extends StatelessWidget {
  static bool isLoading = false;
  static void show(BuildContext context) {
    isLoading = true;
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (ctx) => Theme(
        data: Theme.of(ctx).copyWith(dialogBackgroundColor: Colors.transparent),
        child: Loading(),
      ),
    );
  }
  static void dismiss(context) {
    if(isLoading){
      isLoading = false;
      Navigator.pop(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          width: 60,
          height: 60,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SpinKitFadingCircle(
                color: Colors.black,
                size: 46.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}