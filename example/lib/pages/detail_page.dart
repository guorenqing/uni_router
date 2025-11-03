import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailPage extends StatelessWidget {
  final String id;

  const DetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    String uid = Get.arguments['uid'];
    return Scaffold(
      appBar: AppBar(title: const Text('详情页')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('详情ID: $id, uid=$uid', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 返回上一页并携带数据
                Get.back(result: {'status': 'ok', 'data': '来自详情页的数据'});
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
