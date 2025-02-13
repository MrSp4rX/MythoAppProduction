import 'package:flutter/material.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "User";
  String userEmail = "Email";

  final List<Map<String, String>> popularNovels = [
    {
      "title": "Insta Millionaire",
      "author": "Bug Poc",
      "image": "assets/images/a.jpg"
    },
    {
      "title": "Insta Empire",
      "author": "Mirza",
      "image": "assets/images/a.jpg"
    },
    {"title": "Saving Nora", "author": "Mirza", "image": "assets/images/a.jpg"},
    {
      "title": "Insta Millionaire",
      "author": "Bug Poc",
      "image": "assets/images/a.jpg"
    },
    {
      "title": "Insta Empire",
      "author": "Mirza",
      "image": "assets/images/a.jpg"
    },
    {"title": "Saving Nora", "author": "Mirza", "image": "assets/images/a.jpg"},
    {
      "title": "Insta Millionaire",
      "author": "Bug Poc",
      "image": "assets/images/a.jpg"
    },
    {
      "title": "Insta Empire",
      "author": "Mirza",
      "image": "assets/images/a.jpg"
    },
    {"title": "Saving Nora", "author": "Mirza", "image": "assets/images/a.jpg"},
  ];

  final List<Map<String, String>> topPicks = [
    {"title": "The Return", "author": "Mirza", "image": "assets/images/a.jpg"},
    {"title": "Saving Nora", "author": "Mirza", "image": "assets/images/a.jpg"},
    {
      "title": "Love, Lies & Lust",
      "author": "Damon",
      "image": "assets/images/a.jpg"
    },
    {"title": "The Return", "author": "Mirza", "image": "assets/images/a.jpg"},
    {"title": "Saving Nora", "author": "Mirza", "image": "assets/images/a.jpg"},
    {
      "title": "Love, Lies & Lust",
      "author": "Damon",
      "image": "assets/images/a.jpg"
    },
    {"title": "The Return", "author": "Mirza", "image": "assets/images/a.jpg"},
    {"title": "Saving Nora", "author": "Mirza", "image": "assets/images/a.jpg"},
    {
      "title": "Love, Lies & Lust",
      "author": "Damon",
      "image": "assets/images/a.jpg"
    },
  ];

  final List<Map<String, String>> favorites = [
    {
      "title": "Dark Secrets",
      "author": "John Doe",
      "image": "assets/images/a.jpg"
    },
    {
      "title": "Lost in Time",
      "author": "Jane Austen",
      "image": "assets/images/a.jpg"
    },
    {
      "title": "Mystic River",
      "author": "Robert Frost",
      "image": "assets/images/a.jpg"
    },
    {
      "title": "Dark Secrets",
      "author": "John Doe",
      "image": "assets/images/a.jpg"
    },
    {
      "title": "Lost in Time",
      "author": "Jane Austen",
      "image": "assets/images/a.jpg"
    },
    {
      "title": "Mystic River",
      "author": "Robert Frost",
      "image": "assets/images/a.jpg"
    },
    {
      "title": "Dark Secrets",
      "author": "John Doe",
      "image": "assets/images/a.jpg"
    },
    {
      "title": "Lost in Time",
      "author": "Jane Austen",
      "image": "assets/images/a.jpg"
    },
    {
      "title": "Mystic River",
      "author": "Robert Frost",
      "image": "assets/images/a.jpg"
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      userName = "MrSp4rX";
      userEmail = "sparky@mythoapp.org";
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(top: 8.0), // Adjust top margin for title
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, $userName",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                userEmail,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
                top: 8.0), // Adjust top margin for logout button
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.pinkAccent),
              onPressed: _logout,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: "Write",
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Search",
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: "Library",
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: "Store",
              backgroundColor: Colors.black),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildSearchBar(),
              ),
              buildSection("Popular on Pocket Novels", popularNovels),
              buildSection("Top Picks for You", topPicks),
              buildSection("Favorites", favorites),
              buildSection("Newly Released", favorites),
              buildSection("Dark Romance", favorites),
              buildSection("Action Story", favorites),
              buildSection("Drama", favorites),
              buildSection("Big Boss", favorites),
              buildSection("90's Novals", favorites),
              buildSection("Biography", favorites),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search",
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.search, color: Colors.white),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget buildSection(String title, List<Map<String, String>> books) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text("MORE",
                  style: TextStyle(
                      color: Colors.pinkAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 182,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              itemBuilder: (context, index) {
                return buildBookCard(books[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBookCard(Map<String, String> book) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              book["image"]!,
              width: 120,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          SizedBox(
            width: 120,
            child: Text(
              book["title"]!,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
