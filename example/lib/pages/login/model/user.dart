class User {
  final String id;
  final String email;
  final String name;
  User({
    required this.id,
    required this.email,
    required this.name,
  });

  // 转换为JSON，用于存储
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name
    };
  }

  // 从JSON创建User实例
  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name']
    );
  }
}
