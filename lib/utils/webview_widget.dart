import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewWidget extends StatefulWidget {
  final String url;

  const WebviewWidget({required this.url});

  @override
  State<WebviewWidget> createState() => _WebviewWidgetState();
}

class _WebviewWidgetState extends State<WebviewWidget> {
  InAppWebViewController? _webViewController;

  @override
  void didUpdateWidget(covariant WebviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the URL has changed and reload the WebView
      _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(widget.url)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.url), // Use the passed URL
            ),
            initialSettings: InAppWebViewSettings(
              mediaPlaybackRequiresUserGesture: false,
              useHybridComposition: true,
              allowsInlineMediaPlayback: true,
              javaScriptEnabled: true
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                // _isLoading = true; // Show loader when loading starts
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                // _isLoading = false; // Hide loader when loading stops
              });
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                // _isLoading = false; // Hide loader if there is an error
              });
            },
            onConsoleMessage: (controller, consoleMessage) async {
              // Print console logs
              final url = await controller.getUrl();

              // Print the URL and Console Messages
              print('Console Log from URL: ${url.toString()}'); // Correctly print the URL
              print('Console Log from URL: ${controller.getUrl().toString()}');
              print('Console Log Message: ${consoleMessage.message}');
              print('Log Level: ${consoleMessage.messageLevel}');
            },
            onDownloadStartRequest: (controller, downloadStartRequest) {
              // Handle download requests if needed
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              // Override URL loading if needed
              var uri = navigationAction.request.url;
              return NavigationActionPolicy.ALLOW;
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
              // Handle permission requests (e.g., camera, mic, etc.)
              return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT,
              );
            },
            androidOnGeolocationPermissionsShowPrompt:
                (InAppWebViewController controller, String origin) async {
              // Handle geolocation permissions
              return GeolocationPermissionShowPromptResponse(
                origin: origin,
                allow: true,
                retain: true,
              );
            },
          ),
          // Show a CircularProgressIndicator while the WebView is loading

        ],
      ),
    );
  }
}
