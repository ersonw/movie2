import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movie2/tools/CustomDialog.dart';
import 'package:movie2/tools/RequestApi.dart';
import '../Global.dart';
class Request {
  static late Dio _dio;
  static init() {
    _dio = Dio(_getOptions());
    configModel.addListener(() {
      _dio.options.baseUrl = _getDomain();
    });
    userModel.addListener(() {
      _dio.options.headers['Token'] = userModel.hasToken() ? userModel.user.token : '';
    });
  }
  static _getDomain(){
    String domain = configModel.config.mainDomain;
    if(!domain.startsWith("http")){
      domain = 'http://$domain';
    }
    return domain;
  }
  static _getOptions(){
    /// 自定义Header
    Map<String, dynamic> httpHeaders = {
      'Token': userModel.hasToken() ? userModel.user.token : '',
    };
    return BaseOptions(
      baseUrl: _getDomain(),
      headers: httpHeaders,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      receiveDataWhenStatusError: false,
      connectTimeout: 30000,
      receiveTimeout: 3000,
    );
  }

  static Future<String?> _get(String path,Map<String, dynamic> params)async{
    try{
      Response response = await _dio.get(path,queryParameters: params);
      if(response.statusCode == 200 && response.data != null){
        Map<String, dynamic> data = response.data;
        if(data['code'] == 200){
          return data['data'];
        }else{
          if(data['message'] != null) CustomDialog.message(data['message']);
        }
      }
    } on DioError catch(e) {
      print(e);
      if(e.response == null) {
        CustomDialog.message(e.message);
      } else if(e.response.statusCode == 105){
        CustomDialog.message('未登录');
      }else if(e.response.statusCode == 106){
        CustomDialog.message('登录已失效');
      }else{
        CustomDialog.message(e.response.statusMessage);
      }
    }
  }
  static Future<String?> _post(String path,String data)async{
    try{
      Response response = await _dio.post(path,data: data);
      if(response.statusCode == 200 && response.data != null){
        Map<String, dynamic> data = jsonDecode(response.data);
        if(data['code'] == 200){
          return data['data'];
        }else{
          if(data['message'] != null) CustomDialog.message(data['message']);
        }
      }
    } on DioError catch(e) {
      if(e.response == null) {
        CustomDialog.message(e.message);
      } else if(e.response.statusCode == 105){
        CustomDialog.message('未登录');
      }else if(e.response.statusCode == 106){
        CustomDialog.message('登录已失效');
      }else{
        CustomDialog.message(e.response.statusMessage);
      }
    }
  }

  static Future<void> test()async{
    String? result = await _get(RequestApi.test.replaceAll('{text}', 'replace'), {'token': 'token'});
    if(result==null){
      print(result);
    }
  }
}