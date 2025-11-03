/// 路由结果封装类
class RouteResult {
  final bool isSuccess;
  final String? message;
  final dynamic data;
  RouteResult({required this.isSuccess, this.message, this.data});

  // 成功结果
  factory RouteResult.success({dynamic data}) {
    return RouteResult(isSuccess: true, data: data);
  }

  // 失败结果
  factory RouteResult.failure(String message) {
    return RouteResult(isSuccess: false, message: message);
  }
}
