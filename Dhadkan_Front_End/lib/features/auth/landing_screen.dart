import 'package:dhadkan/Custom/custom_elevated_button.dart';
import 'package:dhadkan/features/auth/selection_screen.dart';
import 'package:dhadkan/features/common/wrapper.dart';
import 'package:dhadkan/features/doctor/home/doctor_home.dart';
import 'package:dhadkan/features/patient/home/patient_home_screen.dart';
import 'package:dhadkan/utils/constants/colors.dart';
import 'package:dhadkan/utils/device/device_utility.dart';
import 'package:dhadkan/utils/helpers/helper_functions.dart';
import 'package:dhadkan/utils/http/http_client.dart';
import 'package:dhadkan/utils/storage/secure_storage_service.dart';
import 'package:dhadkan/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  Future<void> handleLogin(BuildContext context) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final String mobile = mobileController.text.trim();
    final String password = passwordController.text;

    if (mobile.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    try {
      final response = await MyHttpHelper.post(
        '/auth/login',
        {
          'mobile': mobile,
          'password': password,
        },
      );

      if (response['success'] == "true") {
        final String token = response['message'];
        final String role = getRole(token);

        if (role.isEmpty) {
          throw Exception('Invalid role in token');
        }

        await SecureStorageService.storeData('authToken', token);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful!")),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                role == "patient" ? const PatientHome() : const DoctorHome(),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MyDeviceUtils.getScreenWidth(context);

    return Scaffold(
      body: Wrapper(
        top: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// App Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dhadkan',
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'App for Heart Disease',
                      style: MyTextTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Image.asset(
                  'assets/Images/logo.png',
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                ),
              ],
            ),

            const SizedBox(height: 55),

            Text('Login', style: MyTextTheme.textTheme.headlineLarge),
            const SizedBox(height: 24),

            /// Mobile Field
            TextFormField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              style: MyTextTheme.textTheme.headlineSmall,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.phone),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
              ),
            ),

            const SizedBox(height: 16),

            /// Password Field
            TextFormField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: MyColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),

            const SizedBox(height: 16),

            /// Login Button (FIXED)
            SizedBox(
              width: screenWidth * 0.9,
              height: 50,
              child: CustomElevatedButton(
                onPressed: () {
                  if (_isSubmitting) return;
                  handleLogin(context);
                },
                text: _isSubmitting ? 'Logging in...' : 'Login',
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Patient default password is the first 4 letters of name + last 4 digits of mobile number",
              style: MyTextTheme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            /// Signup Redirect
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: MyTextTheme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SelectionScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: MyTextTheme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
