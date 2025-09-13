import 'package:healjai_project/Widgets/community/commentPopup.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/commu.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/Widgets/community/commuClass.dart';
import 'package:healjai_project/Widgets/community/photoView.dart';
import 'package:healjai_project/Widgets/community/postButton.dart';
import 'package:healjai_project/service/account.dart';

const Color kCardBorderColor = Color(0xFFCDE5CF);
const Color kLikeButtonBorderColor = Color(0xFFFFB8C3);
const Color kLikeButtonBackgroundColor = Color(0xFFFFF0F3);
const Color kCommentButtonBorderColor = Color(0xFFFFD97D);
const Color kCommentButtonBackgroundColor = Color(0xFFFFF8E5);
const Color kRepostButtonBorderColor = Color(0xFFC7C5FF);
const Color kRepostButtonBackgroundColor = Color(0xFFF2F1FF);
const Color kIconColor = Color(0xFF757575);
const Color kTextColor = Color(0xFF333333);
const Color kTimestampColor = Colors.grey;
const Color kDmBubbleColor = Color(0xFFC5E3C8);

class UserPostCard extends StatefulWidget {
  final Post post;
  final Map<String, dynamic> postNew;
  // final VoidCallback onCommentPressed;
  final VoidCallback onMoreOptionsPressed;

  const UserPostCard({
    super.key,
    required this.post,
    required this.postNew,
    // required this.onCommentPressed,
    required this.onMoreOptionsPressed,
  });

  @override
  State<UserPostCard> createState() => _UserPostCardState();
}

class _UserPostCardState extends State<UserPostCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic> userInfo = {}; // ข้อมูลของเจ้าของโพส
  int countLike = 0; // จำนวน Like ของโพส
  int countComment = 0; // จำนวน Comment ของโพส
  bool stateLike = false; // สถานะของ Like

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลทั้งหมด
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([fetchUserInfo(), fetchCountLike(), fetchStateLike(), fetchCountComment()]);
  }

  // เรียกข้อมูลเจ้าของโพส
  Future<void> fetchUserInfo() async {
    final userID = widget.postNew['userID'];
    final user = await getuserById(userID);
    if (!mounted) return;
    setState(() {
      userInfo = user;
    });
  }

  // เรียกจำนวน Like ของโพส
  Future<void> fetchCountLike() async {
    final postId = widget.postNew['_id'];
    final data = await getCountLike(postId);
    if (!mounted) return;
    setState(() {
      countLike = data;
    });
  }

  // เรียกสถานะ Like ของโพส
  Future<void> fetchStateLike() async {
    final postId = widget.postNew['_id'];
    String userId = await getUserId();
    final data = await getStateLike(postId, userId);
    final state = data['success'];
    setState(() {
      stateLike = state;
    });
  }

  // ฟังก์ชันการทำงานของปุ่ม Like
  Future<void> likeHandle() async {
    setState(() {
      countLike += stateLike ? -1 : 1;
      stateLike = !stateLike;
    });
    final postId = widget.postNew['_id'];
    String userId = await getUserId();
    await addLike(postId, userId);
  }

  // เปิด popup Comment
  Future<void> commentHandle() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return CommentsDialog(
          postId: widget.postNew['_id'], //ส่ง PostId
          onCommentAdded: () {
            setState(() {});
            fetchCountComment();
          },
        );
      },
    );
  }

   // เรียกจำนวน Comment ของโพส
  Future<void> fetchCountComment() async {
    final postId = widget.postNew['_id'];
    final data = await getCountComment(postId);
    if (!mounted) return;
    setState(() {
      countComment = data;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userName = userInfo['username'];
    final userImg = userInfo['photoURL'];
    final String postTxt = widget.postNew['infoPost'];
    final String postImg = widget.postNew['img'];

    // เวลาที่โพส
    final String isoTime = widget.postNew['createdAt'];
    DateTime postTime = DateTime.parse(isoTime);
    timeago.setLocaleMessages('th', timeago.ThMessages());
    String resultTime = timeago.format(postTime, locale: 'th');

    return ZoomIn(
      duration: Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Color(0xFF78B465), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                userImg == null
                    ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    : CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(userImg),
                    ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userName == null
                        ? Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 100,
                            height: 23,
                            color: Colors.grey,
                          ),
                        )
                        : Text(
                          userName,
                          style: GoogleFonts.mali(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: kTextColor,
                          ),
                        ),
                    const SizedBox(height: 4),
                    Text(
                      resultTime,
                      style: GoogleFonts.mali(
                        color: Color(0xFF9F9F9F),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Transform.translate(
                  offset: Offset(0, -10),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      Icons.more_horiz,
                      color: Color(0xFF464646),
                      size: 40,
                    ),
                    onPressed: widget.onMoreOptionsPressed,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                postTxt,
                style: GoogleFonts.mali(
                  fontSize: 15,
                  color: kTextColor,
                  height: 1.4,
                ),
              ),
            ),
            if (postImg.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PhotoViewScreen(imagePath: postImg),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      postImg,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: likeHandle,
                  child: InteractionButton(
                    icon:
                        stateLike == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                    iconColor: Color(0xFFFD7D7E),
                    label: '$countLike',
                    borderColor: Color(0xFFFD7D7E),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: commentHandle,
                  child: InteractionButton(
                    icon: Icons.chat_bubble_outline,
                    iconColor: Color(0xFFF5B43A),
                    label: '$countComment',
                    borderColor: Color(0xFFF5B43A),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                // ปุ่มรีโพส 
                // GestureDetector(
                //   onTap: () {},
                //   child: InteractionButton(
                //     icon: Icons.repeat,
                //     iconColor: Color(0xFF7F71FF),
                //     label: '0',
                //     borderColor: Color(0xFF7F71FF),
                //     backgroundColor: Colors.white,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
