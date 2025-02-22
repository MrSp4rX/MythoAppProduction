import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mongo_service.dart';
import 'login.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "User";
  String userEmail = "Email";
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> books = [];
  int _selectedIndex = 0;
  final MongoService mongoService = MongoService();
  bool isLoading = true; // Loading state management

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  /// Loads user info and fetches books
  Future<void> _initializeDashboard() async {
    await _loadUserInfo();
    await _fetchBooks();
  }

  /// Loads user data from SharedPreferences and prints all stored data
  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load user info
    setState(() {
      userName = prefs.getString('username') ?? "MrSp4rX";
      userEmail = prefs.getString('email') ?? "sparky@mythoapp.org";
    });

    // Debug: Print all SharedPreferences data
    print("🔹 All SharedPreferences Data:");
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      print("Printing Shared Prefrerences Data\n\n\n");
      print("$key: ${prefs.get(key)}");
      print("Printed Shared Prefrerences Data\n\n\n");
    }
  }

  Future<void> _fetchBooks() async {
    try {
      List<Map<String, dynamic>> fetchedBooks = await mongoService.getBooks();
      setState(() {
        books = fetchedBooks;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Fetch error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Logs out user by clearing SharedPreferences and navigating to login screen
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  /// Handles bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome, $userName",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(userEmail,
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.logout, color: Colors.pinkAccent),
                onPressed: _logout),
          ],
        ),
        body: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Colors.pinkAccent))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: buildSearchBar(),
                      ),
                      buildSection("Books", books),
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Artist',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Saved',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Colors.black,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  /// Builds the search bar
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

  /// Builds the book section
  Widget buildSection(String title, List<Map<String, dynamic>> books) {
    return books.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "No books found!",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          )
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

  /// Builds a book card
  Widget buildBookCard(Map<String, dynamic> book) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: book["cover_image"] != null && book["cover_image"].isNotEmpty
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
