import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:kapture_nps/model/ConfigJsonModel.dart';
import 'dart:io' show Platform;


class CommonUtils {
  static Widget loadProgress() {
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Please wait...",
              textAlign: TextAlign.center,
            ),
          ),
          // Lottie.asset(
          //     "packages/kapture_nps/lib/assets/json/lottieAnimation.json"),
        ],
      ),
    );
  }

  // static Widget returnCloseButton(ConfigJson configJson,ValueChanged<bool> isFormClosed){
  //   if(configJson.close.enable){
  //     AlignmentGeometry alignmentGeometry;
  //     if(configJson.close.align == "left"){
  //       alignmentGeometry = Alignment.topLeft;
  //     }else if(configJson.close.align == "center"){
  //       alignmentGeometry = Alignment.center;
  //     }else{
  //       alignmentGeometry = Alignment.topRight;
  //     }
  //     return Container(
  //       width: null,
  //       alignment: alignmentGeometry,
  //       margin: EdgeInsets.symmetric(vertical: 10,horizontal:8),
  //       child: ElevatedButton(
  //         onPressed: ()=>{isFormClosed(true)},
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.white,
  //           padding: EdgeInsets.only(top: 2,bottom: 2,left: 15,right: 15),// Background color of the button
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20), // Rounded corners
  //           ),
  //         ),
  //         child: Padding(
  //           padding: EdgeInsets.symmetric(vertical: 7),
  //           child: Container(
  //             width: null,
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 if(configJson.close.enableIcon)
  //                   Padding(
  //                     padding: const EdgeInsets.only(right: 5.0),
  //                     child: Icon(Icons.arrow_back_ios_sharp,size: 11,color: HexColor.fromHex(configJson.close.colorCode),),
  //                   ),
  //                 Text(
  //                   configJson.close.buttonText,
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.bold,
  //                     color: HexColor.fromHex(configJson.close.colorCode),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }else{
  //     return Container();
  //   }
  //
  // }

  // static Widget returnWebView(bool isBottomSheet,WebView webView){
  //   if(isBottomSheet){
  //     return Expanded(
  //       child: Container(
  //         padding: EdgeInsets.only(top: 20),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.only(
  //             topLeft: const Radius.circular(25.0),
  //             topRight: const Radius.circular(25.0),
  //           ),
  //           color: Colors.white,
  //         ),
  //         child: webView,
  //       ),
  //     );
  //   }
  //   else{
  //     return Expanded(
  //         child: webView
  //     );
  //   }
  // }

  static void openStore(String androidId, String iosId) {
    if (Platform.isAndroid || Platform.isIOS) {
      final appId = Platform.isAndroid ? androidId : iosId;
      final url = Uri.parse(
        Platform.isAndroid
            ? "market://details?id=$appId"
            : "https://apps.apple.com/app/id$appId",
      );
      // launchUrl(
      //   url,
      //   mode: LaunchMode.externalApplication,
      // );
    }
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
