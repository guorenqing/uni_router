/// 路由类型枚举
enum RouteType {
  page, // 页面跳转（Flutter页面、WebView页面等）
  actionSync, // 同步功能调用（无异步操作）
  actionAsync, // 异步功能调用（有异步操作）
}

enum NavigationType {
  none, //非页面类型
  push, // 推入导航栈
  modal, // 模态展示
  replaceCurrent, // 替换当前页面
  replaceAll, // 替换所有页面
}
