import 'package:ashlink/pages/main_pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  TextEditingController _controller = TextEditingController();
  late String selectedOption;
  List _allResults = [];
  List _resultList = [];

  @override
  initState() {
    super.initState();
    selectedOption = 'Users';
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

        if (name.contains(_controller.text.toLowerCase())) {
          showResult.add(clientSnapshot);
        }
      }
    } else {
      showResult = List.from(_allResults);
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

  void updateSelectedOption(String option) {
    setState(() {
      selectedOption = option;
      // postsFuture = fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 248, 248, 248),
            flexibleSpace: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSearchInput(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildOption('Users'),
                    buildOption('Events'),
                    // buildOption('Option 3'),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey,
                )
              ],
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: _resultList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      username: _resultList[index]['username'],
                      thisUser: false,
                    ),
                  ),
                );
              },
              child: ListTile(
                  leading: CircleAvatar(
                    radius: 29.0, // Set the desired size here
                    backgroundImage:
                        _resultList[index]['profile_image'] != null &&
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

  Widget buildOption(String option) {
    bool isSelected = selectedOption == option;
    return GestureDetector(
      onTap: () => updateSelectedOption(option),
      child: Column(
        children: [
          Text(
            option,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? const Color.fromARGB(255, 70, 111, 201)
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 1.0), // Spacer between text and underline
          Container(
            width: 50.0,
            height: 2.0,
            color: isSelected
                ? const Color.fromARGB(255, 70, 111, 201)
                : const Color.fromARGB(255, 248, 248, 248),
          ),
        ],
      ),
    );
  }
}
