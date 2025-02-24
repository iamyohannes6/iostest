enum BuildEnvironment {
  development,
  staging,
  production,
}

class Environment {
  static BuildEnvironment _environment = BuildEnvironment.development;
  static String _apiUrl = 'http://localhost:8080/api';

  static void initialize(BuildEnvironment env) {
    _environment = env;
    switch (_environment) {
      case BuildEnvironment.development:
        _apiUrl = 'http://localhost:8080/api';
        break;
      case BuildEnvironment.staging:
        _apiUrl = 'https://staging-api.yourapp.com/api';
        break;
      case BuildEnvironment.production:
        _apiUrl = 'https://api.yourapp.com/api';
        break;
    }
  }

  static String get apiUrl => _apiUrl;
  static bool get isDevelopment => _environment == BuildEnvironment.development;
  static bool get isStaging => _environment == BuildEnvironment.staging;
  static bool get isProduction => _environment == BuildEnvironment.production;
} 