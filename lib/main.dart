import 'package:flutter/material.dart';
import 'signup.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

// REUSABLE COLORS & SPACING
const Color primaryColor = Color(0xFFFA5246);
const Color secondaryColor = Color(0xFF808080);
const double spacingSmall = 10.0;
const double spacingMedium = 20.0;
const double spacingLarge = 40.0;

// REUSABLE ERROR TEXT STYLE
const TextStyle errorTextStyle = TextStyle(
  fontSize: 15,
  fontFamily: 'Quicksand',
  fontWeight: FontWeight.w600,
  color: Colors.red,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TEXTFIELD CONTROLLERS
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // FOR ERROR MESSAGES
  String? _usernameError;
  String? _passwordError;

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _usernameError = username.isEmpty ? 'Please fill out this field' : null;
      _passwordError = password.isEmpty ? 'Please fill out this field' : null;
    });

    if (_usernameError != null || _passwordError != null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  // TEXTFIELDS BUILDER
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? errorText,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: (value) {
        if (errorText != null && value.isNotEmpty) {
          setState(() {
            if (label == 'Username') _usernameError = null;
            if (label == 'Password') _passwordError = null;
          });
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 18,
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w500,
          color: secondaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFACACAC), width: 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 15,
        ),
        errorText: errorText,
        errorStyle: errorTextStyle,
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: secondaryColor,
                ),
                onPressed: toggleVisibility,
              )
            : null,
      ),
    );
  }

  // LOGIN BUTTON BUILDER
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Login',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'REM',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // BACKGROUND IMAGE & LOGO
          Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: screenHeight / 4,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/login_bg.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight / 20,
                    left: 30,
                    child: Image.asset(
                      'assets/login_logo.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // LOGIN CARD
          Positioned(
            top: screenHeight / 4 - 40,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Welcome to ResQ!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontFamily: 'REM',
                      ),
                    ),
                  ),
                  const SizedBox(height: spacingSmall),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Your safety starts here',
                      style: TextStyle(
                        fontSize: 18,
                        color: secondaryColor,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: spacingLarge),

                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    errorText: _usernameError,
                  ),
                  const SizedBox(height: spacingMedium),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    errorText: _passwordError,
                    toggleVisibility: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  const SizedBox(height: spacingLarge),

                  //LOGIN BUTTON
                  _buildLoginButton(),

                  const SizedBox(height: spacingMedium),

                  // SIGN UP ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don’t have an account?',
                        style: TextStyle(
                          fontSize: 15,
                          color: secondaryColor,
                          fontFamily: "Quicksand",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 15,
                            color: primaryColor,
                            fontFamily: "Quicksand",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
