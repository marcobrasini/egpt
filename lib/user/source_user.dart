import "package:flutter/foundation.dart";
import "package:egpt/services/egpt_services.dart";


class UserSource extends ChangeNotifier {
  UserSource({required this.services});

  bool _loading = false;
  Object? _error;

  bool get isLoading => _loading;
  Object? get error => _error;

  final EGPTServices services;

  Future<void> build() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // await services.database.buildRegister();
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
