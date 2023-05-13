import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sop_app/models/sop_request.dart';
import 'package:sop_app/services/database_service.dart';
import 'package:sop_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';

import 'package:sop_app/providers/sop_page_provider.dart';
import 'package:timeago/timeago.dart' as timeago;




class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late double _deviceHeight;
  late double _deviceWidth;


  late DatabaseService _db;
  final ValueNotifier<List<SOPRequest>?> _sopRequests = ValueNotifier<List<SOPRequest>?>(null);

  @override
  void initState() {
    super.initState();
    _db = GetIt.instance.get<DatabaseService>();
    _fetchSopRequests();
  }

  Future<void> _fetchSopRequests() async {
    List<SOPRequest> requests = await _db.getSopRequests();
    _sopRequests.value = requests;
  }

  @override
  Widget build(BuildContext context) {
    _db = Provider.of<DatabaseService>(context);
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    final sopProvider = Provider.of<SopPageProvider>(context);
    return _buildUI(sopProvider);
  }

  Widget _buildUI(SopPageProvider sopProvider) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                'Admin DashBoard',
              ),
              Expanded(
                child: _buildRequestList(),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildRequestList() {
    return ValueListenableBuilder<List<SOPRequest>?>(
      valueListenable: _sopRequests,
      builder: (context, requests, _) {
        if (requests == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (requests.isEmpty) {
          return Text('No requests found');
        } else {
          return SizedBox(
            height: _deviceHeight * 0.7,
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (BuildContext context, int index) {
                SOPRequest request = requests[index];
                String timeAgo = timeago.format(request.submittedon);
                return Dismissible(
                  key: Key(request.bitsid),
                  onDismissed: (direction) async {

                    await _db.deleteSopRequest(request.bitsid);
                    requests.removeAt(index);
                    _sopRequests.value = requests;
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(request.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(request.email),
                          Text(request.bitsid),
                          Text(request.worktitle),
                          Text(
                            'Submitted $timeAgo',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.delete),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }






}

