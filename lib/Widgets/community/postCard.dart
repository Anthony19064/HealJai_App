import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healjai_project/Widgets/community/commentPopup.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/commu.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/Widgets/community/photoView.dart';
import 'package:healjai_project/Widgets/community/postButton.dart';
import 'package:healjai_project/service/account.dart';

class UserPostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  // final VoidCallback onCommentPressed;
  final VoidCallback onMoreOptionsPressed;

  const UserPostCard({
    super.key,
    required this.post,
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
    await Future.wait([
      fetchUserInfo(),
      fetchCountLike(),
      fetchStateLike(),
      fetchCountComment(),
    ]);
  }

  // เรียกข้อมูลเจ้าของโพส
  Future<void> fetchUserInfo() async {
    final userID = widget.post['userID'];
    final user = await getuserById(userID);
    if (!mounted) return;
    setState(() {
      userInfo = user;
    });
  }

  // เรียกจำนวน Like ของโพส
  Future<void> fetchCountLike() async {
    final postId = widget.post['_id'];
    final data = await getCountLike(postId);
    if (!mounted) return;
    setState(() {
      countLike = data;
    });
  }

  // เรียกสถานะ Like ของโพส
  Future<void> fetchStateLike() async {
    final postId = widget.post['_id'];
    String userId = await getUserId();
    final data = await getStateLike(postId, userId);
    final state = data['success'];
    if (!mounted) return;
    setState(() {
      stateLike = state;
    });
  }

  // ฟังก์ชันการทำงานของปุ่ม Like
  Future<void> likeHandle() async {
    if (!mounted) return;
    setState(() {
      countLike += stateLike ? -1 : 1;
      stateLike = !stateLike;
    });
    final postId = widget.post['_id'];
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
          postId: widget.post['_id'], //ส่ง PostId
          onCommentAdded: () {
            if (!mounted) return;
            setState(() {});
            fetchCountComment();
          },
        );
      },
    );
  }

  // เรียกจำนวน Comment ของโพส
  Future<void> fetchCountComment() async {
    final postId = widget.post['_id'];
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
    final userImg =
        userInfo['photoURL'].toString().trim().isNotEmpty
            ? userInfo['photoURL']
            : "https://firebasestorage.googleapis.com/v0/b/healjaiapp-60ec3.firebasestorage.app/o/AssetsInApp%2Fprofile.png?alt=media&token=8cdff07d-64e1-4d02-b83d-af54648f52a0";
    final String postTxt = widget.post['infoPost'];
    final String postImg = widget.post['img'];

    // เวลาที่โพส
    final String isoTime = widget.post['createdAt'];
    DateTime postTime = DateTime.parse(isoTime);
    timeago.setLocaleMessages('th', timeago.ThMessages());
    String resultTime = timeago.format(postTime, locale: 'th');

    return ZoomIn(
      duration: Duration(milliseconds: 700),
      child: Container(
        padding: const EdgeInsets.all(15.0),
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
                      backgroundImage: CachedNetworkImageProvider(userImg),
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
                            fontSize: 18,
                            color: Color(0xFF78B465),
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
                GestureDetector(
                  onTap: widget.onMoreOptionsPressed,
                  child: Transform.translate(
                    offset: Offset(0, -10),
                    child: SvgPicture.asset(
                      "assets/icons/more.svg",
                      width: 40,
                      height: 40,
                      color: Color(0xFF78B465),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              child: Text(
                postTxt,
                style: GoogleFonts.mali(
                  fontSize: 15,
                  color: Color(0xFF464646),
                  height: 1.4,
                ),
              ),
            ),
            if (postImg.trim().isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 16),
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
                    child: CachedNetworkImage(
                      imageUrl: postImg,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Shimmer.fromColors(
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
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Icon(Icons.error, color: Colors.red),
                          ),
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
