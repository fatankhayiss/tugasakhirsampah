enum AppEnvironment { dev, production }

class Environment {
  // Switch this to change environment across the app
  static const AppEnvironment current = AppEnvironment.production;

  static String get baseUrl {
    switch (current) {
      case AppEnvironment.dev:
        return 'http://192.168.31.220/tugasakhirsampah/bank_sampah/';
      case AppEnvironment.production:
        return 'http://192.168.31.220/tugasakhirsampah/bank_sampah/';
    }
  }
}
