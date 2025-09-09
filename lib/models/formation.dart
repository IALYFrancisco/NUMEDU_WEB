class Formation {
  final String formationId;           // Identifiant unique de la formation
  final String title;                 // Titre de la formation
  final String description;           // Description de la formation (texte long)
  final DateTime addDate;             // Date d'ajout de la formation
  final String image;                 // Image mise en avant
  final List<String> formationModuleIds; // Liste des identifiants des modules
  final bool published;               // Formation publiée ou non
  final String introduction;          // Introduction de la formation

  Formation({
    required this.formationId,
    required this.title,
    required this.description,
    required this.addDate,
    required this.image,
    required this.formationModuleIds,
    required this.published,
    required this.introduction,
  });

  /// Convertir une Formation en JSON (ex: pour API ou Firebase)
  Map<String, dynamic> toJson() {
    return {
      'formationId': formationId,
      'title': title,
      'description': description,
      'addDate': addDate.toIso8601String(),
      'image': image,
      'formationModuleIds': formationModuleIds,
      'published': published,
      'introduction': introduction,
    };
  }

  /// Créer une Formation à partir d’un JSON
  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      formationId: json['formationId'],
      title: json['title'],
      description: json['description'],
      addDate: DateTime.parse(json['addDate']),
      image: json['image'],
      formationModuleIds: List<String>.from(json['formationModuleIds']),
      published: json['published'],
      introduction: json['introduction'],
    );
  }
}
