import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotel/splash_screen.dart';
import 'admin_manage_hotels.dart';
import 'admin_view_all_bookings.dart';
import 'admin_manage_guests.dart';
import '../AdminDashboard.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage>
    with TickerProviderStateMixin {
  int _currentIndex = 4;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _darkMode = false;
  bool _autoBackup = true;
  String _selectedLanguage = 'English';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
                        'Settings',
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
                          setState(() => _currentIndex = 4);
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
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.help_outline, color: Color(0xFF1E88E5)),
                        onPressed: () => _showHelpDialog(),
                        tooltip: 'Help',
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Admin Profile Section
                          _buildProfileSection(),

                          const SizedBox(height: 20),

                          // Notifications Section
                          _buildSettingsSection(
                title: 'Notifications',
                icon: Icons.notifications_outlined,
                children: [
                  _buildSwitchTile(
                    title: 'Enable Notifications',
                    subtitle:
                        'Receive notifications about bookings and updates',
                    value: _notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _notificationsEnabled = value),
                  ),
                  _buildSwitchTile(
                    title: 'Email Notifications',
                    subtitle: 'Get notified via email',
                    value: _emailNotifications,
                    onChanged: (value) =>
                        setState(() => _emailNotifications = value),
                  ),
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive push notifications on your device',
                    value: _pushNotifications,
                    onChanged: (value) =>
                        setState(() => _pushNotifications = value),
                  ),
                ],
              ),

                          const SizedBox(height: 20),

                          // System Settings Section
                          _buildSettingsSection(
                title: 'System Settings',
                icon: Icons.settings_outlined,
                children: [
                  _buildSwitchTile(
                    title: 'Dark Mode',
                    subtitle: 'Enable dark theme',
                    value: _darkMode,
                    onChanged: (value) => setState(() => _darkMode = value),
                  ),
                  _buildSwitchTile(
                    title: 'Auto Backup',
                    subtitle: 'Automatically backup data',
                    value: _autoBackup,
                    onChanged: (value) => setState(() => _autoBackup = value),
                  ),
                  _buildDropdownTile(
                    title: 'Language',
                    subtitle: 'Choose your preferred language',
                    value: _selectedLanguage,
                    items: ['English', 'Spanish', 'French', 'German'],
                    onChanged: (value) =>
                        setState(() => _selectedLanguage = value!),
                  ),
                ],
              ),

                          const SizedBox(height: 20),

                          // Management Section
                          _buildSettingsSection(
                title: 'Management',
                icon: Icons.admin_panel_settings_outlined,
                children: [
                  _buildActionTile(
                    title: 'User Management',
                    subtitle: 'Manage user accounts and permissions',
                    icon: Icons.people_outline,
                    onTap: () => _showUserManagementDialog(),
                  ),
                  _buildActionTile(
                    title: 'System Analytics',
                    subtitle: 'View system performance and statistics',
                    icon: Icons.analytics_outlined,
                    onTap: () => _showAnalyticsDialog(),
                  ),
                  _buildActionTile(
                    title: 'Backup & Restore',
                    subtitle: 'Manage data backups and restoration',
                    icon: Icons.backup_outlined,
                    onTap: () => _showBackupDialog(),
                  ),
                ],
              ),

                          const SizedBox(height: 20),

                          // Security Section
                          _buildSettingsSection(
                title: 'Security',
                icon: Icons.security_outlined,
                children: [
                  _buildActionTile(
                    title: 'Change Password',
                    subtitle: 'Update your admin password',
                    icon: Icons.lock_outline,
                    onTap: () => _showChangePasswordDialog(),
                  ),
                  _buildActionTile(
                    title: 'Two-Factor Authentication',
                    subtitle: 'Enable 2FA for enhanced security',
                    icon: Icons.verified_user_outlined,
                    onTap: () => _show2FADialog(),
                  ),
                  _buildActionTile(
                    title: 'Activity Log',
                    subtitle: 'View recent admin activities',
                    icon: Icons.history,
                    onTap: () => _showActivityLogDialog(),
                  ),
                ],
              ),

                          const SizedBox(height: 20),

                          // About Section
                          _buildSettingsSection(
                title: 'About',
                icon: Icons.info_outline,
                children: [
                  _buildActionTile(
                    title: 'App Information',
                    subtitle: 'Version 1.0.0 - Hotel Management System',
                    icon: Icons.info,
                    onTap: () => _showAppInfoDialog(),
                  ),
                  _buildActionTile(
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () => _showPrivacyPolicyDialog(),
                  ),
                  _buildActionTile(
                    title: 'Terms of Service',
                    subtitle: 'Read terms and conditions',
                    icon: Icons.description_outlined,
                    onTap: () => _showTermsDialog(),
                  ),
                ],
              ),

                          const SizedBox(height: 20),

                          // Logout Section
                          _buildLogoutSection(),

                          const SizedBox(height: 20),
                        ],
                      ),
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

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Administrator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'admin@hotelmanagement.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last login: Today, 10:30 AM',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditProfileDialog(),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF1E88E5)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1E88E5),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF1E88E5), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.logout, color: Colors.red, size: 20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
        ),
        subtitle: Text(
          'Sign out of admin account',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.red,
        ),
        onTap: () => _confirmLogout(context),
      ),
    );
  }

  // Dialog methods
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Name')),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showUserManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('User Management'),
        content: const Text(
          'Access user management features to handle user accounts and permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('System Analytics'),
        content: const Text(
          'View detailed analytics about bookings, revenue, and system performance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Backup & Restore'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last backup: Yesterday, 11:30 PM'),
            SizedBox(height: 16),
            Text('Create a new backup or restore from previous backups.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Two-Factor Authentication'),
        content: const Text(
          'Enable 2FA to add an extra layer of security to your admin account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Enable 2FA'),
          ),
        ],
      ),
    );
  }

  void _showActivityLogDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Activity Log'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activities:'),
            SizedBox(height: 8),
            Text('• Login - Today, 10:30 AM'),
            Text('• Hotel added - Yesterday, 3:15 PM'),
            Text('• User account created - Dec 15, 2:00 PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('App Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hotel Management System'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            Text('Build: 100'),
            Text('Developer: Your Company'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Privacy Policy'),
        content: const Text(
          'Read our privacy policy to understand how we handle your data and protect your privacy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terms of Service'),
        content: const Text(
          'Please review our terms and conditions for using the hotel management system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact our support team:'),
            SizedBox(height: 8),
            Text('Email: support@hotelmanagement.com'),
            Text('Phone: +1 (555) 123-4567'),
            Text('Available: 24/7'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 231, 47, 6),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    }
  }
}
