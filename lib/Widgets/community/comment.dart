import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/Widgets/community/commuClass.dart';

class CommentsDialog extends StatefulWidget {
  final Post post;
  final VoidCallback onCommentAdded;

  const CommentsDialog({required this.post, required this.onCommentAdded});

  @override
  State<CommentsDialog> createState() => CommentsDialogState();
}

class CommentsDialogState extends State<CommentsDialog> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.isNotEmpty) {
      final newComment = Comment(
        username: 'Me',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        text: _commentController.text,
      );

      setState(() {
        widget.post.comments.add(newComment);
      });
      widget.onCommentAdded();
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7EB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(62, 0, 0, 0),
              blurRadius: 20,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ความคิดเห็น',
                  style: GoogleFonts.mali(
                    color: const Color(0xFF78B465),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child:
                  widget.post.comments.isEmpty
                      ? Center(
                        child: Text(
                          'ยังไม่มีความคิดเห็น',
                          style: GoogleFonts.mali(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: widget.post.comments.length,
                        itemBuilder: (context, index) {
                          final comment = widget.post.comments[index];
                          final cardColor =
                              index.isEven
                                  ? Colors.white
                                  : const Color(0xFFF1F8E9);

                          return Card(
                            color: cardColor,
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      comment.avatarUrl,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.username,
                                          style: GoogleFonts.mali(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment.text,
                                          style: GoogleFonts.mali(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              autofocus: true,
              style: GoogleFonts.mali(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "แสดงความคิดเห็นของคุณ...",
                hintStyle: GoogleFonts.mali(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF78B465)),
                  onPressed: _submitComment,
                ),
              ),
              onSubmitted: (_) => _submitComment(),
            ),
          ],
        ),
      ),
    );
  }
}
