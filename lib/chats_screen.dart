import 'package:flutter/material.dart';
import 'package:hotel/home_screen.dart';
import 'package:hotel/favorites_screen.dart';
import 'package:hotel/my_bookings_screen.dart';
import 'package:hotel/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  int _selectedIndex = 3;

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const FavoritesScreen();
        break;
      case 2:
        screen = const MyBookingsScreen();
        break;
      case 3:
        screen = const ChatsScreen();
        break;
      case 4:
        screen = const ProfileScreen();
        break;
      default:
        screen = const HomeScreen();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Chats",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: user == null
          ? const Center(child: Text("Please login to see chats."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(user.uid)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No chats yet."));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final data = msg.data() as Map<String, dynamic>;

                    final text = data['text'] ?? '';
                    final sender = data['sender'] ?? 'System';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final timeString = timestamp != null
                        ? "${timestamp.toDate().day.toString().padLeft(2, '0')}-"
                              "${timestamp.toDate().month.toString().padLeft(2, '0')}-"
                              "${timestamp.toDate().year} "
                              "${timestamp.toDate().hour.toString().padLeft(2, '0')}:"
                              "${timestamp.toDate().minute.toString().padLeft(2, '0')}"
                        : '';

                    final hotelName = data['hotelName'] ?? '';
                    final totalPrice = data.containsKey('totalPrice')
                        ? (data['totalPrice'] as num).toDouble()
                        : 0.0;
                    final checkIn = data.containsKey('checkIn')
                        ? (data['checkIn'] as Timestamp).toDate()
                        : null;
                    final checkOut = data.containsKey('checkOut')
                        ? (data['checkOut'] as Timestamp).toDate()
                        : null;
                    final guests = data['guests'] ?? 0;
                    final rooms = data['rooms'] ?? 0;

                    return _buildChatCard(
                      name: sender,
                      message: text,
                      time: timeString,
                      hasUnread: false,
                      onTap: () {
                        if (hotelName.isNotEmpty) {
                          _showPaymentDetails(
                            hotelName,
                            totalPrice,
                            checkIn,
                            checkOut,
                            guests,
                            rooms,
                            timestamp,
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade600,
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: _selectedIndex,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'My bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard({
    required String name,
    required String message,
    required String time,
    required bool hasUnread,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue[50],
                  child: const Icon(
                    Icons.person_rounded,
                    size: 28,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    if (hasUnread) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDetails(
    String hotelName,
    double totalPrice,
    DateTime? checkIn,
    DateTime? checkOut,
    int guests,
    int rooms,
    Timestamp? transactionTime,
  ) {
    String transactionString = transactionTime != null
        ? "${transactionTime.toDate().day.toString().padLeft(2, '0')}-"
              "${transactionTime.toDate().month.toString().padLeft(2, '0')}-"
              "${transactionTime.toDate().year} "
              "${transactionTime.toDate().hour.toString().padLeft(2, '0')}:"
              "${transactionTime.toDate().minute.toString().padLeft(2, '0')}"
        : 'N/A';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Payment Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hotel: $hotelName"),
              Text("Total Price: \₱${totalPrice.toStringAsFixed(2)}"),
              if (checkIn != null && checkOut != null)
                Text(
                  "Stay: ${checkIn.day}-${checkIn.month}-${checkIn.year} to ${checkOut.day}-${checkOut.month}-${checkOut.year}",
                ),
              Text("Guests: $guests"),
              Text("Rooms: $rooms"),
              const SizedBox(height: 6),
              Text("Transaction Time: $transactionString"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
