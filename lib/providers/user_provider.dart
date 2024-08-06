import 'package:flutter/material.dart';
import 'package:echo_emotions/models/user.dart';

class UserProvider extends ChangeNotifier {
  MyUser? _user;

  MyUser? get user => _user;

  void setUser(MyUser user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
