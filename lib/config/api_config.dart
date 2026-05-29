class ApiConfig {
  ApiConfig._();

  static const String _defaultBaseUrl =
      'https://sift-discover-motivator.ngrok-free.dev/myKosWeb/public/api';

  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static String get baseUrl {
    final configured = _envBaseUrl.trim().isEmpty
        ? _defaultBaseUrl
        : _envBaseUrl;

    return configured;
  }
}
