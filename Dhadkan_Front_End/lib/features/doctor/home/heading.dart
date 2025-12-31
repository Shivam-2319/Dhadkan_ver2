import 'dart:convert';
import 'package:dhadkan/features/doctor/home/display.dart';
import 'package:dhadkan/utils/device/device_utility.dart';
import 'package:dhadkan/utils/http/http_client.dart';
import 'package:dhadkan/utils/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';

class Heading extends StatefulWidget {
  const Heading({super.key});

  @override
  State<Heading> createState() => _HeadingState();
}

class _HeadingState extends State<Heading> {
  String _token = "";

  Map<String, dynamic> doctorDetails = {
    "name": "",
    "hospital": "",
    "mobile": "",
    "email": "",
  };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 1️⃣ Load token
    final token = await SecureStorageService.getData('authToken');
    _token = token ?? '';

    // 2️⃣ LOAD LOCAL PROFILE FIRST (OFFLINE SAFE)
    final localProfile =
        await SecureStorageService.getData('doctorProfile');

    if (localProfile != null) {
      setState(() {
        doctorDetails = jsonDecode(localProfile);
      });
      print('[HEADING] Loaded doctor profile from local storage');
    }

    // 3️⃣ TRY BACKEND (ONLINE ONLY)
    try {
      final response = await MyHttpHelper.private_post(
        '/auth/get-details',
        {},
        _token,
      );

      if (response['success'] == 'true') {
        setState(() {
          doctorDetails = response['data'];
        });

        // 🔐 Cache for offline use
        await SecureStorageService.storeData(
          'doctorProfile',
          jsonEncode(response['data']),
        );

        print('[HEADING] Doctor profile refreshed from backend');
      }
    } catch (e) {
      // ❗ NO SNACKBAR — offline is valid state
      print('[HEADING] Backend unreachable, using cached profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MyDeviceUtils.getScreenWidth(context) * 0.9;

    return Container(
      height: 140,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Image.asset(
                'assets/Images/doctor2.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 20),
            Display(data: doctorDetails),
          ],
        ),
      ),
    );
  }
}
