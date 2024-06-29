import 'package:passguard/screens/homepage.dart';
import 'package:passguard/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final focus = FocusNode();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  bool isObsecured = true;
  EncryptedSharedPreferences encryptedPrefs = EncryptedSharedPreferences();

  _storeOnboardInfo() async {
    int isViewed = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isViewed);
  }

  _savePassword(String password) async {
    await encryptedPrefs.setString('password', password);
  }

  _saveBiometric(bool isEnabled) async {
    await encryptedPrefs.setString('biometricEnabled', isEnabled.toString());
  }

  _saveBiometricPassword(String password) async {
    await encryptedPrefs.setString('biometricPassword', password);
  }

  Future<void> _collectBiometricData() async {
    var localAuth = LocalAuthentication();
    try {
      // Check if biometric authentication is available
      bool canCheckBiometrics = await localAuth.canCheckBiometrics;
      if (canCheckBiometrics) {
        // Authenticate the user
        bool didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Enable biometric authentication for added security',
          options: AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        );

        if (didAuthenticate) {
          // Save biometric status after successful authentication
          _saveBiometric(true);
          print('Biyometrik veri kaydedildi');
        }
      }
    } catch (e) {
      print('biometric authentication hatasi: $e');
    }
  }

  authenticate() async {
    var localAuth = LocalAuthentication();
    bool didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Authenticate',
        options: AuthenticationOptions(biometricOnly: true, stickyAuth: true));

    if (!didAuthenticate) {
      Navigator.pop(context);
    }
  }

  final GlobalKey<FormState> _registerformKey = GlobalKey<FormState>();

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Sifre gerekli'),
    MinLengthValidator(8, errorText: 'Sifre en az 8 karakter uzunlugunda olmali'),
    PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'Sifre en az 1 adet ozel karakter icermeli'),
  ]);

  void validate(BuildContext context) async {
    final FormState form = _registerformKey.currentState!;
    if (form.validate()) {
      await _storeOnboardInfo();
      await _savePassword(confirmpasswordController.text.trim());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else {
      const snackbar = SnackBar(
        content: Text("Form is invalid"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmpasswordController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    authenticate();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
            child: Form(
              key: _registerformKey,
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.07,
                  ),
                  SvgPicture.asset(
                    'assets/secure_files.svg',
                    height: size.height * 0.2,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text(
                    'Bir adet master password giriniz',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.07,
                  ),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    obscureText: isObsecured,
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    validator: passwordValidator,
                    decoration: InputDecoration(
                      labelText: 'Sifre',
                      filled: true,
                      border: const OutlineInputBorder(),
                      suffix: InkWell(
                        child: Icon(
                          isObsecured ? Icons.visibility : Icons.visibility_off,
                        ),
                        onTap: () {
                          setState(() {
                            isObsecured = !isObsecured;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  TextFormField(
                    focusNode: focus,
                    obscureText: isObsecured,
                    controller: confirmpasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    validator: (val) => MatchValidator(
                            errorText: 'Sifreler eslesmiyor')
                        .validateMatch(val!, passwordController.text.trim()),
                    decoration: InputDecoration(
                      labelText: 'Sifreyi onayla',
                      filled: true,
                      border: const OutlineInputBorder(),
                      suffix: InkWell(
                        child: Icon(
                          isObsecured ? Icons.visibility : Icons.visibility_off,
                        ),
                        onTap: () {
                          setState(() {
                            isObsecured = !isObsecured;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  CustomButton(
                    ontap: () {
                      validate(context);
                    },
                    buttontext: 'Kaydol',
                  ),
                  SizedBox(
                    height: size.height * 0.07,
                  ),
                  const Divider(
                    thickness: 1,
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  const Text(
                    'Bu girdiginiz sifreyi lutfen bir yere not ediniz, '
                    'kaydedilen sifreler bu sifre olmadan kullanilamaz hale gelecektir '
                    'Duzenli olarak yedek aliniz.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
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
}
