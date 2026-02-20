/// Stub implementation of reCAPTCHA platform check for mobile
/// Used in Android/iOS builds to avoid dart:js errors
Future<String?> executeRecaptchaJS(String action) async {
  return null;
}

bool isRecaptchaLoadedJS() {
  return false;
}
