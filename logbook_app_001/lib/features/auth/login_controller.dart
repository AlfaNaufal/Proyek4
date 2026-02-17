class LoginController {
  // final Map<String, String> _validuser = {
  //   "username": "admin123",
  //   "user1": "password1",
  //   "user2": "password2",
  // };
  final List<Map<String, String>> _validuser = [
    {"username": "admin", "password": "admin123"},
    {"username": "user1", "password": "pw1"},
    {"username": "user2", "password": "pw2"},
  ];

  bool login(Map<String, String> validUser) {
    for (var user in _validuser) {
      // print(user);
      if (validUser["username"] == user["username"] &&
          validUser["password"] == user["password"]) {
        return true;
      }
    }
    return false;
  }
}
