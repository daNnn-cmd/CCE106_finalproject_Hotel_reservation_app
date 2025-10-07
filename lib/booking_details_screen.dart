import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingDetailsScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final String hotelName = bookingData['hotelName'] ?? 'No Name';
    final String hotelLocation = bookingData['hotelLocation'] ?? 'No Location';
    final String hotelImageUrl = bookingData['hotelImageUrl'] ?? '';
    final DateTime checkInDate = (bookingData['checkIn'] as Timestamp).toDate();
    final DateTime checkOutDate = (bookingData['checkOut'] as Timestamp)
        .toDate();
    final int guests = bookingData['guests'] ?? 0;
    final int rooms = bookingData['rooms'] ?? 0;
    final double totalPrice = bookingData['totalPrice']?.toDouble() ?? 0.0;

    final DateTime createdAt =
        (bookingData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    final int nights = checkOutDate.difference(checkInDate).inDays;
    const double tax = 30.0;
    final double subtotal = totalPrice - tax;

    final transactionDate = DateFormat('dd MMM yyyy').format(createdAt);
    final transactionTime = DateFormat('hh:mm a').format(createdAt);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Booking Details",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Header
            Text(
              "Transaction Receipt",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Date: $transactionDate   •   Time: $transactionTime",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Main Card
            Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: hotelImageUrl.isNotEmpty
                              ? FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder.png',
                                  image: hotelImageUrl,
                                  width: screenWidth * 0.28,
                                  height: screenWidth * 0.28,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: screenWidth * 0.28,
                                  height: screenWidth * 0.28,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.hotel,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotelName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.redAccent,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      hotelLocation,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30, thickness: 1, color: Colors.grey),

                    // Booking Details
                    _buildDetailRow(
                      context,
                      "Check-in",
                      DateFormat('dd-MM-yyyy').format(checkInDate),
                      Icons.login,
                    ),
                    _buildDetailRow(
                      context,
                      "Check-out",
                      DateFormat('dd-MM-yyyy').format(checkOutDate),
                      Icons.logout,
                    ),
                    _buildDetailRow(
                      context,
                      "Nights",
                      "$nights night${nights == 1 ? '' : 's'}",
                      Icons.nights_stay,
                    ),
                    _buildDetailRow(
                      context,
                      "Guests",
                      "$guests guest${guests == 1 ? '' : 's'}",
                      Icons.person,
                    ),
                    _buildDetailRow(
                      context,
                      "Room(s)",
                      "$rooms room${rooms == 1 ? '' : 's'}",
                      Icons.king_bed,
                    ),
                    const Divider(height: 30, thickness: 1, color: Colors.grey),

                    // Pricing Details
                    _buildPriceRow(
                      "Subtotal",
                      "\₱${subtotal.toStringAsFixed(2)}",
                      false,
                    ),
                    _buildPriceRow(
                      "Tax & Fees",
                      "\₱${tax.toStringAsFixed(2)}",
                      false,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _buildPriceRow(
                        "Total",
                        "\₱${totalPrice.toStringAsFixed(2)}",
                        true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for booking details rows
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: Colors.blue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Helper method for pricing rows
  Widget _buildPriceRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? Colors.blue[800] : Colors.black54,
          ),
        ),
      ],
    );
  }
}
