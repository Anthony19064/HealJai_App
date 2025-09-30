import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healjai_project/Widgets/community/createButton.dart';
import 'package:healjai_project/Widgets/community/fullCreate.dart';
import 'package:healjai_project/Widgets/community/postCard.dart';
import 'package:healjai_project/Widgets/bottom_nav.dart';
import 'package:healjai_project/Widgets/toast.dart';
import 'package:healjai_project/service/authen.dart';
import 'package:healjai_project/service/commu.dart';

class CommuScreen extends StatefulWidget {
  const CommuScreen({super.key});

  @override
  State<CommuScreen> createState() => _CommuScreenState();
}

class _CommuScreenState extends State<CommuScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allPost = []; // List ข้อมูลโพสทั้งหมด
  List<Map<String, dynamic>> myPost = [];
  int limitallPost = 5;
  int pageallPost = 1;
  bool hasMoreallPost = true;

  int limitmyPost = 5;
  int pagemyPost = 1;
  bool hasMoreMyPost = true;

  bool isLoadingMore = false;

  bool hasFetchedMyPost = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !hasFetchedMyPost) {
        fetchMyPosts();
        hasFetchedMyPost = true;
      }
    });
    fetchAllPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //ดึงโพสตัวเอง
  Future<void> fetchMyPosts() async {
    String userid = await getUserId();
    final data = await getMyposts(userid, 0, pagemyPost * limitmyPost);
    if (data.length < limitmyPost) {
      setState(() {
        hasMoreMyPost = false;
      });
    }
    if (!mounted) return;
    setState(() {
      myPost = data;
    });
  }

  //ดึงโพสตัวเองเพิ่ม
  Future<void> fetchMyMorePost() async {
    if (!hasMoreMyPost) return;
    if (isLoadingMore) return;
    setState(() {
      isLoadingMore = true;
    });
    String userid = await getUserId();
    final newPosts = await getMyposts(userid, pagemyPost, limitmyPost);
    if (newPosts.length < limitmyPost) {
      setState(() {
        hasMoreMyPost = false;
      });
    }
    setState(() {
      myPost = [...myPost, ...newPosts];
      pagemyPost++;
    });
    setState(() {
      isLoadingMore = false;
    });
  }

  // ดึงโพสทั้งหมด
  Future<void> fetchAllPosts() async {
    final data = await getPosts(0, pageallPost * limitallPost);
    if (data.length < limitallPost) {
      setState(() {
        hasMoreallPost = false;
      });
    }
    if (!mounted) return;
    setState(() {
      allPost = data;
    });
  }

  Future<void> fetchAllMorePosts() async {
    if (!hasMoreallPost) return;
    if (isLoadingMore) return;
    setState(() {
      isLoadingMore = true;
    });
    final newPosts = await getPosts(pageallPost, limitallPost);
    if (newPosts.length < limitallPost) {
      setState(() {
        hasMoreallPost = false;
      });
    }
    setState(() {
      allPost = [...allPost, ...newPosts];
      pageallPost++;
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
                await fetchAllPosts();
                await fetchMyPosts();
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
              fetchAllPosts();
              fetchMyPosts();
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
              fetchAllPosts();
              fetchMyPosts();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo is ScrollEndNotification &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 100) {
              if (_tabController.index == 0) {
                fetchAllMorePosts();
              } else {
                fetchMyMorePost();
              }
            }
            return false;
          },
          child: NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    backgroundColor: Color(0xFFFFF7EB),
                    elevation: 0,
                    floating: true,
                    snap: false,
                    pinned: false,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 230,
                    title: Column(
                      children: [
                        ZoomIn(
                          duration: Duration(milliseconds: 500),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20, top: 20),
                            child: Text(
                              "Healjai Community 💚",
                              style: GoogleFonts.mali(
                                fontSize: 27,
                                color: Color(0xFF78B465),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ),
                        ),
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
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
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
                ],
            body: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                RefreshIndicator(
                  onRefresh: fetchAllPosts,
                  color: Color(0xFF78B465),
                  backgroundColor: Colors.white,
                  child: allpost(),
                ),
                RefreshIndicator(
                  onRefresh: fetchMyPosts,
                  color: Color(0xFF78B465),
                  backgroundColor: Colors.white,
                  child: myPosts(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget myPosts() {
    return myPost.isNotEmpty
        ? CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 25,
                bottom: 15,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == myPost.length) {
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
                  final postObj = myPost[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < myPost.length - 1 ? 20 : 0,
                    ),
                    child: UserPostCard(
                      key: ValueKey(postObj['_id']),
                      post: postObj,
                      onMoreOptionsPressed: () => _showPostOptions(postObj),
                    ),
                  );
                }, childCount: myPost.length + 1),
              ),
            ),
          ],
        )
        : isLoadingMore
        ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SpinKitCircle(color: Color(0xFF78B465), size: 100.0),
        )
        : Center(
          child: Text(
            'ไม่มีโพสต์',
            style: GoogleFonts.mali(
              color: Color(0xFF464646),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
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
              if (index == allPost.length) {
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
              final postObj = allPost[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < allPost.length - 1 ? 20 : 0,
                ),
                child: UserPostCard(
                  key: ValueKey(postObj['_id']),
                  post: postObj,
                  onMoreOptionsPressed: () => _showPostOptions(postObj),
                ),
              );
            }, childCount: allPost.length + 1),
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
