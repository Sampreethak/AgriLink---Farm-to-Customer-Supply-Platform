import 'web_auth_redirect_stub.dart'
    if (dart.library.html) 'web_auth_redirect_web.dart';

void openUrlOnWeb(String url) {
  redirectToUrl(url);
}
