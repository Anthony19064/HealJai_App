import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


import 'package:healjai_project/data_Lists/data_BottomBar.dart';
import 'package:healjai_project/providers/navProvider.dart';


import 'package:healjai_project/main.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNavBar> {
  late List<Map<String, dynamic>> Bottom_data = [];

  @override
  void initState() {
    super.initState();
    
    Bottom_data = List.from(Data_BottomBar);
  }

  @override
  Widget build(BuildContext context) {
    final navInfo = Provider.of<Navprovider>(context);

    return Container(
      child: Container(
        height: 60,
        margin:
            const EdgeInsets.only(bottom: 35, left: 20, right: 20, top: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: Bottom_data.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;
            bool isSelected = navInfo.selectedIndex == index;

            return GestureDetector(
              onTap: () {
                shellNavigatorKey.currentState?.maybePop();
                navInfo.setIndex(index);
                context.go(item['path']);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF78B465)
                      : const Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  item['icon'],
                  // 'color' is deprecated, use 'colorFilter' instead for newer versions of flutter_svg
                  colorFilter: ColorFilter.mode(
                    isSelected
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF8D8D8D),
                    BlendMode.srcIn,
                  ),
                  fit: BoxFit.scaleDown,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}