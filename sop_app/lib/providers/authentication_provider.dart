import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';




import '../services/database_service.dart';
import '../services/navigation_service.dart';



import '../models/chat_user.dart';

import '../pages/home_page.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

  late ChatUser user;

  ChatUser? get currentUser => user;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();

    _auth.authStateChanges().listen((_user) {
      if (_user != null) {
        _databaseService.updateUserLastSeenTime(_user.uid);
        _databaseService.getUser(_user.uid).then(
              (_snapshot) {
            Map<String, dynamic> _userData =
            _snapshot.data()! as Map<String, dynamic>;
            user = ChatUser.fromJSON(
              {
                "uid": _user.uid,
                "name": _userData["name"],
                "email": _userData["email"],
                "last_active": _userData["last_active"],
                "image": _userData["image"],
                "isAdmin": _userData["isAdmin"] ?? false,
              },
            );
            navigateToHomePage();
          },
        );
      } else {
        if (_navigationService.getCurrentRoute() != '/login') {
          _navigationService.removeAndNavigateToRoute('/login');
        }
      }
    });
  }

  void navigateToHomePage() async {
    if (user != null) {
      Navigator.push(
        NavigationService.navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => HomePage(currentUser: user),
        ),
      );
    } else {
      print("Error: currentUser is null");
    }
  }

  Future<void> loginUsingEmailAndPassword(
      String _email, String _password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
    } on FirebaseAuthException {
      print("Error logging user into Firebase");
    } catch (e) {
      print(e);
    }
  }

  Future<String?> registerUserUsingEmailAndPassword(String _email, String _password) async {
    try {
      UserCredential _credentials = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
      String _uid = _credentials.user!.uid;

      await GetIt.instance.get<DatabaseService>().createUser(_uid, _email, "User's Name", "Placeholder Image URL");

      return _uid;
    } on FirebaseAuthException catch (e) {
      print("Error registering user: $e");
      return null;
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }





  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
