import 'package:get/get.dart';
import '../../login/services/user_manager.dart';

class CreateStudentController extends GetxController {
  // 依赖注入UserManager（无需手动初始化，GetX自动查找）
  final UserManager _userManager = UserManager.to;
  // 可观察变量：用于显示状态提示（如“已创建学员”）
  final RxString statusText = "点击按钮创建学员".obs;

  // 核心方法：创建学员（调用UserManager修改状态）
  Future<bool> createStudent() async {
    await Future.delayed(const Duration(seconds: 2), () {
      _userManager.createStudent();
      statusText.value = "✅ 学员创建成功！";
    });
    return true;
  }
}