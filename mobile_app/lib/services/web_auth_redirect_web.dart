// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void redirectToUrl(String url) {
  html.window.location.href = url;
}

void clearWebUrlHash() {
  try {
    if (html.window.location.hash.isNotEmpty) {
      html.window.history.replaceState(null, '', html.window.location.pathname);
    }
  } catch (_) {}
}

