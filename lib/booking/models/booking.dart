import 'dart:convert';

// Model untuk response GET /booking/mybookings/json/
// Format default Django serialize:
// [
//   {
//     "model": "booking.booking",
//     "pk": 10,
//     "fields": {
//       "user": 3,
//       "slot": 1,
//       "total_price": 150000,
//       "created_at": "2025-12-07T10:00:00Z"
//     }
//   }
// ]

List<Booking> bookingFromJson(String str) =>
    List<Booking>.from(json.decode(str).map((x) => Booking.fromJson(x)));

String bookingToJson(List<Booking> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Booking {
  Booking({
    required this.id,
    required this.user,
    required this.slot,
    required this.totalPrice,
    required this.createdAt,
  });

  int id;
  int user;
  int slot;
  int totalPrice;
  DateTime createdAt;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json["pk"],
        user: json["fields"]["user"],
        slot: json["fields"]["slot"],
        totalPrice: json["fields"]["total_price"],
        createdAt: DateTime.parse(json["fields"]["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "pk": id,
        "fields": {
          "user": user,
          "slot": slot,
          "total_price": totalPrice,
          "created_at": createdAt.toIso8601String(),
        },
      };
}
