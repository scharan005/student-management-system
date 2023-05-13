import 'package:cloud_firestore/cloud_firestore.dart';

class SOPRequest {
  final String name;
  final String bitsid;
  final String email;
  final String cgpa;
  final String worktitle;
  late DateTime submittedon;

  SOPRequest({
    required this.name,
    required this.bitsid,
    required this.email,
    required this.cgpa,
    required this.worktitle,
    required this.submittedon,
  });

  factory SOPRequest.fromJSON(Map<String, dynamic> json) {
    DateTime? submittedOn;
    if (json['submittedon'] != null) {
      submittedOn = (json['submittedon'] as Timestamp).toDate();
    } else {
      submittedOn = DateTime.now(); // Set a default value or handle it accordingly
    }

    return SOPRequest(
      name: json['name'],
      bitsid: json['bitsid'],
      email: json['email'],
      cgpa: json['cgpa'],
      worktitle: json['worktitle'],
      submittedon: submittedOn,
    );
  }


  Map<String, dynamic> toJSON() {
    return {
      'name': name,
      'bitsid': bitsid,
      'email': email,
      'cgpa': cgpa,
      'worktitle': worktitle,
       'submittedon': submittedon,
    };
  }
}
