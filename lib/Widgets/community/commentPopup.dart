import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/Widgets/community/commentCard.dart';
import 'package:healjai_project/Widgets/community/commuClass.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/commu.dart';

class CommentsDialog extends StatefulWidget {
  final String postId;
  final VoidCallback onCommentAdded;

  const CommentsDialog({
    required this.postId,
    required this.onCommentAdded});

  @override
  State<CommentsDialog> createState() => CommentsDialogState();
}

class CommentsDialogState extends State<CommentsDialog> {
  final _commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  
  @override
  void initState() {
    super.initState();
    fetchComment();
    print(widget.postId);
  }

  Future<void> fetchComment() async{
    final data = await getComments(widget.postId);
    setState(() {
      comments = data;
    });
  }

  Future<void> _submitComment() async{
    String userId = await getUserId();
    final data = await addComment(widget.postId, userId, _commentController.text);
    final newComment = data['data'];
    setState(() {
      comments.add(newComment);
    });
    _commentController.clear();
    widget.onCommentAdded();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7EB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
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
                  comments.isEmpty
                      ? Center(
                        child: Text(
                          'ยังไม่มีความคิดเห็น',
                          style: GoogleFonts.mali(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final Map<String, dynamic> commentObj = comments[index];
                          return CommentCard(comment: commentObj);
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
