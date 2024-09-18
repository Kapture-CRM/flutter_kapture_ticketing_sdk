import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class WebviewWidget extends StatefulWidget {
  final String url;
  final String fcmToken;

  const WebviewWidget({required this.url, required this.fcmToken});

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
      urlRequest:
          URLRequest(url: WebUri("${widget.url}?fcmToken=${widget.fcmToken}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(
                  "${widget.url}?fcmToken=${widget.fcmToken}"), // Use the passed URL
            ),
            initialSettings: InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: false,
                useHybridComposition: true,
                allowsInlineMediaPlayback: true,
                javaScriptEnabled: true),
            onWebViewCreated: (InAppWebViewController controller) {
              _webViewController = controller;
              // Setting up a JavaScript handler that listens for the "callPhone" event
              _webViewController?.addJavaScriptHandler(
                handlerName: 'callPhone',
                callback: (args) async {
                  // Extract the phone number from the arguments
                  String phoneNumber = args[0];
                  // Validate phone number (10 digits, all numbers)
                  RegExp regExp = RegExp(r'^\d{10}$');
                  if (regExp.hasMatch(phoneNumber)) {
                    // Open the dialer with the phone number
                    String url = 'tel:+91$phoneNumber';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      // Show toast message for invalid phone number
                      Fluttertoast.showToast(
                        msg: "Failed to call: $phoneNumber",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  } else {
                    // Show toast message for invalid phone number
                    Fluttertoast.showToast(
                      msg: "Invalid phone number: $phoneNumber",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              );
            },
            onLoadStart: (controller, url) {},
            onConsoleMessage: (controller, consoleMessage) async {
              // Print console logs
              final url = await controller.getUrl();

              //  the URL and Console Messages
              print(
                  'Console Log from URL: ${url.toString()}'); // Correctly print the URL
              print('Console Log from URL: ${controller.getUrl().toString()}');
              print('Console Log Message: ${consoleMessage.message}');
              print('Log Level: ${consoleMessage.messageLevel}');
            },
            onDownloadStartRequest: (controller, downloadStartRequest) {
              // Handle download requests if needed
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Manually trigger the handler as if it's coming from the React side
              String testPhoneNumber = "1234567890";
              // This simulates the React call to Flutter
              await _webViewController?.evaluateJavascript(source: """
                window.flutter_inappwebview.callHandler('callPhone', '$testPhoneNumber');
              """);
            },
            child: Text("Simulate Phone Call"),
          ),
        ],
      ),
    );
  }
}
