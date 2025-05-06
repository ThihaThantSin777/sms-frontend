import 'package:flutter/foundation.dart';
import 'package:sms_frontend/utils/ip_utils.dart';

void main() {
  IpUtils.init()
      .then((_) {
        if (kDebugMode) {
          print("Ip: ${IpUtils.ip}");
        }
      })
      .catchError((error) {
        if (kDebugMode) {
          print("IP Error: $error");
        }
      });
}
