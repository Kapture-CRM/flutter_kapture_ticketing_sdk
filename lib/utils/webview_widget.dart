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

  String? _response;

  @override
  void didUpdateWidget(covariant WebviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the URL has changed and reload the WebView
    // _webViewController?.loadUrl(
    //   urlRequest:
    //       URLRequest(url: WebUri("${widget.url}?fcmToken=${widget.fcmToken}")),
    // );
  }

  void _testJavaScriptCall() async {
    if (_webViewController != null) {
      print("#############33");
      // Sending a message to the WebView to trigger the event listener
      await _webViewController!.evaluateJavascript(source: """
      console.log("SDFDSF");
        window.postMessage("sdsssd", '*');
        console.log("SDFDSF1");
      """);
    }
  }

  // HTML content embedded directly into the WebView
  String embeddedHtml = """
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Test Message Listener</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin-top: 50px;
          }
          button {
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
          }
        </style>
      </head>
      <body>
        <h1>Test Message Listener from Flutter</h1>
        <button id="sendMessage">Send Message to Flutter</button>
        <p id="receivedData"></p>

        <script>
          // Listener to receive messages from Flutter (via WebView)

          // Send a message from the website to Flutter WebView
          document.getElementById('sendMessage').addEventListener('click', function() {
            window.postMessage('Hello from the web page!', '*');
            console.log("Message sent to Flutter from WebView");
          });
        </script>
      </body>
      </html>
    """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testable WebView'),
        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: _testJavaScriptCall,
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            // initialUrlRequest: URLRequest(
            //   url: WebUri(
            //       "${widget.url}?fcmToken=${widget.fcmToken}"), // Use the passed URL
            // ),
            initialData: InAppWebViewInitialData(data: embeddedHtml),

            initialSettings: InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: false,
                useHybridComposition: true,
                allowsInlineMediaPlayback: true,
                javaScriptEnabled: true),
            // onWebViewCreated: (InAppWebViewController controller) async {
            //   _webViewController = controller;
            //   Uri uri = Uri.parse(widget.url);
            //   String origin =
            //       "${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}";
            //   // Define the JSON data
            //   var jsonData = {
            //     "type": "MOBILE_WEB_VIEW_DATA",
            //     "payload": base64Encode(
            //         utf8.encode(jsonEncode({"_fcmToken": widget.fcmToken})))
            //   };
            //   // Convert JSON data to string and then encode to Base64
            //   String payload = jsonEncode(jsonData);
            //   await _webViewController?.evaluateJavascript(source: """
            //     window.postMessage('$payload', '$origin');
            //   """);
            // },
            onWebViewCreated: (controller) async {
              _webViewController = controller;
              Uri uri = Uri.parse(widget.url);
              String origin =
                  "${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}";

              // Define the JSON data
              var jsonData = {
                "type": "MOBILE_WEB_VIEW_DATA",
                "payload": base64Encode(
                    utf8.encode(jsonEncode({"_fcmToken": widget.fcmToken})))
              };

              // Convert JSON data to string and then encode to Base64
              String payload = jsonEncode(jsonData);

              // Send initial data to the WebView
              // await _webViewController?.evaluateJavascript(source: """
              //   window.postMessage('$payload', '$origin');
              // """);

              // Set up the event listener to listen for messages from Flutter
              await _webViewController!.evaluateJavascript(source: """
            window.addEventListener('message', function(event) {
              console.log('Received message from Flutter---:', event.data);
              window.postMessage('$payload', '$origin');
            });
          """);
            },
            onLoadStart: (controller, url) {},
            onLoadStop: (controller, url) {},
            onLoadError: (controller, url, code, message) {},
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
        ],
      ),
    );
  }
}
