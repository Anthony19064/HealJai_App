class Post {
  final String id;
  final String username;
  final String avatarUrl;
  final String timeAgo;
  String postText;
  int likes;
  bool isLiked;
  List<Comment> comments;
  int reposts;
  String? imageUrl;

  Post({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.timeAgo,
    required this.postText,
    this.likes = 0,
    this.isLiked = false,
    List<Comment>? comments,
    this.reposts = 0,
    this.imageUrl,
  }) : comments = comments ?? [];
}

class Comment {
  final String username;
  final String avatarUrl;
  final String text;

  Comment({
    required this.username,
    required this.avatarUrl,
    required this.text,
  });
}
