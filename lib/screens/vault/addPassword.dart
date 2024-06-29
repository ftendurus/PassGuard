import 'dart:convert';
import 'package:passguard/models/addPasswordModel.dart';
import 'package:passguard/provider/addPasswordProvider.dart';
import 'package:passguard/services/databaseService.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'package:provider/provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AddPassword extends StatefulWidget {
  const AddPassword({super.key});

  @override
  State<AddPassword> createState() => _AddPasswordState();
}

class _AddPasswordState extends State<AddPassword> {
  final focus = FocusNode();
  final titlecontroller = TextEditingController();
  final urlcontroller = TextEditingController(text: 'https://www.');
  final usernamecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final notescontroller = TextEditingController();
  bool isObsecured = true;

  final GlobalKey<FormState> _addPasswordformKey = GlobalKey<FormState>();

  void validate(BuildContext context) async {
    final FormState form = _addPasswordformKey.currentState!;

    if (form.validate()) {
      DateTime now = DateTime.now().toLocal();

      final newPass = AddPasswordModel(
        title: titlecontroller.text.trim(),
        url: urlcontroller.text.trim(),
        username: usernamecontroller.text.trim(),
        // Encrypt password before storing
        password: await _encryptPassword(passwordcontroller.text.trim()),
        notes: notescontroller.text.trim(),
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        addeddate: now,
      );
      context.read<DatabaseService>().addPassword(
        password: newPass,
      );
      context.read<AddPasswordProvider>().userPasswords = [];
      context.read<AddPasswordProvider>().fatchdata; // Corrected method call
      Navigator.pop(context);
    } else {
      const snackbar = SnackBar(
        content: Text("Lutfen tum gerekli alanlari doldurunuz."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

Future<String> _encryptPassword(String password) async {
  final prefs = EncryptedSharedPreferences();
  var masterPassword = await SharedPreferencesUtils.getMasterPassword();
  
  if (masterPassword!.length < 32) {
    masterPassword = masterPassword.padRight(32, 'a');
  }
  
  final key = encrypt.Key.fromUtf8(masterPassword);
  final iv = encrypt.IV.allZerosOfLength(16);


  final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: 'PKCS7')); 

  final encrypted = encrypter.encrypt(password, iv: iv);

  return base64.encode(encrypted.bytes);
}

  @override
  void dispose() {
    titlecontroller.dispose();
    urlcontroller.dispose();
    usernamecontroller.dispose();
    passwordcontroller.dispose();
    notescontroller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passNotifier = ValueNotifier<PasswordStrength?>(null);

    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              validate(context);
            },
            child: const Text('Kaydet'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.07,
          ),
          child: Form(
            key: _addPasswordformKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hesap Bilgileri Ekle',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                const Text(
                  'Lutfen belirtilen zorunlu alanlari doldurun.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                const Row(
                  children: [
                    Text(
                      'Baslik ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '*',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: titlecontroller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator:
                      RequiredValidator(errorText: 'Baslik Gerekli').call,
                  decoration: const InputDecoration(
                    filled: true,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                const Text(
                  'URL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextFormField(
                  controller: urlcontroller,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    filled: true,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                const Row(
                  children: [
                    Text(
                      'Kullanici Adi / E-mail ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '*',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
                TextFormField(
                  controller: usernamecontroller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator:
                      RequiredValidator(errorText: 'Kullanici Adi / E-mail gerekli')
                          .call,
                  decoration: const InputDecoration(
                    filled: true,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                const Row(
                  children: [
                    Text(
                      'Parola ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '*',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  onChanged: (value) {
                    passNotifier.value =
                        PasswordStrength.calculate(text: value);
                  },
                  obscureText: isObsecured,
                  controller: passwordcontroller,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(focus);
                  },
                  validator:
                      RequiredValidator(errorText: 'Parola gerekli')
                          .call,
                  decoration: InputDecoration(
                    filled: true,
                    suffix: InkWell(
                      child: Icon(
                        isObsecured
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                  height: size.height * 0.02,
                ),
                PasswordStrengthChecker(
                  strength: passNotifier,
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                const Text(
                  'Notlar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  focusNode: focus,
                  controller: notescontroller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    filled: true,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      validate(context);
                    },
                    child: const Text('Kaydet'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SharedPreferencesUtils {
  static Future<String?> getMasterPassword() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    return prefs.getString('password');
  }
}
