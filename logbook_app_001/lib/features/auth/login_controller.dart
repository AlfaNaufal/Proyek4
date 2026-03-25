class LoginController {
  // final Map<String, String> _validuser = {
  //   "username": "admin123",
  //   "user1": "password1",
  //   "user2": "password2",
  // };
  // final List<Map<String, String>> _validuser = [
  //   {"username": "admin", "password": "123"},
  //   {"username": "ketua", "password": "k123"},
  //   {"username": "anggota1", "password": "a123"},
  //   {"username": "anomali", "password": "anomali"},
  // ];

  final List<Map<String, String>> _validuser = [
      {
        "username": "admin",
        "password": "123",
        "teamId": "team_1",
        "uid": "0",
        "role": "Ketua",
      },
      {
        "username": "ketua",
        "password": "123",
        "teamId": "team_1",
        "uid": "1",
        "role": "Ketua",
      },
      {
        "username": "anggota1",
        "password": "123",
        "teamId": "team_1",
        "uid": "2",
        "role": "Anggota",
      },
      {
        "username": "anomali",
        "password": "123",
        "teamId": "team_2", 
        "uid": "3",
        "role": "Ketua",
      }
    ];

  // bool login(Map<String, String> validUser) {
  //   for (var user in _validuser) {
  //     // print(user);
  //     if (validUser["username"] == user["username"] &&
  //         validUser["password"] == user["password"]) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  Map<String, String>? login(String username, String password) {
    for (var user in _validuser) {
      if (user["username"] == username && user["password"] == password) {
        return user;
      }
    }
    return null;
  }
}
