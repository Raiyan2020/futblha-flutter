class MemoryCacheManager {
  static final MemoryCacheManager _instance = MemoryCacheManager._private();

  static MemoryCacheManager get instance {
    return _instance;
  }

  static String? _lang;
  static String? _token;

  static const String keyLogin = "loginModel";
  static const String keyToken = "token";

  MemoryCacheManager._private();

  Future<void> init() async {}

  void setApiToken(String token) async {
    _token = token;
  }

  String getApiToken() => _token ?? "";

  void setLanguage(String lang) {
    _lang = lang;
  }

  String getLanguage() => _lang ?? "en";
}
