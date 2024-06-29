import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class SharedPreferencesUtils {
  static Future<String?> getMasterPassword() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    return prefs.getString('password');
  }
}