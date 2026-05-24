import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../theme/app_colors.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'kost/my_kost_screen.dart';
import 'chat/chat_screen.dart';
import 'profile/profile_screen.dart';

class MainLayout extends StatelessWidget {
  final MainController controller = Get.put(MainController());

  // Dummy screens untuk tab lainnya
  final List<Widget> pages = [
    HomeScreen(),
    SearchScreen(),
    MyKostScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: Container(
            key: ValueKey<int>(controller.currentIndex.value),
            child: pages[controller.currentIndex.value],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => SizedBox(
          height: 70 + MediaQuery.of(context).padding.bottom,
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            selectedItemColor: AppColors.primary,
            unselectedItemColor:
                theme.textTheme.bodySmall?.color ?? theme.iconTheme.color,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            iconSize: 26,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor:
                theme.bottomNavigationBarTheme.backgroundColor ??
                theme.cardColor,
            elevation: 10,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_work_outlined),
                activeIcon: Icon(Icons.home_work),
                label: 'Kost Saya',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Akun',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
