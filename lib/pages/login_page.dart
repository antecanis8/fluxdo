import 'package:flutter/widgets.dart';

import 'webview_login_page.dart';

/// 最小登录入口：直接使用站点原生 WebView 登录页。
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebViewLoginPage();
  }
}
