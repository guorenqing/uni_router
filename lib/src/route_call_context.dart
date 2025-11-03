import 'route_types.dart';

/// 请求上下文
class RouteCallContext {
  final String id;
  final String path;
  final Map<String, dynamic> params;
  final NavigationType navigationType;
  final DateTime createdAt;

  RouteCallContext({
    required this.id,
    required this.path,
    required this.params,
    required this.navigationType,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'RouteCallContext{id: $id, path: $path, params: $params}';
  }
}
