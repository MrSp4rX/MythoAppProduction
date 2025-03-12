import 'package:flutter/material.dart';
import 'mongo_service.dart';
import 'helper.dart';

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
  double _selectedRating = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  String _timeAgo(String timestamp) {
    DateTime reviewTime = DateTime.parse(timestamp);
    Duration difference = DateTime.now().difference(reviewTime);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays < 30) {
      return "${difference.inDays} days ago";
    } else {
      return "${(difference.inDays / 30).floor()} months ago";
    }
  }

  Future<void> _fetchReviews() async {
    try {
      String novelId = widget.book['_id'];
      List<Map<String, dynamic>> fetchedReviews =
          await _mongoService.getReviewsByNovelId(novelId);
      setState(() {
        reviews = fetchedReviews;
        print(reviews);
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching reviews: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty) {
      ToastService.showToast(context, "⚠️ Review cannot be empty!");
      return;
    }
    if (_selectedRating == 0.0) {
      ToastService.showToast(context, "⚠️ Star cannot be empty!");
      return;
    }
    String novelId = widget.book['_id'];
    String userId = "some_user_id";

    try {
      await _mongoService.addReview(
          novelId, userId, _reviewController.text, _selectedRating);

      _reviewController.clear();
      setState(() {
        _selectedRating = 3.0;
      });
      ToastService.showToast(context, "✅ Review added successfully!");

      _fetchReviews();
    } catch (e) {
      print("❌ Error submitting review: $e");
      ToastService.showToast(context, "❌ Failed to add review.");
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
            ? Center(child: CircularProgressIndicator())
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reviews.isEmpty)
                          Center(
                            child: Text("No reviews yet.",
                                style: TextStyle(color: Colors.grey)),
                          )
                        else
                          ...reviews.map((review) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.grey[800],
                                        child: Icon(Icons.person,
                                            color: Colors.white),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review['user_id'] ?? "Anonymous",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            _timeAgo(review['created_at']),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < (review['rating'] ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    review['review_text'] ?? "",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  Divider(color: Colors.grey[700]),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                    SizedBox(height: 10),
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
                    TextField(
                      controller: _reviewController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Write a review...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitReview,
                        child: Text("Submit"),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
