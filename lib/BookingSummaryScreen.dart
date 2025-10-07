import 'package:flutter/material.dart';
import 'package:hotel/model/hotel_model.dart';
import 'package:hotel/payment_screen.dart';

class BookingSummaryScreen extends StatelessWidget {
  final Hotel hotel;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final int rooms;

  const BookingSummaryScreen({
    super.key,
    required this.hotel,
    required this.checkInDate,
    required this.checkOutDate,
    this.guests = 1,
    this.rooms = 1,
  });

  @override
  Widget build(BuildContext context) {
    final int nights = checkOutDate.difference(checkInDate).inDays;
    const double tax = 30;
    final double subtotal = hotel.price * nights * rooms;
    final double total = subtotal + tax;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Booking Summary",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Hotel Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hotel.imageUrl.isNotEmpty
                        ? FadeInImage.assetNetwork(
                            placeholder:
                                'assets/placeholder.png', // fallback image in your assets
                            image: hotel.imageUrl,
                            width: MediaQuery.of(context).size.width * 0.28,
                            height: MediaQuery.of(context).size.width * 0.28,
                            fit: BoxFit.cover,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.28,
                                height:
                                    MediaQuery.of(context).size.width * 0.28,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width * 0.28,
                            height: MediaQuery.of(context).size.width * 0.28,
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
                          hotel.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hotel.location,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "\₱${hotel.price.toStringAsFixed(0)} Pesos / night",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// Booking Details Section
            const Text(
              "BOOKING DETAILS",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            _buildBookingRow(
              "Check-in",
              "${checkInDate.day}-${checkInDate.month}-${checkInDate.year}",
            ),
            _buildBookingRow(
              "Check-out",
              "${checkOutDate.day}-${checkOutDate.month}-${checkOutDate.year}",
            ),
            _buildBookingRow("Guests", guests.toString()),
            _buildBookingRow("Room(s)", rooms.toString()),

            const SizedBox(height: 28),

            /// Pricing Details Section
            const Text(
              "PRICING DETAILS",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            _buildPricingRow(
              "Amount",
              "\₱${hotel.price.toStringAsFixed(0)} x $nights x $rooms",
            ),
            _buildPricingRow("Tax", "\₱${tax.toStringAsFixed(0)}"),
            _buildPricingRow(
              "Total",
              "\₱${total.toStringAsFixed(0)}",
              isTotal: true,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),

      /// Bottom CTA
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentScreen(
                    hotel: hotel,
                    checkInDate: checkInDate,
                    checkOutDate: checkOutDate,
                    guests: guests,
                    rooms: rooms,
                    totalAmount: total,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "CONTINUE TO PAYMENT",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Booking Row Helper
  Widget _buildBookingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  /// Pricing Row Helper
  Widget _buildPricingRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Colors.black87 : Colors.grey[800],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
              color: isTotal ? Colors.blue : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
