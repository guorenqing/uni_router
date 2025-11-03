import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app_router/flutter_app_router.dart';

class FlutterRouterTestPage extends StatelessWidget {
  const FlutterRouterTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter router 测试')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // 跳转到详情页
                final result = await AppRouter().navigate('/detail', params: {'id': '123'});
                if (result.isSuccess) {
                  Get.rawSnackbar(message: '从详情页返回: ${result.data}');
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('打开详情页'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 打开WebView(内部调用)
                AppRouter().navigate('/webview', params: {
                  'url': 'https://flutter.dev',
                  'title': 'Flutter官网',
                  'enableJavaScript': true,
                  'supportZoom': true,
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('打开内部WebView'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 打开系统浏览器
                AppRouter().navigate('/system_web', params: {
                  'url': 'https://dart.dev'
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('系统浏览器打开网页'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // 调用分享功能
                final result = await AppRouter().navigate('/share', params: {
                  'content': '这是一个分享测试内容'
                });
                if (result.isSuccess) {
                  Get.rawSnackbar(message: '分享结果: ${result.data}');
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('调用分享功能'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // 显示弹窗
                final result = await AppRouter().navigate('/alert', params: {
                  'title': '测试弹窗',
                  'message': '这是一个测试弹窗，点击确定或取消',
                  'cancelTitle': '取消'
                });
                Get.rawSnackbar(message: '弹窗返回结果: ${result.data}');
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('显示弹窗'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: ()async {
                // 显示Toast
                final result = await AppRouter().navigate('/toast', params: {
                  'title': '这是一个Toast标题',
                  'message': '这是一个Toast内容'
                });
                print("=======$result");
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('显示Toast'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 测试Scheme格式的WebView调用
                final testUrl = 'myapp://webview?url=https%3A%2F%2Fflutter.dev%3Ftitle%3D网页标题%26page%3D1&title=客户端标题&enableJavaScript=true&supportZoom=false&displayNavigationControls=true';
                AppRouter().handleScheme(testUrl);
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('测试Scheme调用WebView'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 测试Scheme格式的WebView调用
                final testUrl = 'myapp://detail?id=123';
                AppRouter().handleScheme(testUrl);
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('测试Scheme调用原生页面'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // 测试Scheme格式的WebView调用
                final testUrl = 'myapp://system_web?url=https%3A%2F%2Fflutter.dev%3Ftitle%3D网页标题%26page%3D1';
                final result = await AppRouter().handleScheme(testUrl);
                print("=======$result");
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('测试Scheme调用系统浏览器页面'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // 测试Scheme格式的alert调用
                final testUrl = 'myapp://alert?title=弹窗标题11111111111111111111111111111111111111111&message1=弹窗内容222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222&cancelTitle=确认按钮';
                final result = await AppRouter().handleScheme(testUrl);
                print("=======$result");
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('测试Scheme格式的alert调用'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // 调用原生方法
                final result = await AppRouter().navigate('/native', params: {
                  'path': '/showToast',
                  'params': {'message': '这是原生Toast'}
                });
                Get.rawSnackbar(message: '原生调用结果: ${result.data}');
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('调用原生方法'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
