// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Web implementation of reCAPTCHA platform check using dart:js
/// ONLY used in Web builds
Future<String?> executeRecaptchaJS(String action) async {
  try {
    // En web/index.html definimos: window.getRecaptchaToken = (action) => ...
    final result = await js.context.callMethod('getRecaptchaToken', [action]);
    return result as String?;
  } catch (e) {
    return null;
  }
}

bool isRecaptchaLoadedJS() {
  try {
    return js.context.hasProperty('grecaptcha');
  } catch (e) {
    return false;
  }
}
