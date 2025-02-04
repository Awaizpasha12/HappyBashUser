// To parse this JSON data, do
//
//     final eventTypeModel = eventTypeModelFromJson(jsonString);

import 'dart:convert';

EventTypeModel eventTypeModelFromJson(String str) => EventTypeModel.fromJson(json.decode(str));

String eventTypeModelToJson(EventTypeModel data) => json.encode(data.toJson());

class EventTypeModel {
  List<Datum> data;

  EventTypeModel({
    required this.data,
  });

  factory EventTypeModel.fromJson(Map<String, dynamic> json) => EventTypeModel(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String name;
  dynamic createdAt;
  dynamic updatedAt;

  Datum({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
