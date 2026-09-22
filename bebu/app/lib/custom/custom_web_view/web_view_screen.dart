import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String screen;

  const WebViewScreen({super.key, required this.url, required this.screen});

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  WebViewController? controller;
  bool isLoading = true; // State to track loading status

  @override
  void initState() {
    super.initState();
    Utils.showLog("urlWebVie::::::::::::::::::::${widget.url}");
    Utils.showLog("screen::::::::::::::::::::${widget.screen}");
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..loadRequest(Uri.parse(widget.url))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true; // Show loader when page starts loading
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false; // Hide loader when page finishes loading
            });
          },
        ),
      );
  }

  @override
  void dispose() {
    controller?.clearLocalStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: WebViewAppBar(
          title: widget.screen,
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: WebViewWidget(
              controller: controller!,
            ),
          ),
          if (isLoading)
            Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: AppColors.appColor,
                size: 50,
              ),
            ),
        ],
      ),
    );
  }
}

class WebViewAppBar extends StatelessWidget {
  final String? title;
  const WebViewAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        // iconColor: AppColors.black,
        title: title,
        showLeadingIcon: true,
      ),
    );
  }
}
