import 'web_auth_redirect_stub.dart'
    if (dart.library.html) 'web_auth_redirect_web.dart' as redirect_impl;

void openUrlOnWeb(String url) {
  redirect_impl.redirectToUrl(url);
}

void clearUrlHashOnWeb() {
  redirect_impl.clearWebUrlHash();
}

