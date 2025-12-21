import 'dart:convert';

List<Booking> bookingFromJson(String str) =>
    List<Booking>.from(json.decode(str).map((x) => Booking.fromJson(x)));

String bookingToJson(List<Booking> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Booking {
  Booking({
    required this.id,
    required this.slotId,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.totalPrice,
    required this.createdAt,
  });

  final int id;
  final int slotId;
  final DateTime slotDate;
  final String startTime;
  final String endTime;
  final BookingVenue venue;
  final int totalPrice;
  final DateTime createdAt;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json["id"],
        slotId: json["slot_id"],
        slotDate: DateTime.parse(json["slot_date"]),
        startTime: json["start_time"],
        endTime: json["end_time"],
        venue: BookingVenue.fromJson(json["venue"]),
        totalPrice: json["total_price"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "slot_id": slotId,
        "slot_date": slotDate.toIso8601String(),
        "start_time": startTime,
        "end_time": endTime,
        "venue": venue.toJson(),
        "total_price": totalPrice,
        "created_at": createdAt.toIso8601String(),
      };
}

class BookingVenue {
  BookingVenue({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.price,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String address;
  final String type;
  final int price;
  final String? imageUrl;

  factory BookingVenue.fromJson(Map<String, dynamic> json) => BookingVenue(
        id: json["id"],
        name: json["name"],
        address: json["address"],
        type: json["type"],
        price: json["price"],
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "type": type,
        "price": price,
        "image_url": imageUrl,
      };
}
