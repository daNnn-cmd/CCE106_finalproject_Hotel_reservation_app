import 'package:flutter/material.dart';
import 'package:hotel/my_bookings_screen.dart'; // import your bookings screen
import 'package:firebase_auth/firebase_auth.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  // 🔹 Function to save chat confirmation to Firestore
  Future<void> _savePaymentConfirmation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Image.asset(
                'assets/images/sucess.jpg',
                height: screenHeight * 0.35,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenHeight * 0.04),

              // Title
              const Text(
                "Congratulations!!",
                style: TextStyle(
                  fontSize: 24, // ✅ fixed size
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),

              // Subtitle
              const Text(
                "Your hotel stay is secured.\nCheck your bookings to view details!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16, // ✅ fixed size
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: screenHeight * 0.06),

              // Go to Bookings Button
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  onPressed: () async {
                    // 🔹 Save chat confirmation before navigating
                    await _savePaymentConfirmation();

                    // Navigate to the MyBookingsScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyBookingsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "GO TO BOOKINGS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // ✅ fixed size
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
