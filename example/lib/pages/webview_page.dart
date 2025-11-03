import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String? title;
  final bool enableJavaScript;
  final bool supportZoom;
  final bool displayNavigationControls;

  const WebViewPage({
    super.key,
    required this.url,
    this.title,
    this.enableJavaScript = true,
    this.supportZoom = true,
    this.displayNavigationControls = true,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  final ValueNotifier<String?> _pageTitle = ValueNotifier(null);

  @override
  void initState() {
    super.initState();

    // 初始化WebViewController
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(widget.enableJavaScript ? JavaScriptMode.unrestricted : JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // 获取页面标题
            _controller.getTitle().then((title) {
              _pageTitle.value = title;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = '加载失败: ${error.description}';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // 可以在这里拦截特定URL
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));



    // 为Android设置额外选项
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder<String?>(
            valueListenable: _pageTitle,
            builder: (context, title, child) {
              return Text(
                widget.title ?? title ?? '网页浏览',
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          actions: [
            // 刷新按钮
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _controller.reload();
              },
            ),
            // 打开外部浏览器按钮
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () {
                Get.back(result: {
                  'action': 'open_externally',
                  'url': widget.url,
                });
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // WebView主体
            WebViewWidget(controller: _controller),

            // 加载指示器
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            // 错误提示
            if (_errorMessage != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _controller.reload();
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
          ],
        ),
    );
  }
}
