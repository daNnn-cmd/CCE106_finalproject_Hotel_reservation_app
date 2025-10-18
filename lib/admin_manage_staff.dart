import 'package:flutter/material.dart';
import 'admin_manage_hotels.dart';
import 'admin_view_all_bookings.dart';
import 'admin_settings_page.dart';
import '../AdminDashboard.dart';

class AdminManageStaff extends StatefulWidget {
  const AdminManageStaff({super.key});

  @override
  State<AdminManageStaff> createState() => _AdminManageStaffState();
}

class _AdminManageStaffState extends State<AdminManageStaff>
    with TickerProviderStateMixin {
  int _currentIndex = 3;
  String _searchQuery = '';
  String _filterBy =
      'all'; // all, active, inactive, managers, front_desk, housekeeping, maintenance
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;

  // Sample staff data - replace with actual Firebase data
  List<StaffMember> staffMembers = [
    StaffMember(
      id: '1',
      name: 'John Smith',
      email: 'john.smith@hotel.com',
      phone: '+1 (555) 123-4567',
      position: 'Manager',
      department: 'Management',
      isActive: true,
      joinDate: DateTime(2023, 1, 15),
      salary: 65000,
      imageUrl: '',
    ),
    StaffMember(
      id: '2',
      name: 'Sarah Johnson',
      email: 'sarah.johnson@hotel.com',
      phone: '+1 (555) 234-5678',
      position: 'Front Desk Receptionist',
      department: 'Front Desk',
      isActive: true,
      joinDate: DateTime(2023, 3, 20),
      salary: 35000,
      imageUrl: '',
    ),
    StaffMember(
      id: '3',
      name: 'Mike Wilson',
      email: 'mike.wilson@hotel.com',
      phone: '+1 (555) 345-6789',
      position: 'Maintenance Technician',
      department: 'Maintenance',
      isActive: false,
      joinDate: DateTime(2022, 8, 10),
      salary: 42000,
      imageUrl: '',
    ),
    StaffMember(
      id: '4',
      name: 'Emma Davis',
      email: 'emma.davis@hotel.com',
      phone: '+1 (555) 456-7890',
      position: 'Housekeeper',
      department: 'Housekeeping',
      isActive: true,
      joinDate: DateTime(2023, 6, 5),
      salary: 30000,
      imageUrl: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<StaffMember> get filteredStaff {
    return staffMembers.where((staff) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!staff.name.toLowerCase().contains(searchLower) &&
            !staff.email.toLowerCase().contains(searchLower) &&
            !staff.position.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Status filter
      switch (_filterBy) {
        case 'active':
          return staff.isActive;
        case 'inactive':
          return !staff.isActive;
        case 'managers':
          return staff.department.toLowerCase() == 'management';
        case 'front_desk':
          return staff.department.toLowerCase() == 'front desk';
        case 'housekeeping':
          return staff.department.toLowerCase() == 'housekeeping';
        case 'maintenance':
          return staff.department.toLowerCase() == 'maintenance';
        default:
          return true;
      }
    }).toList();
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
                        'Staff Management',
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
                        icon: Icons.badge_outlined,
                        label: 'Manage Staff',
                        isSelected: _currentIndex == 3,
                        onTap: () {
                          setState(() => _currentIndex = 3);
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
                        'Manage Staff',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search staff by name, email, or position...',
                              prefixIcon: Icon(Icons.search, color: Color(0xFF1E88E5)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      PopupMenuButton<String>(
                        icon: Row(
                          children: [
                            const Icon(Icons.filter_list, color: Color(0xFF1E88E5)),
                            const SizedBox(width: 4),
                            Text(
                              _filterBy == 'all' ? 'All' : _filterBy.replaceAll('_', ' '),
                              style: const TextStyle(color: Color(0xFF1E88E5)),
                            ),
                          ],
                        ),
                        onSelected: (value) {
                          setState(() {
                            _filterBy = value;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'all', child: Text('All Staff')),
                          const PopupMenuItem(value: 'active', child: Text('Active Staff')),
                          const PopupMenuItem(value: 'inactive', child: Text('Inactive Staff')),
                          const PopupMenuDivider(),
                          const PopupMenuItem(value: 'managers', child: Text('Managers')),
                          const PopupMenuItem(value: 'front_desk', child: Text('Front Desk')),
                          const PopupMenuItem(value: 'housekeeping', child: Text('Housekeeping')),
                          const PopupMenuItem(value: 'maintenance', child: Text('Maintenance')),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFF1E88E5)),
                        onPressed: () => setState(() {}),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showAddStaffDialog(),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add Staff',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Stats Cards
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDesktopStatCard(
                          'Total Staff',
                          staffMembers.length.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDesktopStatCard(
                          'Active',
                          staffMembers.where((s) => s.isActive).length.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDesktopStatCard(
                          'Departments',
                          '4',
                          Icons.business,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child:
                filteredStaff.isEmpty &&
                    (_searchQuery.isNotEmpty || _filterBy != 'all')
                ? _buildEmptySearchState()
                : filteredStaff.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: filteredStaff.length,
                    itemBuilder: (context, index) {
                      final staff = filteredStaff[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                          contentPadding: const EdgeInsets.all(16),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: _getDepartmentColor(
                                  staff.department,
                                ).withOpacity(0.2),
                                child: Text(
                                  staff.name
                                      .split(' ')
                                      .map((n) => n[0])
                                      .join()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: _getDepartmentColor(
                                      staff.department,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (staff.isActive)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            staff.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                staff.position,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      staff.email,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getDepartmentColor(
                                        staff.department,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      staff.department,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getDepartmentColor(
                                          staff.department,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: staff.isActive
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      staff.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: staff.isActive
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.grey,
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 'view':
                                  _showStaffDetails(staff);
                                  break;
                                case 'edit':
                                  _showEditStaffDialog(staff);
                                  break;
                                case 'toggle':
                                  _toggleStaffStatus(staff);
                                  break;
                                case 'delete':
                                  _showDeleteConfirmation(staff);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, size: 20),
                                    SizedBox(width: 8),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Row(
                                  children: [
                                    Icon(
                                      staff.isActive
                                          ? Icons.pause_circle
                                          : Icons.play_circle,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      staff.isActive
                                          ? 'Deactivate'
                                          : 'Activate',
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Remove',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

  Widget _buildDesktopStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No staff members yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first staff member to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddStaffDialog(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Staff Member'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No staff members match your criteria',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _filterBy = 'all';
              });
            },
            child: const Text("Clear filters"),
          ),
        ],
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'management':
        return Colors.purple;
      case 'front desk':
        return const Color(0xFF1E88E5);
      case 'housekeeping':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showStaffDetails(StaffMember staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${staff.name} - Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Position', staff.position),
              _buildDetailRow('Department', staff.department),
              _buildDetailRow('Email', staff.email),
              _buildDetailRow('Phone', staff.phone),
              _buildDetailRow('Status', staff.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow(
                'Join Date',
                '${staff.joinDate.day}/${staff.joinDate.month}/${staff.joinDate.year}',
              ),
              _buildDetailRow(
                'Salary',
                '\$${staff.salary.toStringAsFixed(0)}/year',
              ),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddStaffDialog() {
    _showStaffFormDialog();
  }

  void _showEditStaffDialog(StaffMember staff) {
    _showStaffFormDialog(staff: staff);
  }

  void _showStaffFormDialog({StaffMember? staff}) {
    final nameController = TextEditingController(text: staff?.name ?? '');
    final emailController = TextEditingController(text: staff?.email ?? '');
    final phoneController = TextEditingController(text: staff?.phone ?? '');
    final positionController = TextEditingController(
      text: staff?.position ?? '',
    );
    final salaryController = TextEditingController(
      text: staff?.salary.toString() ?? '',
    );
    String selectedDepartment = staff?.department ?? 'Management';
    bool isActive = staff?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(staff == null ? 'Add Staff Member' : 'Edit Staff Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(labelText: 'Position'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDepartment,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items:
                      [
                            'Management',
                            'Front Desk',
                            'Housekeeping',
                            'Maintenance',
                          ]
                          .map(
                            (dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            ),
                          )
                          .toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedDepartment = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: salaryController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Annual Salary'),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) => setDialogState(() => isActive = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add validation and save logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      staff == null
                          ? 'Staff member added successfully'
                          : 'Staff member updated successfully',
                    ),
                  ),
                );
              },
              child: Text(staff == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleStaffStatus(StaffMember staff) {
    setState(() {
      staff.isActive = !staff.isActive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${staff.name} has been ${staff.isActive ? 'activated' : 'deactivated'}',
        ),
      ),
    );
  }

  void _showDeleteConfirmation(StaffMember staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Staff Member'),
        content: Text(
          'Are you sure you want to remove ${staff.name} from the staff list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                staffMembers.removeWhere((s) => s.id == staff.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${staff.name} has been removed')),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class StaffMember {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final String department;
  bool isActive;
  final DateTime joinDate;
  final double salary;
  final String imageUrl;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.department,
    required this.isActive,
    required this.joinDate,
    required this.salary,
    required this.imageUrl,
  });
}
