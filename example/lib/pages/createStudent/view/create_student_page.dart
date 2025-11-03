import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/create_student_controller.dart';

class CreateStudentPage extends StatelessWidget {
  // 初始化Controller（Get.put：首次进入页面时创建，后续复用）
  final CreateStudentController _controller = Get.put(CreateStudentController());

  CreateStudentPage({super.key});

  // 自定义返回按钮触发的方法
  void _handleBack() {
    // 这里可以添加需要执行的逻辑
    print("返回按钮被点击");

    // 执行完自定义逻辑后返回上一页
    // 如果需要阻止返回，可以不调用Get.back()
    Get.back(result: 'back');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("创建学员"),
        centerTitle: true
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 状态提示文本（监听Controller的可观察变量）
            Obx(
                  () => Text(
                _controller.statusText.value,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            // 创建学员按钮
            ElevatedButton(
              onPressed: () async {
                bool success = await _controller.createStudent();
                if (success) {
                  Get.back();
                }
              }, // 调用Controller方法
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text("创建学员"),
            ),
          ],
        ),
      ),
    );
  }
}