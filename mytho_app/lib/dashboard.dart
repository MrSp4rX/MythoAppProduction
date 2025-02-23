import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mongo_service.dart';
import 'login.dart';
import 'novel_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<void> _initFuture;
  String userName = "User";
  String userEmail = "Email";
  List<Map<String, dynamic>> books = [];
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final MongoService _mongoService = MongoService();

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _loadUserInfo();
    await _fetchBooks();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('username') ?? "MrSp4rX";
      userEmail = prefs.getString('email') ?? "sparky@mythoapp.org";
    });
  }

  Future<void> _fetchBooks() async {
    try {
      List<Map<String, dynamic>> fetchedBooks = await _mongoService.getBooks();
      setState(() {
        books = fetchedBooks;
      });
    } catch (e) {
      print("❌ Fetch error: $e");
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title:
            Text("Welcome, $userName", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
              icon: Icon(Icons.logout, color: Colors.pinkAccent),
              onPressed: _logout),
        ],
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent));
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                _buildSearchBar(),
                _buildSection("Books", books),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const [
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
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
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

  Widget _buildSection(String title, List<Map<String, dynamic>> books) {
    return books.isEmpty
        ? Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("No books found!",
                    style: TextStyle(color: Colors.white70))))
        : Column(
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
                  itemBuilder: (context, index) =>
                      _buildBookCard(books[index], context),
                ),
              ),
            ],
          );
  }

  Widget _buildBookCard(Map<String, dynamic> book, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NovelScreen(
                book: book,
              ),
            ),
          );
        } catch (e) {
          print("❌ Error fetching chapters: $e");
        }
      },
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: book["cover_image"]?.isNotEmpty == true
                  ? Image.network(book["cover_image"],
                      width: 120, height: 150, fit: BoxFit.cover)
                  : Container(
                      width: 120,
                      height: 150,
                      color: Colors.grey[800],
                      child: Icon(Icons.book, color: Colors.white70, size: 50)),
            ),
            SizedBox(height: 5),
            Text(book["title"] ?? "Unknown",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
