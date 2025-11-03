import 'package:flutter/services.dart';

class NativeMethodChannel {
  static const MethodChannel _channel = MethodChannel('com.example/native');

  /// 调用原生方法
  static Future<dynamic> invokeMethod(String method, [dynamic arguments]) async {
    try {
      return await _channel.invokeMethod(method, arguments);
    } on PlatformException catch (e) {
      throw "原生方法调用失败: ${e.message}";
    }
  }
}