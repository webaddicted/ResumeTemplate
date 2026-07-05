import 'dart:io';

/// Custom HTTP overrides for development and testing
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Allow self-signed certificates for development
        // In production, this should be false or properly configured
        return true;
      };
  }
}

