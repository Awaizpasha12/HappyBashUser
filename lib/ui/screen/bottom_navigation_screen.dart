import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/navigator.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/pages/Categories/categories_page.dart';
import 'package:happy_bash/ui/pages/booking/booking_summary.dart';
import 'package:happy_bash/ui/pages/notifications/notifications_page.dart';
import 'package:happy_bash/ui/pages/profile/profile_page.dart';
import 'package:happy_bash/ui/pages/waitlist/wait_list_page.dart';

import '../../core/reusable.dart';
import '../pages/booking/booking_page.dart';
import '../pages/homepage/home_page.dart';
import '../pages/profile/WishList/whishlist_page.dart';

//........Bottom Navigation Bar Screen that Common for all pages........

class BottomNavigationBarScreen extends StatefulWidget {
  BottomNavigationBarScreen({Key? key, required this.selectedIndex})
      : super(key: key);
  int? selectedIndex;

  @override
  State<BottomNavigationBarScreen> createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
      _currentIndex = widget.selectedIndex!;
      // _currentIndex = index;
    });
    if (index == 3) {
      // Ensure WaitListPage is refreshed when tapped
      // final waitListPageState =
      //     (_pages[3] as WaitListPage).currentState as _WaitListPageState;
      // waitListPageState.refreshData();
    }
  }

  @override
  void initState() {
    super.initState();

    _pages = [
      const HomePage(),
      const CategoriesPage(),
      const BookingSummary(),
      // const WaitListPage(),
      const WishListPage(),
      const ProfilePage(),
      const NotificationPage(),
    ];
    _onItemTapped(widget.selectedIndex!);
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: IndexedStack(
  //       index: _currentIndex,
  //       children: _pages,
  //     ),
  //     bottomNavigationBar: BottomNavigationBar(
  //       currentIndex: _currentIndex,
  //       selectedItemColor: PrimaryColors().primarycolor,
  //       unselectedItemColor: PrimaryColors().grey,
  //       selectedLabelStyle: const TextStyle(
  //         color: Color(0xFF2A9DA0),
  //         fontSize: 12,
  //         fontFamily: poppinsSemiBold,
  //         fontWeight: FontWeight.w600,
  //       ),
  //       unselectedLabelStyle: const TextStyle(
  //         color: Color(0xFF9B9B9B),
  //         fontSize: 12,
  //         fontFamily: poppinsMedium,
  //         fontWeight: FontWeight.w500,
  //       ),
  //       type: BottomNavigationBarType.fixed,
  //       items: [
  //         BottomNavigationBarItem(
  //           icon: _currentIndex == 0
  //               ? Image.asset("assets/icons/home_1.png")
  //               : Image.asset("assets/icons/home_2.png"),
  //           label: "",
  //         ),
  //         BottomNavigationBarItem(
  //           icon: _currentIndex == 1
  //               ? Image.asset("assets/icons/categories_fill.png")
  //               : Image.asset("assets/icons/categories.png"),
  //           label: "",
  //         ),
  //         BottomNavigationBarItem(
  //           icon: _currentIndex == 2
  //               ? Image.asset("assets/icons/booking_fill.png")
  //               : Image.asset("assets/icons/booking.png"),
  //           label: "",
  //         ),
  //         BottomNavigationBarItem(
  //           icon: _currentIndex == 3
  //               ? Image.asset("assets/icons/waitlist_fill.png")
  //               : Image.asset("assets/icons/waitlist.png"),
  //           label: "",
  //         ),
  //         BottomNavigationBarItem(
  //           icon: _currentIndex == 4
  //               ? Image.asset("assets/icons/profile_fill.png")
  //               : Image.asset("assets/icons/profile.png"),
  //           label: "",
  //         ),
  //         BottomNavigationBarItem(
  //           icon: _currentIndex == 5
  //               ? Image.asset("assets/icons/notificaitonsnew.png")
  //               : Image.asset("assets/icons/notificaitonsnew.png"),
  //           label: "",
  //         ),
  //       ],
  //       onTap: (index) {
  //         setState(() {
  //           _currentIndex = index;
  //           printMsgTag("_currentIndex of bottom", _currentIndex);
  //           if (index == 3) {
  //             navigateReplaceAll(
  //                 context, BottomNavigationBarScreen(selectedIndex: 3));
  //           }
  //         });
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 60, // Fixed height to match default BottomNavigationBar
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNavItem(0, "assets/icons/home_1.png", "assets/icons/home_2.png"),
            _buildNavItem(1, "assets/icons/categories_fill.png", "assets/icons/categories.png"),
            _buildNavItem(2, "assets/icons/booking_fill.png", "assets/icons/booking.png"),
            _buildNavItem(3, "assets/icons/waitlist_fill.png", "assets/icons/waitlist.png"),
            _buildNavItem(4, "assets/icons/profile_fill.png", "assets/icons/profile.png"),
            _buildNavItem(5, "assets/icons/notificaitonsnew.png", "assets/icons/notificaitonsnew.png"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String selectedIcon, String unselectedIcon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          printMsgTag("_currentIndex of bottom", _currentIndex);
          if (index == 3) {
            navigateReplaceAll(context, BottomNavigationBarScreen(selectedIndex: 3));
          }
        });
      },
      child: SizedBox(
        width: 50, // Set a fixed width for each item
        height: 50, // Ensure proper centering
        child: Center(
          child: Image.asset(
            _currentIndex == index ? selectedIcon : unselectedIcon,
            width: 24, // Standard icon size
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

}
