import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mongo_service.dart';
import 'novel_screen.dart';
import 'dart:ui';
import 'helper.dart';

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
  bool _isSearching = false;
  DateTime? _lastPressed;
  List<Map<String, dynamic>> topAuthors = [];
  List<Map<String, dynamic>> topReaders = [];
  Map<String, bool> followedAuthors = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of Indian Languages
  final List<String> indianLanguages = [
    "हिन्दी (Hindi)",
    "English (English)",
    "বাংলা (Bengali)",
    "తెలుగు (Telugu)",
    "मराठी (Marathi)",
    "தமிழ் (Tamil)",
    "اردو (Urdu)",
    "ગુજરાતી (Gujarati)",
    "മലയാളം (Malayalam)",
    "ଓଡ଼ିଆ (Odia)",
    "ਪੰਜਾਬੀ (Punjabi)",
    "ಕನ್ನಡ (Kannada)",
    "অসমীয়া (Assamese)",
    "मैथिली (Maithili)",
    "سنڌي (Sindhi)"
  ];

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _loadUserInfo();
    await _fetchBooks();
    await _fetchTopAuthors();
    await _fetchTopReaders();
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

  Future<void> _fetchTopAuthors() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    List<Map<String, dynamic>> mockAuthors = [
      {
        "name": "Amish Tripathi",
        "profile_image":
            "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      },
      {
        "name": "Chitra Banerjee",
        "profile_image":
            "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      },
      {
        "name": "Devdutt Pattanaik",
        "profile_image":
            "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      },
      {
        "name": "Ashwin Sanghi",
        "profile_image":
            "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      },
      {
        "name": "Ramesh Menon",
        "profile_image":
            "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      }
    ];

    setState(() {
      topAuthors = mockAuthors;
      for (var author in topAuthors) {
        followedAuthors[author["name"]] = false;
      }
    });
  }

  Future<void> _fetchTopReaders() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    List<Map<String, dynamic>> mockAuthors = [
      {
        "name": "Amish Tripathi",
        "profile_image":
            "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      },
      {
        "name": "Chitra Banerjee",
        "profile_image":
            "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      },
      {
        "name": "Devdutt Pattanaik",
        "profile_image":
            "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      },
      {
        "name": "Ashwin Sanghi",
        "profile_image":
            "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      },
      {
        "name": "Ramesh Menon",
        "profile_image":
            "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      }
    ];

    setState(() {
      topReaders = mockAuthors;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    String? selectedLanguage;
    final ScrollController _scrollController = ScrollController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.5), // Dim effect
                  ),
                ),
                Center(
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: anim1,
                      curve: Curves.easeOutBack,
                    ),
                    child: AlertDialog(
                      backgroundColor: Colors.black,
                      title: Text(
                        "Select Language",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 400,
                            child: Scrollbar(
                              thumbVisibility: true,
                              controller: _scrollController,
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: indianLanguages.map((lang) {
                                    return RadioListTile<String>(
                                      value: lang,
                                      groupValue: selectedLanguage,
                                      activeColor: Colors.pinkAccent,
                                      title: Text(lang,
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedLanguage = value;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(),
                                onPressed: () => Navigator.pop(context),
                                child: Text("CANCEL",
                                    style: TextStyle(
                                        color: Colors.pinkAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(),
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (selectedLanguage != null) {
                                    ToastService.showToast(
                                        context, "$selectedLanguage Selected");
                                    print(
                                        "Selected Language: $selectedLanguage");
                                  }
                                },
                                child: Text("OK",
                                    style: TextStyle(
                                        color: Colors.pinkAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? "Good Morning!"
        : (now.hour < 17 ? "Good Noon!" : "Good Eve!");

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastPressed == null ||
            now.difference(_lastPressed!) > Duration(seconds: 2)) {
          _lastPressed = now;
          ToastService.showToast(context, "Press BACK again to exit",
              duration: Duration(seconds: 2));
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        drawer: Drawer(
          backgroundColor: Colors.black,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.pinkAccent),
                child: Text(
                  "Menu",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.white),
                title: Text("Home", style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text("Settings", style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.white),
                title: Text("About", style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
            ],
          ),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: IconButton(
                  icon: Icon(Icons.menu, color: Colors.pinkAccent),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
              Expanded(
                child: _isSearching
                    ? TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search for Novel or Artist",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        autofocus: true,
                      )
                    : Text(
                        greeting,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis, // Prevents overflow
                      ),
              ),
            ],
          ),
          actions: [
            if (!_isSearching)
              IconButton(
                icon: Icon(Icons.language, color: Colors.pinkAccent),
                onPressed: () => _showLanguageSelectionDialog(context),
              ),
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search,
                  color: Colors.pinkAccent),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                });
              },
            ),
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
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  _buildSection("Trending Now", books),
                  _buildSection("Continue Reading", books),
                  _buildAuthorsSection("Top Authors", topAuthors),
                  _buildSection("New Arrivals", books),
                  _buildSection("Recently Updated", books),
                  _buildReadersSection("Top Readers", topReaders),
                  _buildSection("Premium Exclusive", books),
                  _buildSection("Top Picks for You", books),
                  _buildSection("Top Rated Novels", books),
                  _buildSection("Completed Novels", books),
                  _buildSection("Community Picks", books),
                  _buildSection("Editor's Picks", books),
                  _buildSection("Flash Recommendation", books),
                  _buildSection("More Novels", books),
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
      ),
    );
  }

  Widget _buildReadersSection(
      String title, List<Map<String, dynamic>> readers) {
    return readers.isEmpty
        ? Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("No readers found!",
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
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: readers.length,
                  itemBuilder: (context, index) =>
                      _buildReaderCard(readers[index]),
                ),
              ),
            ],
          );
  }

  Widget _buildReaderCard(Map<String, dynamic> reader) {
    return Container(
      width: 90,
      margin: EdgeInsets.only(right: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50), // Circular image
            child: reader["profile_image"]?.isNotEmpty == true
                ? Image.network(reader["profile_image"],
                    width: 80, height: 80, fit: BoxFit.cover)
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[800],
                    child: Icon(Icons.person, color: Colors.white70, size: 40)),
          ),
          SizedBox(height: 5),
          Text(reader["name"] ?? "Unknown",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAuthorCard(Map<String, dynamic> author) {
    String authorName = author["name"] ?? "Unknown";
    bool isFollowed = followedAuthors[authorName] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          followedAuthors[authorName] = !isFollowed; // Toggle follow state
        });
      },
      child: Container(
        width: 90,
        margin: EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Stack(
              children: [
                // Circular Border
                Container(
                  padding: EdgeInsets.all(3), // Space for border effect
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFollowed
                          ? Colors.green
                          : Colors.white, // ✅ Green if followed
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50), // Circular image
                    child: author["profile_image"]?.isNotEmpty == true
                        ? Image.network(author["profile_image"],
                            width: 80, height: 80, fit: BoxFit.cover)
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[800],
                            child: Icon(Icons.person,
                                color: Colors.white70, size: 40)),
                  ),
                ),

                // Follow/Unfollow Icon
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isFollowed ? Colors.green : Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFollowed ? Icons.check : Icons.add, // ✅ or ➕
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
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

  Widget _buildAuthorsSection(
      String title, List<Map<String, dynamic>> authors) {
    return authors.isEmpty
        ? Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("No authors found!",
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
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: authors.length,
                  itemBuilder: (context, index) =>
                      _buildAuthorCard(authors[index]),
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
              builder: (context) => NovelScreen(book: book),
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
