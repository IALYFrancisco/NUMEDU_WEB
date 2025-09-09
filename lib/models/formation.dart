import 'package:cloud_firestore/cloud_firestore.dart';

class Formation {
  String formationId;
  String title;
  String description;
  String introduction;
  String image;
  List<String> formationModuleIds;
  bool published;
  DateTime? addDate;

  Formation({
    required this.formationId,
    required this.title,
    required this.description,
    required this.introduction,
    required this.image,
    required this.formationModuleIds,
    required this.published,
    this.addDate,
  });

  /// Crée une instance Formation à partir d'un Map (Firestore)
  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      formationId: json['formationId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      introduction: json['introduction'] ?? '',
      image: json['image'] ?? '',
      formationModuleIds: List<String>.from(json['formationModuleIds'] ?? []),
      published: json['published'] ?? false,
      addDate: json['addDate'] != null
          ? (json['addDate'] is Timestamp
              ? (json['addDate'] as Timestamp).toDate()
              : DateTime.tryParse(json['addDate'].toString()))
          : null,
    );
  }

  /// Convertit l'instance Formation en Map pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'formationId': formationId,
      'title': title,
      'description': description,
      'introduction': introduction,
      'image': image,
      'formationModuleIds': formationModuleIds,
      'published': published,
      'addDate': addDate != null ? Timestamp.fromDate(addDate!) : FieldValue.serverTimestamp(),
    };
  }
}