import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movie2/tools/CustomDialog.dart';
import 'package:movie2/tools/RequestApi.dart';
import '../Global.dart';
import 'Loading.dart';
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
      // contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      receiveDataWhenStatusError: false,
      connectTimeout: 30000,
      receiveTimeout: 3000,
    );
  }

  static Future<String?> _get(String path,Map<String, dynamic> params)async{
    // if(Global.initMain == true) Loading.show(Global.mainContext);
    try{
      Response response = await _dio.get(path,queryParameters: params, options: Options(
        headers: {
          'Token': userModel.hasToken() ? userModel.user.token : '',
          "Content-Type": "application/x-www-form-urlencoded",
        },
        responseType: ResponseType.json,
        receiveDataWhenStatusError: false,
        receiveTimeout: 3000,
      ));
      Loading.dismiss();
      if(response.statusCode == 200 && response.data != null){
        // print(response.data);
        Map<String, dynamic> data = response.data;
        if(data['message'] != null) CustomDialog.message(data['message']);
        if(data['code'] == 200 && data['data'] != null){
          return data['data'];
        }
      }
    } on DioError catch(e) {
      Loading.dismiss();
      print(e.message);
      // if(e.response == null) {
      //   CustomDialog.message(e.message);
      // } else if(e.response.statusCode == 105){
      //   CustomDialog.message('未登录');
      // }else if(e.response.statusCode == 106){
      //   CustomDialog.message('登录已失效');
      // }else{
      //   CustomDialog.message(e.response.statusMessage);
      // }
    }
  }
  static Future<String?> _post(String path,Map<String, dynamic> data)async{
    // if(Global.initMain == true) Loading.show(Global.mainContext);
    try{
      Response response = await _dio.post(path,data: data, options: Options(
        headers: {
          // "Content-Type": "application/json",
          'Token': userModel.hasToken() ? userModel.user.token : '',
        },
        responseType: ResponseType.json,
        receiveDataWhenStatusError: false,
        receiveTimeout: 3000,
      ));
      Loading.dismiss();
      if(response.statusCode == 200 && response.data != null){
        Map<String, dynamic> data = response.data;
        if(data['message'] != null) CustomDialog.message(data['message']);
        if(data['code'] == 200 && data['data'] != null){
          return data['data'];
        }
      }
    } on DioError catch(e) {
      Loading.dismiss();
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

  static Future<void> checkDeviceId()async{
    String? result = await _get(RequestApi.checkDeviceId.replaceAll('{deviceId}', Global.deviceId!),{});
    if(result!=null){
      Map<String, dynamic> map = jsonDecode(result);
      if(map['token'] != null) {
        userModel.setToken(map['token']);
      }
    }
  }
  static Future<bool> userLogin(String username, String password)async{
    Loading.show();
    String deviceId = Global.deviceId ?? 'unknown';
    String platform = Global.platform ?? 'Html5';
    Map<String, dynamic> data = {
      "deviceId": deviceId,
      "platform": platform,
      "username": username,
      "password": Global.generateMd5(password),
    };
    String? result = await _post(RequestApi.userLogin, data);
    if(result!=null){
      Map<String, dynamic> map = jsonDecode(result);
      if(map['token'] != null) {
        userModel.setToken(map['token']);
        return true;
      }
    }
    return false;
  }
  static Future<String?> userRegisterSms(String phone)async{
    Loading.show();
    String? result = await _get(RequestApi.userRegisterSms.replaceAll('{phone}', phone),{});

    if(result!=null){
      Map<String, dynamic> map = jsonDecode(result);
      if(map['id'] != null) return map['id'];
    }
    return null;
  }
  static Future<bool> userRegister(String password,String codeId,String code)async{
    // String deviceId = Global.deviceId ?? 'unknown';
    // String platform = Global.platform ?? 'Html5';
    Loading.show();
    Map<String, dynamic> data = {
      // "deviceId": deviceId,
      // "platform": platform,
      "password": Global.generateMd5(password),
      "codeId": codeId,
      "code": code
    };
    String? result = await _post(RequestApi.userRegister, data);

    return result != null;
  }
  static Future<void> test()async{
    String? result = await _get(RequestApi.test.replaceAll('{text}', 'replace'), {'token': 'token'});
    if(result!=null){
      print(result);
    }
  }
  static Future<Map<String, dynamic>> searchLabelAnytime({bool showLoading=false})async{
    if(showLoading) Loading.show();
    String? result = await _get(RequestApi.searchLabelAnytime, {});

    if(result != null){
      return jsonDecode(result);
    }
    return Map<String, dynamic>();
  }
  static Future<Map<String, dynamic>> searchLabelHot()async{
    // Loading.show(Global.mainContext);
    String? result = await _get(RequestApi.searchLabelHot, {});
    // Loading.dismiss(Global.mainContext);
    if(result != null){
      return jsonDecode(result);
    }
    return Map<String, dynamic>();
  }
  static Future<Map<String, dynamic>> searchMovie(String text)async{
    Loading.show();
    String? result = await _get(RequestApi.searchMovie.replaceAll('{text}', text), {});
    if(result != null){
      return jsonDecode(result);
    }
    return Map<String, dynamic>();
  }
  static Future<Map<String, dynamic>> searchResult(String id, {int page=1, bool showLoading=false})async{
    if(showLoading) Loading.show();
    String? result = await _get(RequestApi.searchResult.replaceAll('{page}', '$page').replaceAll('{id}', id), {});

    if(result != null){
      return jsonDecode(result);
    }
    return Map<String, dynamic>();
  }
  static Future<void> searchMovieCancel(String id)async{
   await _get(RequestApi.searchMovieCancel.replaceAll('{id}', id), {});
  }
}