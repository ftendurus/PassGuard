import 'package:passguard/screens/homepage.dart';
import 'package:passguard/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:passguard/provider/themeProvider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final passwordController = TextEditingController();
  final twoFactorController = TextEditingController();
  EncryptedSharedPreferences encryptedPrefs = EncryptedSharedPreferences();

  Future<void> _checkPassword(String password, BuildContext context) async {
    final masterPassword = await encryptedPrefs.getString('password');
    if (masterPassword == password) {
      _showTwoFactorDialog(context);
    } else {
      const snackbar = SnackBar(
        content: Text("Sifreler uyusmuyor"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  void validate(String password, BuildContext context) async {
    final FormState form = _loginformKey.currentState!;
    if (form.validate()) {
      await _checkPassword(password, context);
    } else {
      const snackbar = SnackBar(
        content: Text("Bilinmeyen data"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }
  static const correctCode = "123456";

  Future<void> _checkTwoFactorCode(String code, BuildContext context) async {
    if (code == correctCode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else {
      const snackbar = SnackBar(
        content: Text("2FA sifresi yanlis."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  void _showTwoFactorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Two-Factor Authentication'),
          content: TextField(
            controller: twoFactorController,
            decoration: const InputDecoration(labelText: '2FA Sifresini Girin'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkTwoFactorCode(twoFactorController.text.trim(), context);
              },
              child: const Text('Dogrula'),
            ),
          ],
        );
      },
    );
  }

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Sifre Gerekli'),
    MinLengthValidator(8, errorText: 'Sifre en az 8 karakter uzunlugunda olmali'),
    PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'Sifre en az 1 adet ozel karakter icermeli'),
  ]);

  bool isObsecured = true;
  final GlobalKey<FormState> _loginformKey = GlobalKey<FormState>();

  @override
  void dispose() {
    passwordController.dispose();
    twoFactorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: context.watch<ThemeProvider>().getDarkTheme ? Colors.black : Colors.white,
        statusBarIconBrightness: context.watch<ThemeProvider>().getDarkTheme ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              child: Form(
                key: _loginformKey,
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.07),
                    SvgPicture.asset('assets/secure_login.svg', height: size.height * 0.2),
                    SizedBox(height: size.height * 0.05),
                    Text(
                      'Sifrenizi girerek giris yapabilirsiniz',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                    SizedBox(height: size.height * 0.07),
                    TextFormField(
                      obscureText: isObsecured,
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      validator: passwordValidator,
                      decoration: InputDecoration(
                        labelText: 'Sifre',
                        filled: true,
                        border: const OutlineInputBorder(),
                        suffix: InkWell(
                          child: Icon(isObsecured ? Icons.visibility : Icons.visibility_off),
                          onTap: () {
                            setState(() {
                              isObsecured = !isObsecured;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    CustomButton(
                      ontap: () {
                        FocusManager.instance.primaryFocus!.unfocus();
                        validate(passwordController.text.trim(), context);
                      },
                      buttontext: 'Giris yap',
                    ),
                    SizedBox(height: size.height * 0.1),
                    const Divider(thickness: 1),
                    SizedBox(height: size.height * 0.01),
                    const Text(
                      'Siz 1 tane sifreyi hatirlayin, biz hepsini hatirlayalim. Giris yapmak artik daha kolay ve guvenli!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
