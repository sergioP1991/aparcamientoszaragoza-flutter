class UserRegister{

  String username;
  String mail;
  String password;
  String urlProfile;
  String mobileNumber;

  UserRegister(
      this.username,
      this.mail,
      this.password,
      this.urlProfile,
      this.mobileNumber);

  @override
  String toString() {
    return 'UserRegister{username: $username, mail: $mail, password: $password, urlProfile: $urlProfile, mobileNumber: $mobileNumber}';
  }

}