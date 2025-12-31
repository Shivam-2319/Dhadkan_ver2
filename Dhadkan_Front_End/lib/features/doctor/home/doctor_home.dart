import 'package:dhadkan/features/auth/landing_screen.dart';
import 'package:dhadkan/features/common/top_bar.dart';
import 'package:dhadkan/features/doctor/home/heading.dart';
import 'package:dhadkan/utils/http/http_client.dart';
import 'package:dhadkan/utils/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';

import '../../../utils/device/device_utility.dart';
import 'doctor_buttons.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  @override
  void initState() {
    super.initState();
    _validateTokenInBackground();
  }

  Future<void> _validateTokenInBackground() async {
    final token = await SecureStorageService.getData('authToken');

    if (token == null) {
      _forceLogout();
      return;
    }

    try {
      final response = await MyHttpHelper.private_post(
        '/patient/validate-token',
        {},
        token,
      );

      if (response['status'] != 'valid' && mounted) {
        _showSessionExpiredDialog();
      }
    } catch (_) {
      // OFFLINE → DO NOTHING
      print('[AUTH] Token validation skipped (offline)');
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Session Expired"),
        content: const Text("Please login again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _forceLogout();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> _forceLogout() async {
    await SecureStorageService.deleteAll();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = MyDeviceUtils.getScreenWidth(context) * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const TopBar(title: "Welcome, Doctor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _forceLogout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          children: const [
            SizedBox(height: 15),
            Heading(), // ✅ now fully offline-safe
            SizedBox(height: 15),
            DoctorButtons(),
          ],
        ),
      ),
    );
  }
}
