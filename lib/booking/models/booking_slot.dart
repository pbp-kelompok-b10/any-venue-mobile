import 'dart:convert';

List<BookingSlot> bookingSlotFromJson(String str) =>
    List<BookingSlot>.from(json.decode(str).map((x) => BookingSlot.fromJson(x)));

String bookingSlotToJson(List<BookingSlot> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BookingSlot {
  BookingSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    required this.isBookedByUser,
    required this.price,
  });

  int id;
  String startTime;
  String endTime;
  bool isBooked;
  bool isBookedByUser;
  int price;

  factory BookingSlot.fromJson(Map<String, dynamic> json) => BookingSlot(
        id: json["id"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        isBooked: json["is_booked"],
        isBookedByUser: json["is_booked_by_user"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "start_time": startTime,
        "end_time": endTime,
        "is_booked": isBooked,
        "is_booked_by_user": isBookedByUser,
        "price": price,
      };
}
