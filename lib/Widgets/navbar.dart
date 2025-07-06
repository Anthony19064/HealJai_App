import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("ฮีลใจ"),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              'https://firebasestorage.googleapis.com/v0/b/healjaimini.firebasestorage.app/o/Post%2F1749614806291_SnapInsta.to_495270910_18040002317628716_5641407600884112400_n.jpg?alt=media&token=b4f9cb43-916e-4aff-a87c-d575101f1ca3',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
