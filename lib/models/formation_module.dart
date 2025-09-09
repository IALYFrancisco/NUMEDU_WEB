class FormationModule {
  final String formationModuleId; // Identifiant du module
  final String title;             // Titre du module
  final List<String> contents;    // Contenus du module (liste de paragraphes, chapitres, etc.)

  FormationModule({
    required this.formationModuleId,
    required this.title,
    required this.contents,
  });

  /// Convertir un module en JSON
  Map<String, dynamic> toJson() {
    return {
      'formationModuleId': formationModuleId,
      'title': title,
      'contents': contents,
    };
  }

  /// Créer un module à partir d’un JSON
  factory FormationModule.fromJson(Map<String, dynamic> json) {
    return FormationModule(
      formationModuleId: json['formationModuleId'],
      title: json['title'],
      contents: List<String>.from(json['contents']),
    );
  }
}