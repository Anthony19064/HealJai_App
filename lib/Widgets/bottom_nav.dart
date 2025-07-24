import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


import '../data_Lists/data_BottomBar.dart';
import '../providers/navProvider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNavBar> {
  late List<Map<String, dynamic>> Bottom_data = [];
  int selectedIndex = 2; 
  

  @override
  void initState() {
    super.initState();
    Bottom_data = List.from(Data_BottomBar);
  }

  Widget build(BuildContext context) {
    final navState = Provider.of<NavState>(context);
    
    return Container(
      color: const Color(0xFFFFF7EB),
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 35, left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFFE0E0E0), width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              Bottom_data.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                bool isSelected = navState.selectedIndex == index;
      
                return GestureDetector(
                  onTap: () {
                    navState.setIndex(index);
                    context.go(item['path']);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:  isSelected? Color(0xFF78B465) : Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      item['icon'],
                      color: isSelected? Color(0xFFFFFFFF) : Color(0xFF8D8D8D),
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
