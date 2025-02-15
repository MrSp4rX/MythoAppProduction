import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "User";
  String userEmail = "Email";
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> popularNovels = [];
  List<Map<String, dynamic>> topPicks = [];
  List<Map<String, dynamic>> favorites = [];
  List<Map<String, dynamic>> books = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchBooks();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      userName = "MrSp4rX";
      userEmail = "sparky@mythoapp.org";
    });
  }

  Future<void> _fetchBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token =
        prefs.getString('auth_token'); // ✅ Fix: Get token as String

    if (token == null || token.isEmpty) {
      print("Error: No auth token found.");
      return;
    }

    final url = Uri.parse(
        "https://f059-2409-40e3-18f-61b6-352e-4ed5-570f-6846.ngrok-free.app/getBooks");

    try {
      final response =
          await http.get(url, headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('books') && data['books'] is List) {
          setState(() {
            books = List<Map<String, dynamic>>.from(data['books']);
          });
          print("Books fetched: ${books}");
        } else {
          print("Error: Invalid books data format.");
        }
      } else {
        print("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, $userName",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(userEmail, style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.logout, color: Colors.pinkAccent),
              onPressed: _logout),
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
              buildSection("Books", books),
              // buildSection("Popular on Pocket Novels", popularNovels),
              // buildSection("Top Picks for You", topPicks),
              // buildSection("Favorites", favorites),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
      controller: searchController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search",
        hintStyle: TextStyle(color: Colors.white70),
        suffixIcon: IconButton(
            icon: Icon(Icons.search, color: Colors.pinkAccent),
            onPressed: () {}),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget buildSection(String title, List<Map<String, dynamic>> books) {
    return books.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
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

  Widget buildBookCard(Map<String, dynamic> book) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: book["cover_image"] != null
                ? Image.network(book["cover_image"],
                    width: 120, height: 150, fit: BoxFit.cover)
                : Container(
                    width: 120,
                    height: 150,
                    color: Colors.grey[800],
                    child: Icon(Icons.book, color: Colors.white70, size: 50),
                  ),
          ),
          SizedBox(height: 5),
          Text(
            book["title"] ?? "Unknown",
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
