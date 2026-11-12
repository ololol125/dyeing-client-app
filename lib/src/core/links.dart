import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'messages.dart';

// 개인정보처리방침·이용약관 등 웹 페이지를 앱 안 브라우저로 연다
Future<void> openWebPage(BuildContext context, String url) async {
  final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
  if (!opened && context.mounted) {
    showAppMessage(context, '페이지를 열 수 없어요. 인터넷 연결을 확인해 주세요.');
  }
}
