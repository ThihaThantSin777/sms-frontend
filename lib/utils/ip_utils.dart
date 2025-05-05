import 'dart:io';

class IpUtils {
  static String? ip = '';

  static Future<void> init() async {
    ip = await getIPAddress();
  }

  static Future<String?> getIPAddress() async {
    final networkInterfaceList = await NetworkInterface.list();
    return networkInterfaceList.map((e) => e.addresses.toList().map((e) => e.address).firstOrNull).first;
  }
}
