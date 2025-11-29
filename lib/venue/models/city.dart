import 'dart:convert';

List<City> cityFromJson(String str) => List<City>.from(json.decode(str).map((x) => City.fromJson(x)));
String cityToJson(List<City> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class City {
    int id;
    String name;

    City({required this.id, required this.name});

    factory City.fromJson(Map<String, dynamic> json) => City(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}