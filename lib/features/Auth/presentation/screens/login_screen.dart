import 'package:attendantwebapp/app/urls.dart';
import 'package:attendantwebapp/core/services/network_caller.dart';
import 'package:attendantwebapp/features/Auth/data/models/login_user_model.dart';
import 'package:attendantwebapp/features/Auth/presentation/auth_controller.dart';
import 'package:attendantwebapp/features/Common/presentation/screens/bottom_nav_controller.dart';
import 'package:attendantwebapp/features/Common/presentation/widgets/login_backgroung.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailcontroller;
  late TextEditingController _passwordcontroller;

  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool inprogresslogin = false;

  @override
  void initState() {
    super.initState();

    _emailcontroller = TextEditingController();
    _passwordcontroller = TextEditingController();

    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    const storage = FlutterSecureStorage();

    final savedUsername = await storage.read(key: 'saved_username');
    final savedPassword = await storage.read(key: 'saved_password');

    if (savedUsername != null) _emailcontroller.text = savedUsername;
    if (savedPassword != null) _passwordcontroller.text = savedPassword;
  }

  @override
  void dispose() {
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: LoginBackground(
        child: Form(
          key: _fromKey,
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.15),

                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "Smart Doctor",
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF0B3E6B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  ///
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF0B3E6B), width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 18,
                        right: 18,
                        bottom: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Username",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          SizedBox(height: 3),

                          TextFormField(
                            controller: _emailcontroller,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 15,
                              ),
                              hintText: "Email",

                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0B3E6B),
                                  width: 2,
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0B3E6B),
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "enter the email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 7),

                          Text(
                            "Password",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          SizedBox(height: 3),
                          TextFormField(
                            controller: _passwordcontroller,
                            obscureText: _obscurePassword,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 15,
                              ),
                              hintText: "Enter Password",
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0B3E6B),
                                  width: 2,
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 7, 39, 251),
                                  width: 2,
                                ),
                              ),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "enter the correct password";
                              }
                              return null;
                            },
                          ),

                          // Row(
                          //   children: [
                          //     Icon(
                          //       Icons.toggle_off,
                          //       size: 50,
                          //       color: Colors.grey.shade300,
                          //     ),
                          //     SizedBox(width: 5),
                          //     Text(
                          //       "Remember",
                          //       style: TextStyle(
                          //         fontSize: 16,
                          //         color: Colors.black,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          SizedBox(height: 10),

                          Visibility(
                            visible: inprogresslogin == false,
                            replacement: Center(
                              child: CircularProgressIndicator(),
                            ),
                            child: FilledButton(
                              onPressed: () {
                                if (_fromKey.currentState!.validate()) {
                                  _login();
                                }
                              },
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Color(0xFF0B3E6B),
                                minimumSize: const Size(370, 40), //
                              ),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Future<String> getAndroidId() async {
  //   final deviceinfo = DeviceInfoPlugin();
  //   final android = await deviceinfo.androidInfo;
  //   return android.id;
  // }

  // // login
  Future<void> _login() async {
    inprogresslogin = true;
    setState(() {});

    // String androidId = await getAndroidId();
    String? androidId = await DeviceIdService.getDeviceId();
    print("ANDROID ID = $androidId");

    final Map<String, dynamic> requestBody = {
      "identifier": _emailcontroller.text.trim(),
      "password": _passwordcontroller.text.trim(),
      "android_id": androidId,
    };

    ApiResponse response = await NetworkCaller.postRequest(
      url: Urls.loginUrl,
      body: requestBody,
    );

    // 🔴 FIX-4: Safe check

    if (response.isSuccess && response.responseData["status"] == "success") {
      UserModel model = UserModel.fromJson(
        response.responseData["data"]["user"],
      );

      final responseDataPart = response.responseData["data"];

      String accessToken = responseDataPart["access_token"];

      await AuthController.saveUserData(model, accessToken);

      final storage = FlutterSecureStorage();

      // Login success হলে save করা
      await storage.write(
        key: 'saved_username',
        value: _emailcontroller.text.trim(),
      );

      await storage.write(
        key: 'saved_password',
        value: _passwordcontroller.text.trim(),
      );

      Get.offAll(() => BottomNavControllerScreen());

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Color(0xFF0B3E6B),
          content: Center(
            child: Text(
              response.errorMessage,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          content: Center(
            child: Text(
              response.errorMessage,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    inprogresslogin = false;
    setState(() {});
  }
}

class DeviceIdService {
  static const MethodChannel _channel = MethodChannel('device_info_channel');

  static Future<String?> getDeviceId() async {
    try {
      final String? id = await _channel.invokeMethod('getDeviceId');
      return id;
    } catch (e) {
      return null;
    }
  }
}
