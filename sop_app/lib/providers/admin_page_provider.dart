import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sop_app/models/sop_request.dart';
import 'package:sop_app/services/database_service.dart';

class AdminPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  ValueNotifier<List<SOPRequest>?> sopRequestsNotifier = ValueNotifier<List<SOPRequest>?>(null);

  AdminPageProvider() {
    _db = GetIt.instance.get<DatabaseService>();
    _initializeSopRequests();
  }

  Future<void> _initializeSopRequests() async {
    List<SOPRequest> requests = await _db.getSopRequests();
    sopRequestsNotifier.value = requests;
  }
}
