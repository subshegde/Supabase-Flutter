import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_supabase_project/pages/auth/services/auth_services.dart';
import 'package:flutter_supabase_project/pages/home/profile.dart';
import 'package:flutter_supabase_project/pages/home/supabaseExample.dart';
import 'package:flutter_supabase_project/pages/upload/uploadImage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  int selectedIndex = 0;
  String email = '';

  AuthServices services = AuthServices();

  // Dynamically updated pages list based on email
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _updateEmail();
  }

  void _updateEmail() async {
    final userEmail = services.getUserEmail();
    if (userEmail != null) {
      setState(() {
        email = userEmail;
      });
      setState(() {
        _pages = [
          const SupabaseExample(),
          const UploadImage(),
          ProfilePage(email: email),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.isNotEmpty ? _pages[selectedIndex] : const Center(child: CircularProgressIndicator(color: Colors.amber,)),
      bottomNavigationBar: FlashyTabBar(
        height: 55,
        backgroundColor: Colors.amber,
        selectedIndex: selectedIndex,
        animationCurve: Curves.linear,
        animationDuration: const Duration(milliseconds: 300),
        showElevation: false,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          FlashyTabBarItem(
            icon: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.upload, color: Colors.white),
            title: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.person, color: Colors.white),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
