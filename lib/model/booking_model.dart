import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel/model/hotel_model.dart';

class Booking {
  final Hotel hotel;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int rooms;
  final double totalPrice;

  Booking({
    required this.hotel,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.rooms,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'hotelName': hotel.name,
      'hotelLocation': hotel.location,
      'hotelImageUrl': hotel.imageUrl,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'guests': guests,
      'rooms': rooms,
      'totalPrice': totalPrice,
    };
  }
}
