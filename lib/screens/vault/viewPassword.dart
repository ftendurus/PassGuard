import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:passguard/models/addPasswordModel.dart';
import 'package:passguard/provider/addPasswordProvider.dart';
import 'package:passguard/services/databaseService.dart';
import 'package:passguard/utils/masterPassUtil.dart';

class ViewPassword extends StatefulWidget {
  const ViewPassword({Key? key}) : super(key: key);

  @override
  State<ViewPassword> createState() => _ViewPasswordState();
}

class _ViewPasswordState extends State<ViewPassword> {
  final focus = FocusNode();
  final titlecontroller = TextEditingController();
  final urlcontroller = TextEditingController();
  final usernamecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final notescontroller = TextEditingController();
  bool isObsecured = true;
  bool didAuthenticate = false;
  String keyString = "";
  String masterPassString = "";

  final GlobalKey<FormState> _viewPasswordformKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    authenticate();
    loadMasterPassword();
  }

  void loadMasterPassword() async {
    String? password = await SharedPreferencesUtils.getMasterPassword();
    if (password != null) {
      setState(() {
        masterPassString = password.padRight(32, 'a');
      });
    }
  }

  String decryptPass(String? text) {
    if (text == null || text.isEmpty) return '';

    keyString = masterPassString.padRight(32, 'a');
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.allZerosOfLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: 'PKCS7'));

    try {
      final decrypted = encrypter.decrypt64(text, iv: iv);
      return decrypted;
    } catch (e) {
      print('Decryption error: $e');
      return '';
    }
  }

  String encryptPass(String text) {
    keyString = masterPassString.padRight(32, 'a');
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.allZerosOfLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: 'PKCS7'));

    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64;
  }

  void authenticate() async {
    var localAuth = LocalAuthentication();
    didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Sifreyi gorebilmek icin biyometrik dogrulamayi saglayin!',
      options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
    );

    if (didAuthenticate) {
      // Biyometrik doğrulama başarılı olduktan sonra verileri kontrolörlere yükle
      final addPasswordProvider = context.read<AddPasswordProvider>();
      setState(() {
        usernamecontroller.text = addPasswordProvider.username;
        titlecontroller.text = addPasswordProvider.title ?? '';
        urlcontroller.text = addPasswordProvider.url ?? '';
        passwordcontroller.text = decryptPass(addPasswordProvider.password);
        notescontroller.text = addPasswordProvider.notes ?? '';
      });
    }
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
    final size = MediaQuery.of(context).size;
    final addPasswordProvider = context.read<AddPasswordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          addPasswordProvider.title!,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              if (didAuthenticate) {
                Clipboard.setData(
                  ClipboardData(text: decryptPass(addPasswordProvider.password)),
                ).then(
                  (value) {
                    return ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sifre kopyalandi'),
                      ),
                    );
                  },
                );
              } else {
                const snackBar = SnackBar(content: Text('Kimlik dogrulama yapmaniz gerekli!'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined),
            onPressed: () async {
              if (didAuthenticate) {
                addPasswordProvider.deletePassword();
                addPasswordProvider.userPasswords = [];
                addPasswordProvider.fatchdata;
                Navigator.pop(context);
              } else {
                const snackBar = SnackBar(content: Text('Kimlik dogrulama yapmaniz gerekli!'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
          child: Form(
            key: _viewPasswordformKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  controller: titlecontroller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: RequiredValidator(errorText: 'Baslik gerekli').call,
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
                  validator: RequiredValidator(errorText: 'Kullanici adi / E-mail gerekli').call,
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
                  obscureText: isObsecured,
                  controller: passwordcontroller,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(focus);
                  },
                  validator: RequiredValidator(errorText: 'Parola gerekli').call,
                  decoration: InputDecoration(
                    filled: true,
                    suffix: InkWell(
                      child: Icon(
                        isObsecured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onTap: () async {
                        if (didAuthenticate) {
                          setState(() {
                            isObsecured = !isObsecured;
                          });
                        } else {
                          const snackBar = SnackBar(content: Text('Kimlik dogrulamayi saglayin!'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                    ),
                  ),
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
                    child: const Text('Guncelle'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void validate(BuildContext context) async {
    final FormState form = _viewPasswordformKey.currentState!;

    if (form.validate()) {
      if (didAuthenticate) {
        final encryptedPassword = encryptPass(passwordcontroller.text.trim());

        final newPass = AddPasswordModel(
          addeddate: context.read<AddPasswordProvider>().addeddate,
          title: titlecontroller.text.trim(),
          url: urlcontroller.text.trim(),
          username: usernamecontroller.text.trim(),
          password: encryptedPassword,
          notes: notescontroller.text.trim(),
          id: context.read<AddPasswordProvider>().id,
        );
        context.read<DatabaseService>().updatePassword(
          password: newPass,
        ).then((value) {
          context.read<AddPasswordProvider>().userPasswords = [];
          context.read<AddPasswordProvider>().fatchdata; // Assuming this is a method to fetch data

          Navigator.pop(context);
        });
      } else {
        const snackbar = SnackBar(
          content: Text("Lutfen biyometrik dogrulamayi saglayin."),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } else {
      const snackbar = SnackBar(
        content: Text("Lutfen zorunlu olan tum alanlari doldurun."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }
}
