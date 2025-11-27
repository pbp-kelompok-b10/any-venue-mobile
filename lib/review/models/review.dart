// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

List<Review> reviewFromJson(String str) => List<Review>.from(json.decode(str).map((x) => Review.fromJson(x)));

String reviewToJson(List<Review> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Review {
    int id;
    int rating;
    String comment;
    String user;
    int userId;
    String venueName;
    int venueId;
    String createdAt;
    String lastModified;

    Review({
        required this.id,
        required this.rating,
        required this.comment,
        required this.user,
        required this.userId,
        required this.venueName,
        required this.venueId,
        required this.createdAt,
        required this.lastModified,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        rating: json["rating"],
        comment: json["comment"],
        user: json["user"],
        userId: json["user_id"],
        venueName: json["venue_name"],
        venueId: json["venue_id"],
        createdAt: json["created_at"],
        lastModified: json["last_modified"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "rating": rating,
        "comment": comment,
        "user": user,
        "user_id": userId,
        "venue_name": venueName,
        "venue_id": venueId,
        "created_at": createdAt,
        "last_modified": lastModified,
    };
}
