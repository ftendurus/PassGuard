import 'package:passguard/provider/addPasswordProvider.dart';
import 'package:passguard/provider/generatedPasswordProvider.dart';
import 'package:passguard/provider/themeProvider.dart';
import 'package:passguard/screens/authentication/login.dart';
import 'package:passguard/screens/onBoardingPage.dart';
import 'package:passguard/services/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'consts/consts.dart';
import 'consts/style.dart';

int? isviewed;
void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeProvider themeProvider = ThemeProvider();

  void checkCurrentTheme() async {
    themeProvider.setTheme = await themeProvider.themePrefrences.getTheme();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isviewed = prefs.getInt('onBoard');
    await Future.delayed(const Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    checkCurrentTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AddPasswordProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => DatabaseService(),
        ),
        ChangeNotifierProvider(
          create: (context) => GeneratedPasswordProvider(),
        ),
        ChangeNotifierProvider(create: (_) {
          return themeProvider;
        }),
      ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Consts.APP_NAME,
          theme: Styles.themeData(
              context.watch<ThemeProvider>().getDarkTheme, context),
          home: isviewed != 0 ? const OnBoardingSceen() : const LoginPage(),
          // home: OnBoardingSceen(),
        );
      },
    );
  }
}
