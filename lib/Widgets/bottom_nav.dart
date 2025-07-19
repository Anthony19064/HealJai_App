import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 30), // ขยับ BottomNavBar ขึ้นจากล่างนิดนึง
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // 🔻 BottomAppBar ด้านหลัง
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            child: BottomAppBar(
              color: const Color.fromARGB(255, 79, 138, 65),
              elevation: 6,
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    NavItem(icon: Icons.home, label: 'หน้าหลัก', path: '/'),
                    NavItem(icon: Icons.videogame_asset, label: 'มินิเกม', path: '/game'),
                    SizedBox(width: 40), // ช่องเว้นให้ปุ่ม Floating อยู่ตรงกลาง
                    NavItem(icon: Icons.groups, label: 'ชุมชน', path: '/commu'),
                    NavItem(icon: Icons.menu_book, label: 'บทความ', path: '/'),
                  ],
                ),
              ),
            ),
          ),

          // 🔵 ปุ่ม Floating อยู่ซ้อนด้านบน
          Positioned(
            top: -25, // ยกให้ลอยขึ้นจาก BottomAppBar
            child: FloatingActionButton(
              onPressed: () {
                // ฟังก์ชันเมื่อกดปุ่ม
              },
              backgroundColor: Colors.white,
              shape: const CircleBorder(
                side: BorderSide(
                  color: Color.fromARGB(255, 79, 138, 65),
                  width: 5.0,
                ),
              ),
              elevation: 10,
              child: const Icon(
                Icons.chat,
                color: Color.fromARGB(255, 79, 138, 65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;

  const NavItem({required this.icon, required this.label, required this.path, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go(path);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
