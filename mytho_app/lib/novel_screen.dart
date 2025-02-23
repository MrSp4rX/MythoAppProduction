import 'package:flutter/material.dart';
import 'mongo_service.dart';

class NovelScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  NovelScreen({required this.book});

  @override
  _NovelScreenState createState() => _NovelScreenState();
}

class _NovelScreenState extends State<NovelScreen> {
  final MongoService _mongoService = MongoService();
  final TextEditingController _reviewController = TextEditingController();
  List<Map<String, dynamic>> reviews = [];
  double _selectedRating = 3.0;
  bool isLoading = true; // FIX: Prevents UI from rendering before data is ready

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      String novelId = widget.book['_id']['\$oid'];
      List<Map<String, dynamic>> fetchedReviews =
          await _mongoService.getReviewsByNovelId(novelId);
      setState(() {
        reviews = fetchedReviews;
        isLoading = false; // FIX: Ensure UI updates only after data is ready
      });
    } catch (e) {
      print("❌ Error fetching reviews: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty) return;
    try {
      String novelId = widget.book['_id']['\$oid'];
      await _mongoService.addReview(
          novelId, _reviewController.text, _selectedRating);
      _reviewController.clear();
      setState(() {
        _selectedRating = 3.0;
      });
      _fetchReviews();
    } catch (e) {
      print("❌ Error submitting review: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.book["title"] ?? "Unknown Novel",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator()) // FIX: Show loading state
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: widget.book["cover_image"]?.isNotEmpty == true
                            ? Image.network(
                                widget.book["cover_image"],
                                width: 200,
                                height: 300,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 200,
                                height: 300,
                                color: Colors.grey[800],
                                child: Icon(Icons.book,
                                    color: Colors.white70, size: 100)),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(widget.book["title"] ?? "Unknown",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text("by ${widget.book["author"] ?? "Unknown Author"}",
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[400])),
                    SizedBox(height: 10),
                    Text(
                        widget.book["description"] ??
                            "No description available.",
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[500])),
                    SizedBox(height: 20),
                    Divider(color: Colors.grey[700]),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "👁 Views: ${widget.book["views"] ?? "0"}",
                            style: TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "⭐ ${widget.book["ratings"]?["average_rating"] ?? 'N/A'} "
                            "(${widget.book["ratings"]?["total_reviews"] ?? 0} reviews)",
                            style: TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                        "📅 Date: ${widget.book["created_at"] ?? "01/01/2026"}",
                        style: TextStyle(color: Colors.white)),
                    SizedBox(height: 20),
                    Divider(color: Colors.grey[700]),

                    Text("Reviews",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),

                    /// FIX: Wrapping `ListView.builder` in a `SizedBox`
                    SizedBox(
                      height: reviews.isEmpty ? 50 : 200, // Adjust height
                      child: reviews.isEmpty
                          ? Center(
                              child: Text("No reviews yet.",
                                  style: TextStyle(color: Colors.grey)),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: reviews.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                      reviews[index]['review_text'] ?? "",
                                      style: TextStyle(color: Colors.white)),
                                  subtitle: Text(
                                      "⭐ ${reviews[index]['rating'] ?? 'N/A'}",
                                      style: TextStyle(color: Colors.grey)),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 10),

                    // Star rating system
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedRating = index + 1.0;
                            });
                          },
                        );
                      }),
                    ),

                    // Review input field
                    TextField(
                      controller: _reviewController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Write a review...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Submit button
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitReview,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800]),
                        child: Text("Submit",
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
