import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';
import 'dart:convert';

class UserManager extends GetxService {
  static UserManager get to => Get.find();

  final _currentUser = Rxn<User>();
  final _isLoggedIn = false.obs;
  final _hasCreatedStudent = false.obs;

  User? get currentUser => _currentUser.value;
  bool get isLoggedIn => _isLoggedIn.value;
  bool get hasCreatedStudent => _hasCreatedStudent.value;

  // 初始化，检查是否已登录
  Future<UserManager> init() async {
    await _loadUserFromStorage();
    return this;
  }

  // 检查登录状态
  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    
    if (userJson != null) {
      Map<String, dynamic> jsonData = jsonDecode(userJson);
      _currentUser.value = User.fromJson(jsonData);
      _isLoggedIn.value = true;
    }
  }

  // 登录
  Future<void> login(User user) async {
    _currentUser.value = user;
    _isLoggedIn.value = true;
    
    // 保存用户信息到本地存储
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  // 登出
  Future<void> logout() async {
    _currentUser.value = null;
    _isLoggedIn.value = false;
    
    // 清除本地存储的用户信息
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  // 创建学员
  void createStudent() {
    _hasCreatedStudent.value = true;
  }
}
