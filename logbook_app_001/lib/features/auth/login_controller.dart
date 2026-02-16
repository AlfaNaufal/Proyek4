class LoginController {
  final String _validusername = "admin";
  final String _validpassword = "admin123";

  bool login(String uname, String password) {
    if (uname == _validusername && password == _validpassword) {
      return true;
    }
    return false;
  }
}
