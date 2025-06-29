import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// AppConfig holds environment-specific configuration such as API URLs and service ports.
class AppConfig {
  // Bilgisayarınızın IP adresi - kendi ağ yapılandırmanıza göre değiştirin
  static const String _computerIp =
      '192.168.105.224'; // Kendi IP adresinizle değiştirin

  // IPv6 loopback adresi - bazı ağlarda IPv4 yerine IPv6 çalışabilir
  static const String _computerIpv6 = '[::1]';

  // IP seçimi için flag'ler
  static const bool useRealDeviceIp = true;
  static const bool useIpv6 = false; // IPv6 kullanmak için true yapın

  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      if (useIpv6) {
        return 'http://$_computerIpv6:8080';
      }
      // Emülatörler için 10.0.2.2, fiziksel cihazlar için bilgisayarın IP adresini kullanın
      return useRealDeviceIp
          ? 'http://$_computerIp:8080'
          : 'http://10.0.2.2:8080';
    } else {
      return 'http://localhost:8080';
    }
  }

  static const int apiPort = 8080;

  // Model servis URL'si için dinamik yapılandırma
  static String get modelServiceUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      if (useIpv6) {
        return 'http://$_computerIpv6:5000';
      }
      // Emülatörler için 10.0.2.2, fiziksel cihazlar için bilgisayarın IP adresini kullanın
      return useRealDeviceIp
          ? 'http://$_computerIp:5000'
          : 'http://10.0.2.2:5000';
    } else {
      return 'http://localhost:5000';
    }
  }

  static const int modelServicePort = 5000;
  // Add more service ports or URLs as needed
}
