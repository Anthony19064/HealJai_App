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
import 'package:healjai_project/service/dashboard.dart';

class CommuScreen extends StatefulWidget {
  const CommuScreen({super.key});

  @override
  State<CommuScreen> createState() => _CommuScreenState();
}

class _CommuScreenState extends State<CommuScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allPost = [];
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

  // --- การดึงข้อมูล ---
  Future<void> fetchMyPosts() async {
    String userid = await getUserId();
    final data = await getMyposts(userid, 0, pagemyPost * limitmyPost);
    if (!mounted) return;
    setState(() {
      myPost = data;
      hasMoreMyPost = data.length >= limitmyPost;
    });
  }

  Future<void> fetchAllPosts() async {
    final data = await getPosts(0, pageallPost * limitallPost);
    if (!mounted) return;
    setState(() {
      allPost = data;
      hasMoreallPost = data.length >= limitallPost;
    });
  }

  Future<void> fetchAllMorePosts() async {
    if (!hasMoreallPost || isLoadingMore) return;
    setState(() => isLoadingMore = true);
    final newPosts = await getPosts(pageallPost, limitallPost);
    setState(() {
      allPost = [...allPost, ...newPosts];
      pageallPost++;
      hasMoreallPost = newPosts.length >= limitallPost;
      isLoadingMore = false;
    });
  }

  Future<void> fetchMyMorePost() async {
    if (!hasMoreMyPost || isLoadingMore) return;
    setState(() => isLoadingMore = true);
    String userid = await getUserId();
    final newPosts = await getMyposts(userid, pagemyPost, limitmyPost);
    setState(() {
      myPost = [...myPost, ...newPosts];
      pagemyPost++;
      hasMoreMyPost = newPosts.length >= limitmyPost;
      isLoadingMore = false;
    });
  }

  // --- Modal & Dialog ---
  Future<void> _showPostOptions(Map<String, dynamic> postObj) async {
    final String myuserId = await getUserId();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (modalContext) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFF7EB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Wrap(
              children: [
                if (postObj['userID'] == myuserId) ...[
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
                      await deletePost(postObj['_id']);
                      fetchAllPosts();
                      fetchMyPosts();
                      showSuccessToast(
                        "ลบโพสต์สำเร็จ",
                        "โพสต์ของคุณหายไปแล้วน้า",
                      );
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.report, color: Colors.orange),
                  title: Text('รายงานโพสต์', style: GoogleFonts.mali()),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _showReportDialog(postObj);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _showReportDialog(Map<String, dynamic> postObj) async {
    String? selectedReason;
    final reasonController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setStateDialog) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: const Color(0xFFFFF7EB),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🚨 รายงานโพสต์',
                            style: GoogleFonts.mali(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                [
                                  'เนื้อหาไม่เหมาะสม',
                                  'คำพูดรุนแรง',
                                  'ลามกอนาจาร',
                                  'สแปม',
                                  'อื่นๆ',
                                ].map((reason) {
                                  final isSelected = selectedReason == reason;
                                  return ChoiceChip(
                                    label: Text(
                                      reason,
                                      style: GoogleFonts.mali(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : const Color(0xFFFD7D7E),
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFFFD7D7E),
                                    backgroundColor: const Color(0xFFFFF0F0),
                                    onSelected:
                                        (val) => setStateDialog(
                                          () => selectedReason = reason,
                                        ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: reasonController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'รายละเอียดเพิ่มเติม...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'ยกเลิก',
                                    style: GoogleFonts.mali(color: Colors.grey),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFD7D7E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed:
                                      selectedReason == null || isSubmitting
                                          ? null
                                          : () async {
                                            setStateDialog(
                                              () => isSubmitting = true,
                                            );
                                            String myuserId = await getUserId();
                                            await ReportPost(
                                              myuserId,
                                              postObj['userID'],
                                              postObj['_id'],
                                              selectedReason!,
                                              "Post",
                                              reasonController.text,
                                            );
                                            Navigator.pop(dialogContext);
                                            showSuccessToast(
                                              "ส่งรายงานแล้ว",
                                              "ขอบคุณที่ช่วยดูแลชุมชนของเราน้า",
                                            );
                                          },
                                  child:
                                      isSubmitting
                                          ? const SpinKitThreeBounce(
                                            color: Colors.white,
                                            size: 20,
                                          )
                                          : Text(
                                            'ส่งรายงาน',
                                            style: GoogleFonts.mali(
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FullScreenPostCreator(
            stateEdit: false,
            onPost: () {
              fetchAllPosts();
              fetchMyPosts();
            },
          ),
    );
  }

  void _showEditPostModal(Map<String, dynamic> postOBJ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FullScreenPostCreator(
            stateEdit: true,
            postObj: postOBJ,
            onPost: () {
              fetchAllPosts();
              fetchMyPosts();
            },
          ),
    );
  }

  // --- Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  backgroundColor: const Color(0xFFFFF7EB),
                  floating: true,
                  snap: true,
                  toolbarHeight: 230, // ความสูงเพื่อรองรับหัวใจ
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ZoomIn(
                        duration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 30,
                            bottom: 15,
                          ), // เพิ่มช่องไฟ
                          child: Text(
                            "Healjai Community 💚",
                            style: GoogleFonts.mali(
                              fontSize: 32, // 👈 ปรับตัวหนังสือให้ใหญ่ขึ้น
                              color: const Color(0xFF78B465),
                              fontWeight: FontWeight.w800, // 👈 ปรับให้หนาขึ้น
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: PostCreationTrigger(onTap: _showCreatePostModal),
                      ),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF78B465),
                      indicatorColor: const Color(0xFF78B465),
                      // --- 1. ปรับ Font ตัวที่เลือกอยู่ (Active) ---
                      labelStyle: GoogleFonts.mali(
                        fontSize: 18, // ปรับขนาดตามใจชอบเลย (เช่น 18 หรือ 20)
                        fontWeight: FontWeight.bold,
                      ),
                      // --- 2. ปรับ Font ตัวที่ไม่ได้เลือก (Inactive) ---
                      unselectedLabelStyle: GoogleFonts.mali(
                        fontSize:
                            16, // ให้เล็กลงนิดนึงเพื่อให้ตัวที่เลือกดูเด่นขึ้น
                        fontWeight: FontWeight.w500,
                      ),
                      unselectedLabelColor:
                          Colors.grey, // สีของตัวที่ไม่ได้เลือก
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
            children: [
              _buildPostList(
                allPost,
                fetchAllPosts,
                fetchAllMorePosts,
                hasMoreallPost,
              ),
              _buildPostList(
                myPost,
                fetchMyPosts,
                fetchMyMorePost,
                hasMoreMyPost,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostList(
    List<Map<String, dynamic>> posts,
    RefreshCallback onRefresh,
    Future<void> Function() onLoadMore,
    bool hasMore,
  ) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF78B465),
      child:
          posts.isEmpty && !isLoadingMore
              ? Center(
                child: Text(
                  'ไม่มีโพสต์',
                  style: GoogleFonts.mali(fontSize: 18),
                ),
              )
              : NotificationListener<ScrollNotification>(
                onNotification: (scroll) {
                  if (scroll.metrics.pixels == scroll.metrics.maxScrollExtent &&
                      hasMore)
                    onLoadMore();
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: posts.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == posts.length)
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: SpinKitCircle(
                            color: Color(0xFF78B465),
                            size: 50,
                          ),
                        ),
                      );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: UserPostCard(
                        key: ValueKey(posts[index]['_id']),
                        post: posts[index],
                        onMoreOptionsPressed:
                            () => _showPostOptions(posts[index]),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

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
  ) => Container(color: const Color(0xFFFFF7EB), child: _tabBar);
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
