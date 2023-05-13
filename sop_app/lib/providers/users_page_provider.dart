import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


//Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/chat_user.dart';
import '../models/chat.dart';

//Pages
import '../pages/chat_page.dart';
import 'package:collection/collection.dart';

class UsersPageProvider extends ChangeNotifier {
  ChatUser? _currentUser;

  ChatUser? get currentUser => _currentUser;
  AuthenticationProvider _auth;

  late DatabaseService _database;
  late NavigationService _navigation;
  late FirebaseMessaging _firebaseMessaging;

  List<ChatUser>? users;
  late List<ChatUser> _selectedUsers;
  late FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  List<ChatUser> get selectedUsers {
    return _selectedUsers;
  }

  UsersPageProvider(this._auth) {
    _selectedUsers = [];
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    getUsers();
    fetchUserData();
    _firebaseMessaging = FirebaseMessaging.instance;
    _configureFirebaseMessaging();
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeLocalNotificationsPlugin();
  }

  void _initializeLocalNotificationsPlugin() async {
    AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    IOSInitializationSettings iosInitializationSettings = IOSInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);
    await _localNotificationsPlugin.initialize(initializationSettings);
  }
  Future<void> _showNotification(Map<String, dynamic> notificationData) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('chat_message_channel', 'Chat Messages',
        importance: Importance.max, priority: Priority.high, showWhen: true);
    const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    await _localNotificationsPlugin.show(
        0,
        notificationData['title'].toString(),
        notificationData['body'].toString(),
        platformChannelSpecifics);
  }



  void _configureFirebaseMessaging() {
    // Add the subscription code
    _subscribeToTopic();

    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'high_importance_channel', // Make sure this matches the channel ID above
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );
    // The rest of the existing code
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('Initial message: $message');
      }
    });
    _firebaseMessaging.getToken().then((String? token) {
      print("Firebase Messaging Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: $message');
      Map<String, dynamic> notificationData = {
        'title': message.notification!.title,
        'body': message.notification!.body,
      };
      _showNotification(notificationData);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened message: $message');
    });
  }


  _subscribeToTopic() async {
    await _firebaseMessaging.subscribeToTopic('sop_app_updates');
    print('Subscribed to sop_app_updatas');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchUserData() async {
    // Fetch the user data from the database
    DocumentSnapshot _userSnapshot = await _database.getUser(_auth.user.uid);
    Map<String, dynamic> _userData = _userSnapshot.data() as Map<String, dynamic>;
    _userData["uid"] = _userSnapshot.id;

    // Set the _currentUser property
    _currentUser = ChatUser.fromJSON(_userData);
    notifyListeners();
  }

  void getUsers({String? name}) async {
    _selectedUsers = [];
    try {
      _database.getUsers(name: name).then(
            (_snapshot) {
          users = _snapshot.docs.map(
                (_doc) {
              Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
              _data["uid"] = _doc.id;
              _data["isAdmin"] = _data["isAdmin"] ?? false;
              return ChatUser.fromJSON(_data);
            },
          ).toList();
          notifyListeners();
        },
      );
    } catch (e) {
      print("Error getting users.");
      print(e);
    }
  }

  void updateSelectedUsers(ChatUser _user) {
    if (_selectedUsers.contains(_user)) {
      _selectedUsers.remove(_user);
    } else {
      _selectedUsers.add(_user);
    }
    notifyListeners();
  }

  void createChat() async {
    // Check if the current user is an admin
    ChatUser? currentUser;
    if (users != null) {
      currentUser = users!
          .where((user) => user.uid == _auth.user.uid)
          .firstOrNull; // Use firstOrNull from the collection package
    }

    print('Current user: ${currentUser?.uid}');
    print('Is admin? ${currentUser?.isAdmin}');

    if (currentUser != null && currentUser.isAdmin) {
      try {
        // Your existing code for chat creation
        List<String> _membersIds = _selectedUsers.map((_user) => _user.uid).toList();
        _membersIds.add(_auth.user.uid);
        bool _isGroup = _selectedUsers.length > 1;
        DocumentReference? _doc = await _database.createChat(
          {
            "is_group": _isGroup,
            "is_activity": false,
            "members": _membersIds,
          },
        );

        //Navigate To Chat Page
        List<ChatUser> _members = [];
        for (var _uid in _membersIds) {
          DocumentSnapshot _userSnapshot = await _database.getUser(_uid);
          Map<String, dynamic> _userData = _userSnapshot.data() as Map<String, dynamic>;
          _userData["uid"] = _userSnapshot.id;
          _members.add(ChatUser.fromJSON(_userData));
        }
        ChatPage _chatPage = ChatPage(
          chat: Chat(
              uid: _doc!.id,
              currentUserUid: _auth.user.uid,
              members: _members,
              messages: [],
              activity: false,
              group: _isGroup),
        );
        _selectedUsers = [];
        notifyListeners();
        _navigation.navigateToPage(_chatPage);
      } catch (e) {
        print("Error creating chat.");
        print(e);
      }
    } else {
      print("Only admin users can create chats.");
    }
  }











}
