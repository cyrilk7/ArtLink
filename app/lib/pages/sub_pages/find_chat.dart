import 'package:ashlink/pages/sub_pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FindChatPage extends StatefulWidget {
  final String senderId;
  final String senderEmail;
  const FindChatPage(
      {super.key, required this.senderId, required this.senderEmail});

  @override
  State<FindChatPage> createState() => _FindChatPageState();
}

class _FindChatPageState extends State<FindChatPage> {
  final TextEditingController _controller = TextEditingController();
  List _allResults = [];
  List _resultList = [];

  @override
  initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    getClientStream();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
  }

  @override
  void didChangeDependencies() {
    getClientStream();
    super.didChangeDependencies();
  }

  _onSearchChanged() {
    searchResultList();
  }

  searchResultList() {
    var showResult = [];
    if (_controller.text != "") {
      for (var clientSnapshot in _allResults) {
        var name = clientSnapshot['username'].toString().toLowerCase();

        if (name.contains(_controller.text.toLowerCase()) &&
            name != widget.senderId) {
          showResult.add(clientSnapshot);
        }
      }
    } else {
      showResult = _allResults.where((clientSnapshot) {
        var name = clientSnapshot['username'].toString().toLowerCase();
        return name != widget.senderId;
      }).toList();
    }
    setState(() {
      _resultList = showResult;
    });
  }

  getClientStream() async {
    var data = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('username')
        .get();

    setState(() {
      _allResults = data.docs;
    });

    searchResultList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(255, 248, 248, 248),
          title: GestureDetector(
            child: const Text('Cancel'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: _buildSearchInput(),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _resultList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                            senderId: widget.senderId,
                            senderEmail: widget.senderEmail,
                            receiverUserEmail: _resultList[index]['email'],
                            receiverUserId: _resultList[index]['username'],
                            phoneNumber: _resultList[index]['phone_number'],
                            receiverName:
                                '${_resultList[index]['first_name']} ${_resultList[index]['last_name']}'),
                      ),
                    );
                  },
                  child: ListTile(
                      leading: CircleAvatar(
                        radius: 29.0, // Set the desired size here
                        backgroundImage: _resultList[index]['profile_image'] !=
                                    null &&
                                _resultList[index]['profile_image'] != ""
                            ? NetworkImage(_resultList[index]['profile_image'])
                            : null, // Use profile image if available
                        child: _resultList[index]['profile_image'] == null
                            ? Text(
                                _resultList[index]['first_name'].toUpperCase(),
                                style: const TextStyle(fontSize: 18),
                              )
                            : null, // Placeholder text if no profile image
                      ),
                      title: Text(_resultList[index]['username']),
                      subtitle: Text(_resultList[index]['first_name'])),
                );
              },
            )
          ],
        ));
  }

  Widget _buildSearchInput() {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search..',
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: GestureDetector(
          onTap: () {},
          child: Icon(Icons.search, color: Colors.grey[600]),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      ),
    );
  }
}
