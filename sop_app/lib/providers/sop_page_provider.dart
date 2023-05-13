import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sop_app/models/sop_request.dart';
import 'package:sop_app/models/sop_user.dart';
import 'package:sop_app/services/database_service.dart';

class SopPageProvider extends ChangeNotifier {
  late DatabaseService _db;

  SopPageProvider() {
    _db = GetIt.instance.get<DatabaseService>();
  }

  Future<void> saveSopRequest({
    required String bitsId,
    required String name,
    required String email,
    required String cgpa,
    required String workTitle,
    required DateTime submittedon,
  }) async {
    final request = SOPRequest(
      bitsid: bitsId,
      name: name,
      email: email,
      cgpa: cgpa,
      worktitle: workTitle,
      submittedon: submittedon,
    );
    await _db.addSopRequest(request.toJSON());
    notifyListeners();
  }
}
