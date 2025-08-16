import 'package:flutter/material.dart';

class FormationsPage extends StatelessWidget {
  const FormationsPage({super.key});

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
                    borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5), // 🔹 padding correct ici
                ),
                style: const TextStyle(fontSize: 14),
            ),
            ),


            // 🔹 Bouton Ajouter Formation
            ElevatedButton.icon(
            onPressed: () {
                // Ajouter une nouvelle formation
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
              scrollDirection: Axis.horizontal, // scroll horizontal pour toutes les colonnes
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // scroll vertical pour les lignes
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
