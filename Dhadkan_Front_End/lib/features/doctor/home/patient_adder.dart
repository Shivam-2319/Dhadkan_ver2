import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as record_pkg;
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:dhadkan/features/doctor/home/doctor_home.dart';
import 'package:dhadkan/utils/constants/colors.dart';
import 'package:dhadkan/utils/device/device_utility.dart';
import 'package:dhadkan/utils/helpers/alphaToNum.dart';
import 'package:dhadkan/utils/storage/secure_storage_service.dart';
import 'package:dhadkan/utils/theme/text_theme.dart';
import 'package:dhadkan/utils/http/http_client.dart';

import 'package:dhadkan/models/user.dart';
import 'package:dhadkan/models/patient.dart';
import 'package:dhadkan/models/sync_status.dart';
import 'package:dhadkan/repositories/local/patient_local_repository.dart';

class Patientadder extends StatefulWidget {
  const Patientadder({super.key});

  @override
  State<Patientadder> createState() => _PatientadderState();
}

class _PatientadderState extends State<Patientadder> {
  String _token = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController uhidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? selectedGender;
  bool _obscurePassword = true;
  bool _isButtonLocked = false;

  final recorder = record_pkg.AudioRecorder();
  bool isRecording = false;
  TextEditingController? currentListeningController;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await SecureStorageService.getData('authToken');
    if (mounted) {
      setState(() => _token = token ?? '');
    }
    _generatePassword();
  }

  // ===============================
  // 🔐 PASSWORD GENERATION
  // ===============================
  void _generatePassword() {
    final name = nameController.text.trim().toLowerCase();
    final mobile = mobileController.text.replaceAll(RegExp(r'\D'), '');

    final namePart =
        name.isNotEmpty ? name.substring(0, name.length.clamp(0, 4)) : '';
    final mobilePart =
        mobile.length >= 4 ? mobile.substring(mobile.length - 4) : '';

    passwordController.text = namePart + mobilePart;
  }

  // ===============================
  // ✅ ONLINE + OFFLINE SAFE ADD (FIXED)
  // ===============================
 Future<void> handleAdd(BuildContext context) async {
  if (_isButtonLocked) return;
  setState(() => _isButtonLocked = true);

  final name = nameController.text.trim();
  final mobile = mobileController.text.trim();
  final ageText = ageController.text.trim();
  final uhid = uhidController.text.trim();
  final email = emailController.text.trim();
  final gender = selectedGender;

  if (name.isEmpty ||
      mobile.isEmpty ||
      ageText.isEmpty ||
      uhid.isEmpty ||
      gender == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields')),
    );
    _isButtonLocked = false;
    return;
  }

  final age = int.parse(ageText);

  final user = User(
    id: mobile,
    name: name,
    mobile: mobile,
    email: email,
    role: 'PATIENT',
  );

  Patient patient = Patient(
    user: user,
    uhid: uhid,
    age: age,
    gender: gender,
    disease: null,
    syncStatus: SyncStatus.pending,
  );

  bool backendAccepted = false;

  final connectivity = await Connectivity().checkConnectivity();
  final hasInternet = connectivity != ConnectivityResult.none;

  if (hasInternet && _token.isNotEmpty) {
    try {
      final response = await MyHttpHelper.private_post(
        '/doctor/addpatient',
        patient.toApiJson(),
        _token,
      );

      // 🔑 ONLY THIS COUNTS AS SUCCESS
      if (response['success'] == true ||
          response['success'] == 'true' ||
          response['status'] == 'success') {
        backendAccepted = true;
        patient = patient.copyWith(syncStatus: SyncStatus.synced);
      }
    } catch (e) {
      // Network / parsing error → treat as offline
      backendAccepted = false;
    }
  }

  // Always save locally (single source of truth)
  await PatientLocalRepository().save(patient);

  // ✅ CORRECT MESSAGE
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        backendAccepted
            ? 'Patient added successfully'
            : 'No internet. Patient saved locally',
      ),
    ),
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const DoctorHome()),
  );

  setState(() => _isButtonLocked = false);
}

  // ===============================
  // 🎨 UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MyDeviceUtils.getScreenWidth(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sign-Up Information',
              style: MyTextTheme.textTheme.headlineSmall),
          const SizedBox(height: 16),

          _input('Name', nameController, genPwd: true),
          _input('Phone Number', mobileController, genPwd: true),
          _genderDropdown(),
          _input('Age', ageController),
          _input('UHID', uhidController),
          _passwordField(),
          _input('Email', emailController),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isButtonLocked ? null : () => handleAdd(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isButtonLocked
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Add this Patient...',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController c, {bool genPwd = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: label == 'Age' ||
                label == 'Phone Number' ||
                label == 'UHID'
            ? TextInputType.number
            : TextInputType.text,
        onChanged: (_) => genPwd ? _generatePassword() : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: ['Male', 'Female', 'Other']
            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
            .toList(),
        onChanged: (v) => setState(() => selectedGender = v),
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }
}
