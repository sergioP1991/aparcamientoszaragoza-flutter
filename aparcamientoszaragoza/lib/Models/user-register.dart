class UserRegister{

  String username;
  String password;
  String urlProfile;

  UserRegister( this.username,
      this.password,
      this.urlProfile);

  @override
  String toString() {
    return 'UserRegister{username: $username, password: $password, urlProfile: $urlProfile}';
  }
}