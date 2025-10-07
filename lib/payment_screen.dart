import 'package:flutter/material.dart';
import 'package:hotel/payment_success_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel/model/hotel_model.dart';

class PaymentScreen extends StatefulWidget {
  final Hotel hotel;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final int rooms;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.hotel,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.rooms,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = "GCash";
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.totalAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBookingToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Save booking
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookings')
        .add({
          'hotelName': widget.hotel.name,
          'hotelLocation': widget.hotel.location,
          'hotelImageUrl': widget.hotel.imageUrl,
          'checkIn': widget.checkInDate,
          'checkOut': widget.checkOutDate,
          'guests': widget.guests,
          'rooms': widget.rooms,
          'totalPrice': widget.totalAmount,
          'createdAt': FieldValue.serverTimestamp(),
        });

    // Save as chat message with timestamp
    // Save as chat message with timestamp (initial pending state)
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(user.uid)
        .collection('messages')
        .add({
          'sender': 'System',
          'text': 'Payment is waiting for admin validation.',
          'hotelName': widget.hotel.name,
          'totalPrice': widget.totalAmount,
          'checkIn': widget.checkInDate,
          'checkOut': widget.checkOutDate,
          'guests': widget.guests,
          'rooms': widget.rooms,
          'timestamp': FieldValue.serverTimestamp(),
        });

    // Also mark guest’s payment status as Pending
    await FirebaseFirestore.instance
        .collection('admin_manage_guest')
        .doc(user.uid)
        .set({
          'paymentStatus': 'Pending',
          'username': user.displayName ?? 'Guest',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Amount Section
            Center(
              child: Column(
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "\₱${widget.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method Section
            const Text(
              "Payment method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMethod = "GCash";
                    });
                  },
                  child: _buildPaymentMethod(
                    "GCash",
                    "assets/images/gcash.jpg",
                    _selectedMethod == "GCash",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMethod = "Maya";
                    });
                  },
                  child: _buildPaymentMethod(
                    "Maya",
                    "assets/images/maya.jpg",
                    _selectedMethod == "Maya",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount Input
            const Text(
              "Amount",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _buildAmountInputField(),
            const SizedBox(height: 16),

            // Reference Number
            const Text(
              "Reference Number",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: const Text(
                "**** **** ****",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 32),
            // Pay Now Button
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.07,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveBookingToFirebase();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentSuccessScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "PAY NOW",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String name, String imagePath, bool isSelected) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: 35),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAmountInputField() {
    return TextField(
      controller: _amountController,
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      decoration: InputDecoration(
        hintText: "0.00",
        hintStyle: const TextStyle(color: Colors.grey),
        prefixText: "\₱",
        prefixStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }
}
