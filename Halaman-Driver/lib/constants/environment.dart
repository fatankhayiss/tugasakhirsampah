enum AppEnvironment { dev, production }

class Environment {
  // Switch this to change environment across the app
  static const AppEnvironment current = AppEnvironment.dev;

  static String get baseUrl {
    switch (current) {
      case AppEnvironment.dev:
        return 'http://192.168.110.62/tugasakhirsampah/bank_sampah/';
      case AppEnvironment.production:
        return 'https://itrashy.triki.cloud/';
    }
  }
}
