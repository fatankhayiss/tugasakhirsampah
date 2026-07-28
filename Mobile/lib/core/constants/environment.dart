enum AppEnvironment { dev, production }

class Environment {
  // Switch this to change environment across the app
  static const AppEnvironment current = AppEnvironment.production;

  static String get baseUrl {
    switch (current) {
      case AppEnvironment.dev:
        return 'http://172.20.10.13/tugasakhirsampah/bank_sampah/';
      case AppEnvironment.production:
        return 'http://172.20.10.13/tugasakhirsampah/bank_sampah/';
    }
  }
}
