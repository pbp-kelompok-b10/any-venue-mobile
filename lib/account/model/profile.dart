// To parse this JSON data, do
//
//     final profile = profileFromJson(jsonString);

import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
    String username;
    String role;
    bool isOwner;
    DateTime lastLogin;
    DateTime createdAt;
    DateTime updatedAt;

    Profile({
        required this.username,
        required this.role,
        required this.isOwner,
        required this.lastLogin,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        username: json["username"],
        role: json["role"],
        isOwner: json["is_owner"],
        lastLogin: DateTime.parse(json["last_login"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "role": role,
        "is_owner": isOwner,
        "last_login": lastLogin.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}
