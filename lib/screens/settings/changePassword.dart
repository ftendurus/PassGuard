// ignore_for_file: use_build_context_synchronously

import 'package:passguard/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  bool isObsecured = true;
  bool isAuthenticated = false;
  final focus = FocusNode();
  
  EncryptedSharedPreferences encryptedPrefs = EncryptedSharedPreferences();

  _savePassword(String password) async {
    await encryptedPrefs.setString('password', password);
  }

  final GlobalKey<FormState> _loginformKey = GlobalKey<FormState>();

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Sifre Gerekli'),
    MinLengthValidator(8, errorText: 'Sifre en az 8 karakter uzunlugunda olmali'),
    PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'Sifre en az 1 adet ozel karakter icermeli'),
  ]);

  void validate(BuildContext context) async {
    final FormState form = _loginformKey.currentState!;
    if (form.validate()) {
      await _savePassword(confirmpasswordController.text.trim());
      Navigator.pop(context);
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sifre degistir',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.07,
            ),
            child: Form(
              key: _loginformKey,
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    obscureText: isObsecured,
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    validator: passwordValidator.call,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Sifre',
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
                    buttontext: 'Sifreyi degistir',
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
