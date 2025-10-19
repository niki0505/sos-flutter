import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() => runApp(const SignupScreen());

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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // FIRE STORE
  final FirestoreService fireStoreService = FirestoreService();

  // TEXTFIELD CONTROLLERS
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  bool _obscurePassword = true;

  // DROPDOWN
  String? _selectedSex;

  // FOR ERROR MESSAGES
  final Map<String, String?> _errors = {};

  void _signup() {
    setState(() {
      _errors['firstname'] = _firstnameController.text.trim().isEmpty
          ? 'Please fill out this field'
          : null;
      _errors['lastname'] = _lastnameController.text.trim().isEmpty
          ? 'Please fill out this field'
          : null;
      _errors['sex'] = _selectedSex == null ? 'Please select your sex' : null;
      _errors['birthdate'] = _birthdateController.text.trim().isEmpty
          ? 'Please select your birthdate'
          : null;
      _errors['mobile'] = _mobileController.text.trim().isEmpty
          ? 'Please fill out this field'
          : null;
      _errors['username'] = _usernameController.text.trim().isEmpty
          ? 'Please fill out this field'
          : null;
      _errors['password'] = _passwordController.text.trim().isEmpty
          ? 'Please fill out this field'
          : null;
      _errors['confirmpassword'] =
          _confirmpasswordController.text.trim().isEmpty
          ? 'Please fill out this field'
          : (_confirmpasswordController.text != _passwordController.text
                ? 'Passwords do not match'
                : null);
    });

    if (_errors.values.any((e) => e != null)) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  //BIRTH DATE FORMAT
  Future<void> _selectBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _birthdateController.text = DateFormat('MM-dd-yyyy').format(picked);
        _errors['birthdate'] = null;
      });
    }
  }

  // TEXTFIELDS BUILDER
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? errorKey,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onTap: onTap,
          onChanged: (_) {
            if (errorKey != null && _errors[errorKey] != null) {
              setState(() => _errors[errorKey] = null);
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
              borderSide: const BorderSide(
                color: Color(0xFFACACAC),
                width: 0.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
        if (errorKey != null && _errors[errorKey] != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(_errors[errorKey]!, style: errorTextStyle),
          ),
      ],
    );
  }

  //DROPDOWN BUILDER
  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedSex,
          items: ['Male', 'Female']
              .map((sex) => DropdownMenuItem(value: sex, child: Text(sex)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedSex = value;
              _sexController.text = value!;
              _errors['sex'] = null;
            });
          },
          decoration: InputDecoration(
            labelText: 'Sex',
            labelStyle: const TextStyle(
              fontSize: 18,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w500,
              color: secondaryColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFFACACAC),
                width: 0.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
          ),
        ),
        if (_errors['sex'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(_errors['sex']!, style: errorTextStyle),
          ),
      ],
    );
  }

  // PASSWORD BUILDER
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String errorKey,
  }) {
    return _buildTextField(
      controller: controller,
      label: label,
      errorKey: errorKey,
      obscure: true,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility : Icons.visibility_off,
          color: secondaryColor,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
    );
  }

  // SIGNUP BUTTON BUILDER
  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          fireStoreService.addUser(
            _firstnameController.text,
            _lastnameController.text,
            _sexController.text,
            _birthdateController.text,
            _mobileController.text,
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );
          _signup();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Signup',
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
              Container(
                height: screenHeight / 4,
                color: const Color(0x33FA5246),
              ),
            ],
          ),

          // SIGNUP CARD
          Positioned(
            top: screenHeight / 4 - 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 35,
                  right: 35,
                  top: 35,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Create Account!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontFamily: 'REM',
                      ),
                    ),
                    const SizedBox(height: spacingSmall),
                    const Text(
                      'Join us, get help fast',
                      style: TextStyle(
                        fontSize: 18,
                        color: secondaryColor,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: spacingLarge),

                    _buildTextField(
                      controller: _firstnameController,
                      label: 'First Name',
                      errorKey: 'firstname',
                    ),
                    const SizedBox(height: spacingMedium),
                    _buildTextField(
                      controller: _lastnameController,
                      label: 'Last Name',
                      errorKey: 'lastname',
                    ),
                    const SizedBox(height: spacingMedium),
                    _buildDropdownField(),
                    const SizedBox(height: spacingMedium),
                    _buildTextField(
                      controller: _birthdateController,
                      label: 'Birthdate',
                      errorKey: 'birthdate',
                      readOnly: true,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.calendar_today,
                          color: secondaryColor,
                        ),
                        onPressed: () => _selectBirthdate(context),
                      ),
                    ),
                    const SizedBox(height: spacingMedium),
                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      errorKey: 'mobile',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                        _PhoneNumberFormatter(),
                      ],
                    ),
                    const SizedBox(height: spacingMedium),
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      errorKey: 'username',
                    ),
                    const SizedBox(height: spacingMedium),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      errorKey: 'password',
                    ),
                    const SizedBox(height: spacingMedium),
                    _buildPasswordField(
                      controller: _confirmpasswordController,
                      label: 'Confirm Password',
                      errorKey: 'confirmpassword',
                    ),
                    const SizedBox(height: spacingLarge),

                    //SIGN UP BUTTON
                    _buildSignUpButton(),

                    // LOGIN ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Have an account?',
                          style: TextStyle(
                            fontSize: 15,
                            color: secondaryColor,
                            fontFamily: "Quicksand",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          child: const Text(
                            'Log in',
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
          ),
        ],
      ),
    );
  }
}

//FORMAT MOBILE NUMBER
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String formatted = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (formatted.isNotEmpty && !formatted.startsWith('63'))
      formatted = '63$formatted';
    if (formatted.length > 13) formatted = formatted.substring(0, 13);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
