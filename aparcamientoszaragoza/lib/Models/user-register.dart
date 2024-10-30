class UserRegister{

  String username;
  String mail;
  String password;
  String urlProfile;
  String phoneNumber;

  UserRegister(
      this.username,
      this.mail,
      this.password,
      this.urlProfile,
      this.phoneNumber);

  @override
  String toString() {
    return 'UserRegister{username: $username, mail: $mail, password: $password, urlProfile: $urlProfile}, phoneNumber: $phoneNumber';
  }

}