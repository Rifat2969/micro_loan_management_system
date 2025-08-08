import '../models/UserModel.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final List<UserModel> _users = [];
  UserModel? currentUser;

  bool register(String name, String phone, String password) {
    if (_users.any((user) => user.phone == phone)) return false;
    _users.add(UserModel(name: name, phone: phone, password: password));
    return true;
  }

  bool login(String phone, String password) {
    final user = _users.firstWhere(
      (u) => u.phone == phone && u.password == password,
      orElse: () => UserModel(name: '', phone: '', password: ''),
    );
    if (user.phone.isNotEmpty) {
      currentUser = user;
      return true;
    }
    return false;
  }

  void logout() {
    currentUser = null;
  }
}
