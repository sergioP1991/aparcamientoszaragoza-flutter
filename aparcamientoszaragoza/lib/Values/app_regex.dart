class AppRegex {
  const AppRegex._();

  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.([a-zA-Z]{2,})+",
  );

  static final RegExp usernameRegex = RegExp(
      //r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~][a-zA-Z0-9]+\.([a-zA-Z]{2,})+");
      r"^([a-zA-Z])+");
  static final RegExp passwordRegex = RegExp(
      //r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$#!%*?&_])[A-Za-z\d@#$!%*?&_].{7,}$');
      r"^([a-zA-Z])+");

  static final RegExp urlProfileImageRegex = RegExp(
    r'(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])',
  );

}
