import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok/features/inbox/views/chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  static const String routeName = "chats";
  static const String routeURL = "/chats";

  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final GlobalKey<AnimatedListState> _key = GlobalKey<AnimatedListState>();

  final List<int> _items = [];
  final Duration _duration = Duration(milliseconds: 300);

  void _addItem() {
    // AanimatedList에 접근
    if (_key.currentState != null) {
      // _key.currentState!.insertItem(0); // add begin

      _key.currentState!.insertItem(
        _items.length,
        duration: _duration,
      ); // add end
      _items.add(_items.length);
    }
  }

  void _deleteItem(int index) {
    _key.currentState!.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: Container(
          color: Theme.of(context).primaryColor,
          child: _makeTile(index),
        ),
      ),
      duration: _duration,
    );
    _items.removeAt(index);
  }

  void _onChatTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(),
      ),
    );
  }

  Widget _makeTile(int index) {
    return ListTile(
      onTap: _onChatTap,
      onLongPress: () => _deleteItem(index),
      leading: CircleAvatar(
        radius: 30,
        foregroundImage: NetworkImage(
          "https://github.com/user-attachments/assets/9eefce11-9d03-4bcc-8a6a-ffd8f154e727",
        ),
        child: Text("Jim"),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "wozl ($index)",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            "20:30",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
      subtitle: Text("Do Somethig!!"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Direct Messages"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: FaIcon(
              FontAwesomeIcons.plus,
            ),
          ),
        ],
      ),
      body: AnimatedList(
        key: _key,
        padding: EdgeInsets.symmetric(vertical: 10.0),
        itemBuilder:
            (BuildContext context, int index, Animation<double> animation) {
          return FadeTransition(
            key: UniqueKey(),
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              child: _makeTile(index),
            ),
          );
        },
      ),
    );
  }
}
