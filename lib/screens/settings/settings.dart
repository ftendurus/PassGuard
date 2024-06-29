import 'package:passguard/provider/themeProvider.dart';
import 'package:passguard/screens/settings/changePassword.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../authentication/login.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool didAuthenticate = false;

  authenticate() async {
    var localAuth = LocalAuthentication();
    didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Islem yapabilmek icin dogrulama saglayin!',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true));
  }

  @override
  void initState() {
    super.initState();
    authenticate();
  }

  Future<void> logout(BuildContext context) async {
    // Burada oturum kapatma işlemlerini gerçekleştirin
    // Örneğin, kullanıcının kimlik bilgilerini temizleme veya token'ı silme
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    // Oturum kapatma işlemi tamamlandıktan sonra kullanıcıyı login sayfasına yönlendirin
   Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return const LoginPage();
                              },
                            ),
                            (_) => false,
                          );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayarlar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
          ),
          child: Column(
            children: [
              // _buildSettingList(
              //   context: context,
              //   title: 'Ana Parolayi Degistir',
              //   icon: Icons.password_outlined,
              //   ontap: () {
              //     if (didAuthenticate) {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => const ChangePasswordPage(),
              //         ),
              //       );
              //     } else {
              //       const snackBar =
              //           SnackBar(content: Text('Kimlik dogrulama yapmaniz gerekli!'));
              //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
              //     }
              //   },
              // ),
              // SizedBox(
              //   height: size.height * 0.01,
              // ),
              _buildSettingList(
                context: context,
                title: 'Gizlilik Sartlari',
                icon: Icons.policy_outlined,
                ontap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Yakinda'),
                    ),
                  );
                },
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              _buildSettingList(
                context: context,
                title: 'Database dosyasini disa aktar',
                icon: Icons.backup_outlined,
                ontap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Yakinda'),
                    ),
                  );
                },
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              _buildSettingList(
                context: context,
                title: context.watch<ThemeProvider>().getDarkTheme
                    ? 'Acik Tema'
                    : "Koyu Tema",
                icon: context.watch<ThemeProvider>().getDarkTheme
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                ontap: () {
                  context.read<ThemeProvider>().setTheme =
                      !context.read<ThemeProvider>().getDarkTheme;
                },
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              _buildSettingList(
                context: context,
                title: 'Cikis Yap',
                icon: Icons.logout,
                ontap: () {
                  logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingList({
    required String title,
    required IconData icon,
    required BuildContext context,
    required VoidCallback ontap,
  }) {
    return Material(
      color: Theme.of(context).highlightColor,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: ontap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Icon(
                icon,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
