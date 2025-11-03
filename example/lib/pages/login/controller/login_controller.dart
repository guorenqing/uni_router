import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/user_manager.dart';
import '../model/user.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController(text: "test@qq.com");
  final passwordController = TextEditingController(text: "123456");
  final obscureText = true.obs;
  final isLoading = false.obs;

  // 登录方法
  Future<bool> login() async {
    try {
      isLoading.value = true;
      
      // 模拟API请求延迟
      await Future.delayed(const Duration(seconds: 1));
      
      // 实际项目中这里应该是调用API进行登录验证
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      
      // 简单验证，实际项目中应该替换为API调用
      if (email == "test@qq.com" && password == "123456") {
        // 登录成功，保存用户信息
        await UserManager.to.login(
          User(
            id: "1",
            email: email,
            name: "测试用户",
          ),
        );
        // Get.showSnackbar(
        //   const GetSnackBar(
        //     title: "登录成功",
        //     message: "欢迎回来！",
        //     duration: Duration(seconds: 2),
        //     backgroundColor: Colors.green,
        //   ),
        // );
        return true;
      } else {
        Get.showSnackbar(
          const GetSnackBar(
            title: "登录失败",
            message: "邮箱或密码错误",
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: "登录失败",
          message: e.toString(),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 谷歌登录
  Future<void> handleGoogleLogin() async {
    try {
      isLoading.value = true;
      // 模拟谷歌登录
      await Future.delayed(const Duration(seconds: 1));
      
      // 登录成功，保存用户信息
      await UserManager.to.login(
        User(
          id: "2",
          email: "google@example.com",
          name: "谷歌用户",
        ),
      );
      
      Get.showSnackbar(
        const GetSnackBar(
          title: "登录成功",
          message: "通过谷歌账号登录",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      Get.offNamed('/home');
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: "登录失败",
          message: e.toString(),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 脸书登录
  Future<void> handleFacebookLogin() async {
    try {
      isLoading.value = true;
      // 模拟脸书登录
      await Future.delayed(const Duration(seconds: 1));
      
      // 登录成功，保存用户信息
      await UserManager.to.login(
        User(
          id: "3",
          email: "facebook@example.com",
          name: "脸书用户",
        ),
      );
      
      Get.showSnackbar(
        const GetSnackBar(
          title: "登录成功",
          message: "通过脸书账号登录",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      Get.offNamed('/home');
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: "登录失败",
          message: e.toString(),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
