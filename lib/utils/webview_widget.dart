import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewWidget extends StatefulWidget {
  final String url;
  final String fcmToken;

  const WebviewWidget({required this.url, required this.fcmToken});

  @override
  State<WebviewWidget> createState() => _WebviewWidgetState();
}

class _WebviewWidgetState extends State<WebviewWidget> {
  InAppWebViewController? _webViewController;
  String? lastVisitedUrl; // To track the last visited URL

  @override
  void didUpdateWidget(covariant WebviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _webViewController?.loadUrl(
      urlRequest:
          URLRequest(url: WebUri("${widget.url}")),
    );
  }

  @override
  void initState() {
    print("token${widget.fcmToken}");
    super.initState();
  }

  Future<void> addEventListener() async {
    Uri uri = Uri.parse(widget.url);
    String origin =
        "${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}";
    var jsonData = {
      "type": "MOBILE_WEB_VIEW_DATA",
      "payload": base64Encode(
          utf8.encode(jsonEncode({"_fcmToken": widget.fcmToken})))
    };
    String jsonString = json.encode(jsonData);
    await _webViewController!.evaluateJavascript(source: """
      console.log("#############-1");
      window.addEventListener('message', function(event) {
        console.log("#############-5", typeof event.data);
        if(event.data.type=="NUI_LOADED"){
          window.postMessage($jsonString, '$origin');
        }
      })"""
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri("${widget.url}")),
            initialSettings:
              InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: false,
                useHybridComposition: true,
                allowsInlineMediaPlayback: true,
                javaScriptEnabled: true
              ),
            onWebViewCreated: (controller) async {
              _webViewController = controller;
              await addEventListener();
            },
            onUpdateVisitedHistory: (controller, url, androidIsReload) async {
              if (url != null && !url.toString().contains("login")) {
                if (!url.queryParameters.containsKey("webView")) {
                  Uri modifiedUrl = url.replace(queryParameters: {
                    "webView": "webView", // Add your custom parameter
                  });
                  await _webViewController?.loadUrl(urlRequest: URLRequest(
                      url: WebUri(modifiedUrl.toString())));
                }
              }
            },
            onLoadStart: (controller, url) async {},
            onLoadStop: (controller, url) async {
              await addEventListener();
            },
            onLoadError: (controller, url, code, message) {},
            onConsoleMessage: (controller, consoleMessage) async {
              final url = await controller.getUrl();
              print(
                  'Console Log from URL: ${url.toString()}'); // Correctly print the URL
              print('Console Log from URL: ${controller.getUrl().toString()}');
              print('Console Log Message: ${consoleMessage.message}');
              print('Log Level: ${consoleMessage.messageLevel}');
            },
            onDownloadStartRequest: (controller, downloadStartRequest) {},
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
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
        ],
      ),
    );
  }
}
