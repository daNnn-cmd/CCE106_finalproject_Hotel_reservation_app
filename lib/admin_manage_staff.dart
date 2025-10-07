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
  bool _isSearching = false;
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search staff by name, email, or position...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text('Manage Staff'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Staff')),
              const PopupMenuItem(value: 'active', child: Text('Active Staff')),
              const PopupMenuItem(
                value: 'inactive',
                child: Text('Inactive Staff'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'managers', child: Text('Managers')),
              const PopupMenuItem(
                value: 'front_desk',
                child: Text('Front Desk'),
              ),
              const PopupMenuItem(
                value: 'housekeeping',
                child: Text('Housekeeping'),
              ),
              const PopupMenuItem(
                value: 'maintenance',
                child: Text('Maintenance'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E88E5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  "Total Staff",
                  staffMembers.length.toString(),
                  Icons.people,
                ),
                _buildStatCard(
                  "Active",
                  staffMembers.where((s) => s.isActive).length.toString(),
                  Icons.check_circle,
                ),
                _buildStatCard("Departments", "4", Icons.business),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Main Content
          Expanded(
            child:
                filteredStaff.isEmpty &&
                    (_searchQuery.isNotEmpty || _filterBy != 'all')
                ? _buildEmptySearchState()
                : filteredStaff.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStaffDialog(),
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) return;

            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboard(),
                  ),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminManageHotels(),
                  ),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminViewAllBookings(),
                  ),
                );
                break;
              case 3:
                break;
              case 4:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminSettingsPage(),
                  ),
                );
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF1E88E5),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
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
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
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
