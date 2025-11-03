import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app_router/flutter_app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // 跳转到详情页
                AppRouter().navigate('/flutter_router_test');
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('flutter router 测试页面'),
              ),
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}
