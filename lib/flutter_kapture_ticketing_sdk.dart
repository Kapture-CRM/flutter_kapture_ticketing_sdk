import 'package:flutter/material.dart';
import 'package:flutter_kapture_ticketing_sdk/utils/webview_widget.dart'; // Replace this with the correct path for WebviewWidget
import 'package:flutter_kapture_ticketing_sdk/utils/permission_handler_service.dart'; // Import the PermissionHandlerService

class KapturePackage extends StatefulWidget {
  final String url;

  const KapturePackage({super.key, required this.url});

  @override
  _KapturePackageState createState() => _KapturePackageState();
}

class _KapturePackageState extends State<KapturePackage> {
  bool _isConnected = true;
  bool _isLoading = true; // Track loading state

  final PermissionHandlerService _permissionHandlerService =
  PermissionHandlerService();

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _checkStoragePermission();
  }

  // Check internet connection
  Future<void> _checkInternetConnection() async {
    setState(() {
      _isLoading = true;
    });
    bool connected = await _permissionHandlerService.checkInternetConnection();
    setState(() {
      _isLoading = false;
      _isConnected = connected;
    });
  }

  // Check and request storage permission
  Future<void> _checkStoragePermission() async {
    setState(() {
      _isLoading = true;
    });
    bool hasPermission = await _permissionHandlerService.checkAndRequestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: _isLoading? const Center(child: CircularProgressIndicator()):
              !_isConnected
              ? _buildNoConnectionMessage()
              : WebviewWidget(url: widget.url),
        ));
  }

  // Widget to display when permission is not granted
  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 100, color: Colors.red),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Storage permission is required to proceed',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _checkStoragePermission,
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  // Widget to display when not connected to the internet
  Widget _buildNoConnectionMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 100, color: Colors.red),
          const SizedBox(height: 20),
          const Center(child:
          Text(
            'No internet connection',
            style: TextStyle(fontSize: 24),
          )
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _checkInternetConnection,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
