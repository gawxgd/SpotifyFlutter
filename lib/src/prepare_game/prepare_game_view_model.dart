import 'package:flutter/material.dart';

class PrepareGameViewModel extends ChangeNotifier {
  String _gameMode = 'Standard';
  String get gameMode => _gameMode;
  set gameMode(String value) {
    _gameMode = value;
    notifyListeners();
  }

  String _rounds = '5';
  String get rounds => _rounds;
  set rounds(String value) {
    _rounds = value;
    notifyListeners();
  }

  String _password = '';
  String get password => _password;
  set password(String value) {
    _password = value;
    notifyListeners();
  }

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;
  set isPasswordVisible(bool value) {
    _isPasswordVisible = value;
    notifyListeners();
  }

  bool get isValid =>
      _rounds.isNotEmpty &&
      int.tryParse(_rounds) != null &&
      _password.isNotEmpty;
}
