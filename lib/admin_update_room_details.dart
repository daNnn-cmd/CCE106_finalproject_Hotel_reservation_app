import 'package:flutter/material.dart';
import 'admin_manage_hotels.dart';
import 'admin_manage_guests.dart';
import 'admin_view_all_bookings.dart';
import 'admin_settings_page.dart';
import '../AdminDashboard.dart';

class AdminUpdateRoomDetails extends StatefulWidget {
  const AdminUpdateRoomDetails({super.key});

  @override
  State<AdminUpdateRoomDetails> createState() => _AdminUpdateRoomDetailsState();
}

class _AdminUpdateRoomDetailsState extends State<AdminUpdateRoomDetails> {
  int _currentIndex = 1; // Corresponds to Hotels tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Room Details'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: const Center(child: Text('This is the Update Room Details page.')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) {
            return;
          }

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminManageHotels(),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminViewAllBookings(),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminManageGuests(),
              ),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminSettingsPage(),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel_outlined),
            label: 'Hotels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
