import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewWidget extends StatefulWidget {
  final String url;
  final String? fcmToken;

  const WebviewWidget({required this.url, required this.fcmToken});

  @override
  State<WebviewWidget> createState() => _WebviewWidgetState();
}

class _WebviewWidgetState extends State<WebviewWidget> {
  InAppWebViewController? _webViewController;
  String oldPath = "";


  @override
  void initState() {
    oldPath = WebUri(widget.url).path.toString();
    super.initState();
  }


  @override
  void didUpdateWidget(covariant WebviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _webViewController?.loadUrl(
      urlRequest:
          URLRequest(url: WebUri("${widget.url}")),
    );
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
      window.addEventListener('message', function(event) {
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
              if (url != null && !url.toString().contains("login") && (widget.fcmToken!=null && widget.fcmToken!.isNotEmpty)) {
                if (!url.queryParameters.containsKey("webView") && oldPath!=url.path.toString()) {
                  oldPath = url.path;
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
