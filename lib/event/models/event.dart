import 'dart:convert';

List<EventEntry> eventEntryFromJson(String str) => List<EventEntry>.from(json.decode(str).map((x) => EventEntry.fromJson(x)));

String eventEntryToJson(List<EventEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventEntry {
    int id;
    String name;
    String description;
    DateTime date;
    String startTime;
    int registeredCount;
    String venueName;
    String venueAddress;
    String venueCategory;
    String venueType;
    String owner;
    int ownerId;
    String thumbnail;
    bool isOwner;

    EventEntry({
        required this.id,
        required this.name,
        required this.description,
        required this.date,
        required this.startTime,
        required this.registeredCount,
        required this.venueName,
        required this.venueAddress,
        required this.venueCategory,
        required this.venueType,
        required this.owner,
        required this.ownerId,
        required this.thumbnail,
        required this.isOwner,
    });

    factory EventEntry.fromJson(Map<String, dynamic> json) => EventEntry(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        date: DateTime.parse(json["date"]),
        startTime: json["start_time"],
        registeredCount: json["registered_count"],
        venueName: json["venue_name"],
        venueAddress: json["venue_address"],
        venueCategory: json["venue_category"],
        venueType: json["venue_type"],
        owner: json["owner"],
        ownerId: json["owner_id"],
        thumbnail: json["thumbnail"],
        isOwner: json["is_owner"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "start_time": startTime,
        "registered_count": registeredCount,
        "venue_name": venueName,
        "venue_address": venueAddress,
        "venue_category": venueCategory,
        "venue_type": venueType,
        "owner": owner,
        "owner_id": ownerId,
        "thumbnail": thumbnail,
        "is_owner": isOwner,
    };
}
