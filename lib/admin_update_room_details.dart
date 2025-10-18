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
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 280,
            color: const Color(0xFF1E88E5),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24.0),
                  color: const Color(0xFF1565C0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Update Room Details',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      _buildSidebarItem(
                        icon: Icons.dashboard_outlined,
                        label: 'Dashboard',
                        isSelected: _currentIndex == 0,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminDashboard(),
                            ),
                          );
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.hotel_outlined,
                        label: 'Manage Hotels',
                        isSelected: _currentIndex == 1,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminManageHotels(),
                            ),
                          );
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.book_outlined,
                        label: 'View Bookings',
                        isSelected: _currentIndex == 2,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminViewAllBookings(),
                            ),
                          );
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.person_outline,
                        label: 'Manage Guests',
                        isSelected: _currentIndex == 3,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminManageGuests(),
                            ),
                          );
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        isSelected: _currentIndex == 4,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminSettingsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Update Room Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                const Expanded(
                  child: Center(
                    child: Text(
                      'This is the Update Room Details page.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
