import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel/admin_manage_guests.dart';
import 'package:hotel/admin_view_all_bookings.dart';
import 'package:hotel/admin_settings_page.dart';
import 'package:hotel/model/hotel_model.dart';
import '../AdminDashboard.dart';

class AdminManageHotels extends StatefulWidget {
  const AdminManageHotels({super.key});

  @override
  State<AdminManageHotels> createState() => _AdminManageHotelsState();
}

class _AdminManageHotelsState extends State<AdminManageHotels> {
  int selectedIndex = 1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final CollectionReference _hotelsCollection = FirebaseFirestore.instance
      .collection('hotels');

  // Controllers for the form fields
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _reviewsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _galleryImagesController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _imageUrlController.dispose();
    _reviewsController.dispose();
    _descriptionController.dispose();
    _galleryImagesController.dispose();
    super.dispose();
  }

  // CREATE and UPDATE operation
  Future<void> _saveHotel([String? docId]) async {
    final name = _nameController.text;
    final location = _locationController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final rating = double.tryParse(_ratingController.text) ?? 0.0;
    final imageUrl = _imageUrlController.text;
    final reviews = int.tryParse(_reviewsController.text) ?? 0;
    final description = _descriptionController.text;
    final galleryImages = _galleryImagesController.text
        .split(',')
        .map((s) => s.trim())
        .toList();

    if (name.isEmpty || location.isEmpty || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    final hotelData = {
      'name': name,
      'location': location,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
      'reviews': reviews,
      'description': description,
      'galleryImages': galleryImages,
    };

    try {
      if (docId == null) {
        await _hotelsCollection.add(hotelData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel added successfully')),
        );
      } else {
        await _hotelsCollection.doc(docId).update(hotelData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotel updated successfully')),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving hotel: $e')));
    }
  }

  // DELETE operation with confirmation dialog
  Future<void> _deleteHotel(String docId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Hotel'),
          content: const Text(
            'Are you sure you want to delete this hotel? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await _hotelsCollection.doc(docId).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hotel deleted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete hotel: $e')),
                  );
                } finally {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showHotelForm(BuildContext context, [Hotel? hotel]) async {
    final formKey = GlobalKey<FormState>();

    if (hotel != null) {
      _nameController.text = hotel.name;
      _locationController.text = hotel.location;
      _priceController.text = hotel.price.toString();
      _ratingController.text = hotel.rating.toString();
      _imageUrlController.text = hotel.imageUrl;
      _reviewsController.text = hotel.reviews.toString();
      _descriptionController.text = hotel.description;
      _galleryImagesController.text = hotel.galleryImages.join(', ');
    } else {
      _nameController.clear();
      _locationController.clear();
      _priceController.clear();
      _ratingController.clear();
      _imageUrlController.clear();
      _reviewsController.clear();
      _descriptionController.clear();
      _galleryImagesController.clear();
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hotel == null ? 'Add New Hotel' : 'Edit Hotel',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const Divider(),

                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Hotel Name
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Hotel Name',
                              prefixIcon: const Icon(
                                Icons.hotel,
                                color: Color(0xFF1E88E5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Hotel name is required'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Location',
                              prefixIcon: const Icon(
                                Icons.location_on,
                                color: Color(0xFF1E88E5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Location is required'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: 'Price per night',
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 8,
                                      ),
                                      child: const Text(
                                        '₱',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E88E5),
                                        ),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                      ? 'Price is required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _ratingController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: 'Rating (0-5)',
                                    prefixIcon: const Icon(
                                      Icons.star,
                                      color: Color(0xFF1E88E5),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                      ? 'Rating is required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _imageUrlController,
                            decoration: InputDecoration(
                              labelText: 'Main Image URL',
                              prefixIcon: const Icon(
                                Icons.image,
                                color: Color(0xFF1E88E5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Image URL is required'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _reviewsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Number of Reviews',
                              prefixIcon: const Icon(
                                Icons.reviews,
                                color: Color(0xFF1E88E5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Reviews count is required'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              prefixIcon: const Icon(
                                Icons.description,
                                color: Color(0xFF1E88E5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Description is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                // Submit button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        _saveHotel(hotel?.id);
                      }
                    },
                    child: Text(
                      hotel == null ? 'Add Hotel' : 'Update Hotel',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                        'Hotel Management',
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
                        isSelected: selectedIndex == 0,
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
                        isSelected: selectedIndex == 1,
                        onTap: () {
                          setState(() => selectedIndex = 1);
                        },
                      ),
                      _buildSidebarItem(
                        icon: Icons.book_outlined,
                        label: 'View Bookings',
                        isSelected: selectedIndex == 2,
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
                        isSelected: selectedIndex == 3,
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
                        isSelected: selectedIndex == 4,
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
                        'Manage Hotels',
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
                              hintText: 'Search hotels or locations...',
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
                      ElevatedButton.icon(
                        onPressed: () => _showHotelForm(context),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add Hotel',
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
                // Content
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
        stream: _hotelsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Loading hotels...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hotels found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first hotel to get started',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showHotelForm(context),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Hotel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            );
          }

          final hotels = snapshot.data!.docs
              .map((doc) => Hotel.fromFirestore(doc))
              .toList();

          // Filter hotels based on search query
          final filteredHotels = hotels.where((hotel) {
            if (_searchQuery.isEmpty) return true;
            return hotel.name.toLowerCase().contains(_searchQuery) ||
                hotel.location.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filteredHotels.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hotels match your search',
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
                      });
                    },
                    child: const Text("Clear search"),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(32),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 0.85,
            ),
            itemCount: filteredHotels.length,
            itemBuilder: (context, index) {
              final hotel = filteredHotels[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel Image
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            hotel.imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                ),
                          ),
                        ),

                        // Rating badge
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  hotel.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Hotel Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    hotel.location,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hotel.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "\₱${hotel.price.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E88E5),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  onPressed: () => _showHotelForm(context, hotel),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () => _deleteHotel(hotel.id),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
}
