class FormationModule {
  final String formationModuleId; // Identifiant unique du module
  final String title;             // Titre du module
  final String contents;          // Contenu (texte enrichi, HTML, etc.)

  FormationModule({
    required this.formationModuleId,
    required this.title,
    required this.contents,
  });

  /// Convertir en JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'formationModuleId': formationModuleId,
      'title': title,
      'contents': contents,
    };
  }

  /// Créer un module à partir de Firestore
  factory FormationModule.fromJson(Map<String, dynamic> json) {
    return FormationModule(
      formationModuleId: json['formationModuleId'],
      title: json['title'],
      contents: json['contents'],
    );
  }
}