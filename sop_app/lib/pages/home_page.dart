//Packages
import 'package:flutter/material.dart';
import 'package:sop_app/pages/sop_page.dart';
import 'package:sop_app/pages/admin_page.dart';

//Pages
import '../pages/chats_page.dart';
import '../pages/users_page.dart';
import '../models/chat_user.dart';


class HomePage extends StatefulWidget {
  final ChatUser currentUser;

  HomePage({required this.currentUser});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ChatsPage(),
      UsersPage(),
      widget.currentUser.isAdmin ? AdminPage() : SopPage(),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (_index) {
          setState(() {
            _currentPage = _index;
          });
        },
        items: [
          BottomNavigationBarItem(
            label: "Chats",
            icon: Icon(
              Icons.chat_bubble_sharp,
            ),
          ),
          BottomNavigationBarItem(
            label: "Users",
            icon: Icon(
              Icons.supervised_user_circle_sharp,
            ),
          ),
          BottomNavigationBarItem(
            label: "Sop",
            icon: Icon(
              Icons.article_rounded,
            ),
          ),

        ],
      ),
    );
  }
}
