class UserRegister{

  String username;
  String mail;
  String password;
  String urlProfile;

  UserRegister(
      this.username,
      this.mail,
      this.password,
      this.urlProfile);

  @override
  String toString() {
    return 'UserRegister{username: $username, mail: $mail, password: $password, urlProfile: $urlProfile}';
  }

}