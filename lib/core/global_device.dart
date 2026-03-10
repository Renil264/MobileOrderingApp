import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GlobalDevice {
  static String? deviceId;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    String? storedId = prefs.getString('device_uuid');

    if (storedId == null) {
      // Generate new UUID
      const uuid = Uuid();
      storedId = uuid.v4();

      await prefs.setString('device_uuid', storedId);
    }

    deviceId = storedId;
  }
}