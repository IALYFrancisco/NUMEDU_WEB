import 'package:flutter/material.dart';

class FormationsPage extends StatefulWidget {
  const FormationsPage({super.key});

  @override
  State<FormationsPage> createState() => _FormationsPageState();
}

class _FormationsPageState extends State<FormationsPage> {
  // Pour récupérer les valeurs saisies dans le formulaire
  TextEditingController nomController = TextEditingController();
  TextEditingController dureeController = TextEditingController();
  TextEditingController formateurController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Text(
            "Formations",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),

          const SizedBox(height: 50),

          // Barre de recherche + bouton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 300,
                height: 36, // hauteur totale réduite
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher une formation...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              // 🔹 Bouton Ajouter Formation
              ElevatedButton.icon(
                onPressed: () {
                  // Afficher le popup pour ajouter une formation
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text("Ajout de formation"),
                         titleTextStyle: TextStyle(
                            color: Colors.blueGrey[800], // couleur personnalisée
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // 🔹 border radius personnalisé
                        ),
                        content: SizedBox(
                          width: 300,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nomController,
                                decoration: const InputDecoration(
                                  labelText: 'Nom de la formation',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: dureeController,
                                decoration: const InputDecoration(
                                  labelText: 'Durée',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: formateurController,
                                decoration: const InputDecoration(
                                  labelText: 'Formateur',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[300], // couleur de fond du bouton Annuler
                                foregroundColor: Colors.black,     // couleur du texte
                                ),
                                child: const Text("Annuler"),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                print("Nom : ${nomController.text}");
                                print("Durée : ${dureeController.text}");
                                print("Formateur : ${formateurController.text}");
                                Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF23468E), // couleur de fond du bouton Ajouter
                                foregroundColor: Colors.white,             // couleur du texte
                                ),
                                child: const Text("Ajouter"),
                            ),
                        ]
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Ajouter formation"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23468E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 60), // espace avant le tableau

          // Tableau scrollable
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(const Color(0xFF23468E)),
                  headingTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Durée')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Formateur')),
                    DataColumn(label: Text('Date début')),
                    DataColumn(label: Text('Catégorie')),
                    DataColumn(label: Text('Niveau')),
                    DataColumn(label: Text('Langue')),
                    DataColumn(label: Text('Participants')),
                    DataColumn(label: Text('Commentaires')),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('1')),
                      DataCell(Text('Flutter débutants')),
                      DataCell(Text('4 semaines')),
                      DataCell(Text('En cours')),
                      DataCell(Text('Alice')),
                      DataCell(Text('01/08/2025')),
                      DataCell(Text('Développement')),
                      DataCell(Text('Débutant')),
                      DataCell(Text('FR')),
                      DataCell(Text('20')),
                      DataCell(Text('-')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('2')),
                      DataCell(Text('Django avancé')),
                      DataCell(Text('6 semaines')),
                      DataCell(Text('Terminé')),
                      DataCell(Text('Bob')),
                      DataCell(Text('15/07/2025')),
                      DataCell(Text('Web')),
                      DataCell(Text('Avancé')),
                      DataCell(Text('EN')),
                      DataCell(Text('15')),
                      DataCell(Text('Bien reçu')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('3')),
                      DataCell(Text('React Web')),
                      DataCell(Text('3 semaines')),
                      DataCell(Text('En cours')),
                      DataCell(Text('Charlie')),
                      DataCell(Text('20/08/2025')),
                      DataCell(Text('Web')),
                      DataCell(Text('Intermédiaire')),
                      DataCell(Text('EN')),
                      DataCell(Text('25')),
                      DataCell(Text('-')),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
