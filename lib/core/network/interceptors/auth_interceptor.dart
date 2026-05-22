import 'package:dio/dio.dart';

/// Слот под Bearer-токен. Сейчас API анонимный (`external_id`), но
/// порядок интерсепторов (Auth → Locale → Retry → Logging) уже зафиксирован,
/// чтобы добавление авторизации в будущем не требовало переделки клиента.
///
/// Когда появятся реальные токены — заменить [tokenProvider] на инжектируемый
/// источник из `SecureStorage`/Auth-сервиса.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({String? Function()? tokenProvider})
    : _tokenProvider = tokenProvider ?? _emptyToken;

  static String? _emptyToken() => null;

  final String? Function() _tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
