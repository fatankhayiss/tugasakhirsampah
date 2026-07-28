enum AppEnvironment { dev, production }

class Environment {
  // Switch this to change environment across the app
  // static const AppEnvironment current = AppEnvironment.production;
  static const AppEnvironment current = AppEnvironment.dev;

  static String get baseUrl {
    switch (current) {
      case AppEnvironment.dev:
        return 'http://10.128.52.227/tugasakhirsampah/bank_sampah/';
      case AppEnvironment.production:
        return 'http://192.168.129.68/tugasakhirsampah/bank_sampah/';
    }
  }
}
