import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel/HotelDetailsScreen.dart';
import 'package:hotel/chats_screen.dart';
import 'package:hotel/favorites_screen.dart';
import 'package:hotel/home_screen.dart';
import 'package:hotel/my_bookings_screen.dart';
import 'package:hotel/profile_screen.dart';
import 'package:intl/intl.dart';
import 'model/hotel_model.dart';

class HotelListingScreen extends StatefulWidget {
  final String location;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final int rooms;

  const HotelListingScreen({
    super.key,
    required this.location,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.rooms,
  });

  @override
  State<HotelListingScreen> createState() => _HotelListingScreenState();
}

class _HotelListingScreenState extends State<HotelListingScreen> {
  List<Hotel> _filteredHotels = [];
  int _selectedIndex = 0;
  String _selectedSort = 'Price Lower to Higher';
  int _selectedRating = 0;
  RangeValues _priceRange = const RangeValues(0, 1000);
  final TextEditingController _searchController = TextEditingController();
  List<Hotel> _allHotels = [];
  Set<String> _favoriteHotelIds = {};

  final CollectionReference _hotelsCollection = FirebaseFirestore.instance
      .collection('hotels');
  final CollectionReference _favoritesCollection = FirebaseFirestore.instance
      .collection('favorites');

  @override
  void initState() {
    super.initState();

    // Initialize searchController with location from HomeScreen
    _searchController.text = widget.location.toLowerCase();

    _searchController.addListener(_applyFilters);
    _loadFavorites();
    _loadHotels();
  }

  void _loadHotels() {
    // Listen to Firestore hotels and merge with dummy hotels
    _hotelsCollection.snapshots().listen((snapshot) {
      final firestoreHotels = snapshot.docs
          .map((doc) => Hotel.fromFirestore(doc))
          .toList();

      setState(() {
        _allHotels = [...dummyHotels, ...firestoreHotels];
      });

      _applyFilters();
    });
  }

  void _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await _favoritesCollection
          .doc(user.uid)
          .collection('userFavorites')
          .get();

