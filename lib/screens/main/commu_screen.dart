import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/Widgets/community/createButton.dart';
import 'package:healjai_project/Widgets/community/fullCreate.dart';
import 'package:healjai_project/Widgets/community/postCard.dart';
import 'package:healjai_project/Widgets/bottom_nav.dart';
import 'package:healjai_project/Widgets/header_section.dart';
import 'package:healjai_project/Widgets/toast.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/commu.dart';

class CommuScreen extends StatefulWidget {
  const CommuScreen({super.key});

  @override
  State<CommuScreen> createState() => _CommuScreenState();
}

class _CommuScreenState extends State<CommuScreen> {
  List<Map<String, dynamic>> post = []; // List ข้อมูลโพสทั้งหมด
  int limit = 5;
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    fetchPost();
    // ลบ scroll listener เก่าออก เพราะจะใช้ NotificationListener แทน
  }

  // ดึงโพส
  Future<void> fetchPost() async {
    final data = await getPosts(0, page * limit);
    if (data.length < limit) {
      setState(() {
        hasMore = false;
      });
    }
    if (!mounted) return;
    setState(() {
      post = data;
    });
  }

  Future<void> fetchMorePosts() async {
    if (!hasMore) return;
    if (isLoadingMore) return;
    setState(() {
      isLoadingMore = true;
    });
    final newPosts = await getPosts(page, limit);
    if (newPosts.length < limit) {
      setState(() {
        hasMore = false;
      });
    }
    setState(() {
      post = [...post, ...newPosts];
      page++;
    });
    setState(() {
      isLoadingMore = false;
    });
  }

  Future<void> _showPostOptions(Map<String, dynamic> postObj) async {
    final postID = postObj['_id'];
    final ownerPostId = postObj['userID'];
    final String myuserId = await getUserId();

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        List<Widget> options = [];
        if (ownerPostId == myuserId) {
          options.addAll([
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text('แก้ไขโพสต์', style: GoogleFonts.mali()),
              onTap: () {
                Navigator.pop(modalContext);
                _showEditPostModal(postObj);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                'ลบโพสต์',
                style: GoogleFonts.mali(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(modalContext);
                await deletePost(postID);
                if (!mounted) return;
                await fetchPost();
                showSuccessToast("ลบโพสต์สำเร็จ", "ลบโพสของคุณเรียบร้อยแล้ว");
              },
            ),
          ]);
        }
        options.add(
          ListTile(
            leading: const Icon(Icons.report),
            title: Text('รายงาน', style: GoogleFonts.mali()),
            onTap: () {
              Navigator.pop(modalContext);
              showSuccessToast(
                "รายงานโพสต์สำเร็จ",
                "ขอบคุณสำหรับการรายงานข้อมูล",
              );
            },
          ),
        );
        options.add(
          ListTile(
            leading: const Icon(Icons.save),
            title: Text('บันทึกโพสต์', style: GoogleFonts.mali()),
            onTap: () {
              Navigator.pop(modalContext);
              showSuccessToast(
                "บันทึกสำเร็จ",
                "บันทึกโพสต์เข้ารายการของคุณแล้ว",
              );
            },
          ),
        );
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7EB),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Wrap(children: options),
        );
      },
    );
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FullScreenPostCreator(
            stateEdit: false,
            onPost: () {
              fetchPost();
            },
          ),
        );
      },
    );
  }

  void _showEditPostModal(Map<String, dynamic> postOBJ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FullScreenPostCreator(
            stateEdit: true,
            postObj: postOBJ,
            onPost: () {
              fetchPost();
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widgetPost = [allpost(), allpost()];
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      bottomNavigationBar: const BottomNavBar(),
      body: RefreshIndicator(
        onRefresh: fetchPost,
        color: Color(0xFF78B465),
        backgroundColor: Colors.white,
        child: SafeArea(
          child: DefaultTabController(
            length: widgetPost.length,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollEndNotification &&
                    scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 100) {
                  fetchMorePosts();
                }
                return false;
              },
              child: NestedScrollView(
                headerSliverBuilder: (
                  BuildContext context,
                  bool innerBoxIsScrolled,
                ) {
                  return <Widget>[
                    SliverAppBar(
                      backgroundColor: const Color(0xFFFFF7EB),
                      elevation: 0,
                      floating: true, // ให้ header กลับมาเมื่อเลื่อนลง
                      snap: false, // ให้มีการ snap เมื่อเลื่อน
                      pinned: false, // ไม่ให้ติดอยู่ด้านบน
                      automaticallyImplyLeading: false, // ไม่แสดง back button
                      toolbarHeight: 230, // กำหนดความสูงของ toolbar
                      title: Column(
                        children: [
                          const HeaderSection(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: PostCreationTrigger(
                              onTap: _showCreatePostModal,
                            ),
                          ),
                        ],
                      ),
                      centerTitle: false,
                      titleSpacing: 0,
                    ),
                    SliverPersistentHeader(
                      pinned: true, // ให้ TabBar ติดอยู่ด้านบน
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          labelStyle: GoogleFonts.mali(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          labelColor: Color(0xFF78B465),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Color(0xFF78B465),
                          tabs: const [
                            Tab(text: "โพสต์ทั้งหมด"),
                            Tab(text: "โพสต์ของฉัน"),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: widgetPost
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget allpost() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(left: 15, right: 15, top: 25, bottom: 15),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == post.length) {
                return isLoadingMore
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: SpinKitCircle(
                        color: Color(0xFF78B465),
                        size: 100.0,
                      ),
                    )
                    : const SizedBox.shrink();
              }
              final postObj = post[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < post.length - 1 ? 20 : 0,
                ),
                child: UserPostCard(
                  key: ValueKey(postObj['_id']),
                  post: postObj,
                  onMoreOptionsPressed: () => _showPostOptions(postObj),
                ),
              );
            }, childCount: post.length + 1),
          ),
        ),
      ],
    );
  }
}

// สร้าง delegate สำหรับ SliverPersistentHeader
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFFFF7EB), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
