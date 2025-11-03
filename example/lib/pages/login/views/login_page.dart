import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/login_controller.dart';
import '../services/user_manager.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginController controller = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // 标题
              const Text(
                "欢迎回来",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "请登录你的账号",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // 登录表单
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 邮箱输入框
                    TextFormField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "邮箱",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "请输入邮箱";
                        }
                        if (!GetUtils.isEmail(value)) {
                          return "请输入有效的邮箱地址";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 密码输入框
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.obscureText.value,
                        decoration: InputDecoration(
                          labelText: "密码",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureText.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              controller.obscureText.value =
                                  !controller.obscureText.value;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "请输入密码";
                          }
                          if (value.length < 6) {
                            return "密码长度不能少于6位";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 忘记密码
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed('/forgot-password');
                        },
                        child: const Text("忘记密码?"),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 登录按钮
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  // 隐藏键盘
                                  FocusScope.of(context).unfocus();
                                  // 执行登录
                                  bool success = await controller.login();
                                  if (success) {
                                    Get.back();
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "登录",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 分割线
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("或使用以下方式登录"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 32),
              
              // 第三方登录
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.ac_unit_sharp),
                    onPressed: () async {
                      // 谷歌登录逻辑
                      Get.back();
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: Icon(Icons.ac_unit_sharp),
                    onPressed: () async {
                      // 脸书登录逻辑
                      controller.handleFacebookLogin();
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // 注册提示
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("还没有账号?"),
                  TextButton(
                    onPressed: () {
                      Get.toNamed('/register');
                    },
                    child: const Text(
                      "立即注册",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