      setState(() {
        _favoriteHotelIds = Set<String>.from(
          snapshot.docs.map((doc) => doc.id),
        );
      });
    }
  }

  Future<void> _toggleFavorite(Hotel hotel) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Show login prompt if user is not authenticated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login to add favorites'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              // Navigate to login screen
            },
          ),
        ),
      );
      return;
    }

    final favoriteDoc = _favoritesCollection
        .doc(user.uid)
        .collection('userFavorites')
        .doc(hotel.id);

    setState(() {
      if (_favoriteHotelIds.contains(hotel.id)) {
        _favoriteHotelIds.remove(hotel.id);
        favoriteDoc.delete();
      } else {
        _favoriteHotelIds.add(hotel.id);
        favoriteDoc.set({
          'hotelId': hotel.id,
          'hotelName': hotel.name,
          'hotelImage': hotel.imageUrl,
          'hotelLocation': hotel.location,
          'hotelPrice': hotel.price,
          'hotelRating': hotel.rating,
          'addedAt': DateTime.now(),
        });
      }
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _favoriteHotelIds.contains(hotel.id)
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      List<Hotel> results = _allHotels.where((hotel) {
        final query = _searchController.text.toLowerCase();
        return hotel.name.toLowerCase().contains(query) ||
            hotel.location.toLowerCase().contains(query);
      }).toList();

      if (_selectedRating > 0) {
        results = results
            .where((hotel) => hotel.rating >= _selectedRating.toDouble())
            .toList();
      }

      results = results
          .where(
            (hotel) =>
                hotel.price >= _priceRange.start &&
                hotel.price <= _priceRange.end,
          )
          .toList();

      switch (_selectedSort) {
        case 'Price Lower to Higher':
          results.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'Price Higher to Lower':
          results.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Rating Higher to Lower':
          results.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Rating Lower to Higher':
          results.sort((a, b) => a.rating.compareTo(b.rating));
          break;
      }

      _filteredHotels = results; // Use this for ListView.builder
    });
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                      const Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedSort = 'Price Lower to Higher';
                            _selectedRating = 0;
                            _priceRange = const RangeValues(0, 1000);
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Sort By',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 300,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Sort By',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: const [
                                      'Price Lower to Higher',
                                      'Price Higher to Lower',
                                      'Rating Higher to Lower',
                                      'Rating Lower to Higher',
                                    ].length,
                                    itemBuilder: (context, index) {
                                      final sortOption = const [
                                        'Price Lower to Higher',
                                        'Price Higher to Lower',
                                        'Rating Higher to Lower',
                                        'Rating Lower to Higher',
                                      ][index];
                                      return ListTile(
                                        title: Text(sortOption),
                                        trailing: _selectedSort == sortOption
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.blue,
                                              )
                                            : null,
                                        onTap: () {
                                          setModalState(() {
                                            _selectedSort = sortOption;
                                          });
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedSort,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ratings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedRating = _selectedRating == index + 1
                                ? 0
                                : index + 1;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _selectedRating >= index + 1
                                ? Colors.blue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedRating >= index + 1
                                  ? Colors.transparent
                                  : Colors.black,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: _selectedRating >= index + 1
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.star,
                                  color: _selectedRating >= index + 1
                                      ? Colors.white
                                      : Colors.amber,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Price Ranges',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 10,
                    labels: RangeLabels(
                      '\₱${_priceRange.start.round()}',
                      '\₱${_priceRange.end.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        _priceRange = values;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\₱${_priceRange.start.round()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\₱${_priceRange.end.round()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('APPLY'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                widget.location,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('dd MMM').format(widget.checkInDate)}-${DateFormat('dd MMM').format(widget.checkOutDate)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.guests} guests',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by Location',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Recommended Hotels',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: _hotelsCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No hotels found.'));
                  }

                  final firestoreHotels = snapshot.data!.docs
                      .map((doc) => Hotel.fromFirestore(doc))
                      .toList();

                  // ✅ Merge Firestore + Dummy hotels
                  final allHotels = [...dummyHotels, ...firestoreHotels];

                  // Apply filters locally
                  List<Hotel> results = allHotels.where((hotel) {
                    return hotel.name.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    );
                  }).toList();

                  if (_selectedRating > 0) {
                    results = results
                        .where(
                          (hotel) => hotel.rating >= _selectedRating.toDouble(),
                        )
                        .toList();
                  }

                  results = results
                      .where(
                        (hotel) =>
                            hotel.price >= _priceRange.start &&
                            hotel.price <= _priceRange.end,
                      )
                      .toList();

                  switch (_selectedSort) {
                    case 'Price Lower to Higher':
                      results.sort((a, b) => a.price.compareTo(b.price));
                      break;
                    case 'Price Higher to Lower':
                      results.sort((a, b) => b.price.compareTo(a.price));
                      break;
                    case 'Rating Higher to Lower':
                      results.sort((a, b) => b.rating.compareTo(a.rating));
                      break;
                    case 'Rating Lower to Higher':
                      results.sort((a, b) => a.rating.compareTo(b.rating));
                      break;
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredHotels.length,
                    itemBuilder: (context, index) {
                      final hotel = _filteredHotels[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HotelDetailsScreen(
                                hotel: hotel,
                                checkInDate: widget.checkInDate,
                                checkOutDate: widget.checkOutDate,
                                guests: widget.guests,
                                rooms: widget.rooms,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: _buildHotelCard(hotel),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatsScreen()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'My bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    final isFavorite = _favoriteHotelIds.contains(hotel.id);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel Image
          Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                hotel.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 40),
              ),
            ),
          ),

          // Hotel Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleFavorite(hotel),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hotel.location,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        hotel.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\₱${hotel.price.toStringAsFixed(0)} Pesos /night',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
