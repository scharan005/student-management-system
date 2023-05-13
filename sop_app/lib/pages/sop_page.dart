import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sop_app/pages/admin_page.dart';
import 'package:sop_app/providers/sop_page_provider.dart';

import 'package:sop_app/services/database_service.dart';
import 'package:sop_app/widgets/custom_input_fields.dart';
import 'package:sop_app/widgets/rounded_button.dart';
import 'package:sop_app/widgets/top_bar.dart';

class SopPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SopPageState();
  }
}

class _SopPageState extends State<SopPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late DatabaseService _db;

  String? _bitsid;
  String? _name;
  String? _cgpa;
  String? _worktitle;
  String? _email;
  DateTime? _submittedon;

  final _sopFormKey = GlobalKey<FormState>();

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
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                'Statement of Purpose',
              ),
              SizedBox(
                height: _deviceHeight * 0.02,
              ),
              _sopForm(),
              SizedBox(
                height: _deviceHeight * 0.02,
              ),
              _sopButton(sopProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sopForm() {
    return Container(
      child: Form(
        key: _sopFormKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextFormField(
                  onSaved: (_value) {
                    setState(() {
                      _bitsid = _value;
                    });
                  },
                  regEx: r'.{8,}',
                  hintText: "Bits ID",
                  obscureText: false),
              SizedBox(height: 16),
              CustomTextFormField(
                  onSaved: (_value) {
                    setState(() {
                      _name = _value;
                    });
                  },
                  regEx: r'.{6,}',
                  hintText: "Full Name",
                  obscureText: false),
              SizedBox(height: 16),
              CustomTextFormField(
                  onSaved: (_value) {
                    setState(() {
                      _email = _value;
                    });
                  },
                  regEx:
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  hintText: "Email",
                  obscureText: false),
              SizedBox(height: 16),
              CustomTextFormField(
                  onSaved: (_value) {
                    setState(() {
                      _cgpa = _value;
                    });
                  },
                  regEx: r".{1,}",
                  hintText: "Cgpa",
                  obscureText: false),
              SizedBox(height: 16),
              CustomTextFormField(
                  onSaved: (_value) {
                    setState(() {
                      _worktitle = _value;
                    });
                  },
                  regEx: r'.{8,}',
                  hintText: "Type of work done",
                  obscureText: false),
            ],
          ),
        ),
      ),
    );
  }


  Widget _sopButton(SopPageProvider sopProvider) {
    return RoundedButton(
      name: "Request Sop",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        if (_sopFormKey.currentState?.validate() == true) {
          _sopFormKey.currentState?.save();
          try {
            await sopProvider.saveSopRequest(
              bitsId: _bitsid!,
              name: _name!,
              email: _email!,
              cgpa: _cgpa!,
              workTitle: _worktitle!,
              submittedon: DateTime.now(),
            );
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SOP request sent successfully')));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save SOP request')));
          }
        }
      },
    );
  }

}

