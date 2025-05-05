import 'package:sms_frontend/utils/ip_utils.dart';

void main() {
  IpUtils.init()
      .then((_) {
        print("Ip: ${IpUtils.ip}");
      })
      .catchError((error) {
        print("IP Error: $error");
      });
}
