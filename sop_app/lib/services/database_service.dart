import 'package:cloud_firestore/cloud_firestore.dart';

//Models
import '../models/chat_message.dart';

import '../models/sop_request.dart';


const String USER_COLLECTION = "Users";
const String CHAT_COLLECTION = "Chats";
const String MESSAGES_COLLECTION = "Messages";
const String SOP_COLLECTION = "Sop";
const String REQUEST_COLLECTION = 'Requests';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService() {}

  Future<void> createUser(String _uid, String _email, String _name,
      String _imageURL) async {
    try {
      await _db.collection(USER_COLLECTION).doc(_uid).set(
        {
          "email": _email,
          "image": _imageURL,
          "last_active": DateTime.now().toUtc(),
          "name": _name,
          "isAdmin": false, // Add this line
        },
      );
    } catch (e) {
      print(e);
    }
  }


  Future<DocumentSnapshot> getUser(String _uid) {
    return _db.collection(USER_COLLECTION).doc(_uid).get();
  }

  Future<QuerySnapshot> getUsers({String? name}) {
    Query _query = _db.collection(USER_COLLECTION);
    if (name != null) {
      _query = _query
          .where("name", isGreaterThanOrEqualTo: name)
          .where("name", isLessThanOrEqualTo: name + "z");
    }
    return _query.get();
  }

  Stream<QuerySnapshot> getChatsForUser(String _uid) {
    return _db
        .collection(CHAT_COLLECTION)
        .where('members', arrayContains: _uid)
        .snapshots();
  }

  Future<QuerySnapshot> getLastMessageForChat(String _chatID) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatID)
        .collection(MESSAGES_COLLECTION)
        .orderBy("sent_time", descending: true)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> streamMessagesForChat(String _chatID) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatID)
        .collection(MESSAGES_COLLECTION)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> addMessageToChat(String _chatID, ChatMessage _message) async {
    try {
      await _db
          .collection(CHAT_COLLECTION)
          .doc(_chatID)
          .collection(MESSAGES_COLLECTION)
          .add(
        _message.toJson(),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateChatData(String _chatID,
      Map<String, dynamic> _data) async {
    try {
      await _db.collection(CHAT_COLLECTION).doc(_chatID).update(_data);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeenTime(String _uid) async {
    try {
      await _db.collection(USER_COLLECTION).doc(_uid).update(
        {
          "last_active": DateTime.now().toUtc(),
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteChat(String _chatID) async {
    try {
      await _db.collection(CHAT_COLLECTION).doc(_chatID).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<DocumentReference?> createChat(Map<String, dynamic> _data) async {
    try {
      DocumentReference _chat =
      await _db.collection(CHAT_COLLECTION).add(_data);
      return _chat;
    } catch (e) {
      print(e);
    }
  }



  Future<void> addSopRequest(Map<String, dynamic> _data) async {
    try {
      // Add the current timestamp to the submittedon field
      _data['submittedon'] = Timestamp.fromDate(DateTime.now());

      print("Before saving data: $_data");

      await _db.collection(REQUEST_COLLECTION).add(_data);

      print("After saving data: $_data");
    } catch (e) {
      print("Error while saving data: $e");
    }
  }


  Future<List<SOPRequest>> getSopRequests() async {
    List<SOPRequest> sopRequests = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Requests')
        .get();

    if (snapshot.docs.isEmpty) {
      print('No documents found in the Requests collection');
    }

    snapshot.docs.forEach((doc) {
      print('Processing document: ${doc.id}'); // Log the document ID being processed

      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        try {
          sopRequests.add(SOPRequest.fromJSON(data));
        } catch (error) {
          print('Error processing document ${doc.id}: $error');
        }
      } else {
        print('Error: Document data is null for document ID: ${doc.id}');
      }
    });

    return sopRequests;
  }
  Future<void> deleteSopRequest(String id) async {
    print('Deleting SOP request with ID: $id');
    try {
      await _db.collection('Requests').doc(id).delete();
      print('SOP request deleted successfully.');
    } catch (e) {
      print('Error deleting SOP request: $e');
    }
  }

  Future<void> updateUser(String _uid, Map<String, dynamic> _data) async {
    await FirebaseFirestore.instance.collection(USER_COLLECTION).doc(_uid).update(_data);
  }



}

