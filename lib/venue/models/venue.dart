import 'dart:convert';
import 'city.dart';
import 'category.dart';
import 'package:any_venue/account/models/profile.dart';

List<Venue> venueFromJson(String str) => 
    List<Venue>.from(json.decode(str).map((x) => Venue.fromJson(x)));

String venueToJson(List<Venue> data) => 
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Venue {
  final int id;
  final String name;
  final int price;
  final City city;
  final Category category;
  final VenueOwner owner;
  final String type;
  final String address;
  final String description;
  final String imageUrl;

  Venue({
    required this.id,
    required this.name,
    required this.price,
    required this.city,
    required this.category,
    required this.owner,
    required this.type,
    required this.address,
    required this.description,
    required this.imageUrl,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
    id: json["id"],
    name: json["name"] ?? "No Name",
    price: json["price"] ?? 0,
    
    // Nested Objects
    city: City.fromJson(json["city"]),
    category: Category.fromJson(json["category"]),
    owner: VenueOwner.fromJson(json["owner"]),

    type: json["type"] ?? "-",
    address: json["address"] ?? "-",
    description: json["description"] ?? "-",
    imageUrl: json["image_url"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "city": city.toJson(),
    "category": category.toJson(),
    "owner": owner.toJson(),
    "type": type,
    "address": address,
    "description": description,
    "image_url": imageUrl,
  };
}

class VenueOwner {
  final int id;
  final String username;

  VenueOwner({required this.id, required this.username});

  factory VenueOwner.fromJson(Map<String, dynamic> json) => VenueOwner(
    id: json["id"],
    username: json["username"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
  };
}