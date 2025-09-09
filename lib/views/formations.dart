import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/formation.dart';
import '../widgets/formation_form.dart';

class FormationsPage extends StatefulWidget {
  const FormationsPage({super.key});

  @override
  State<FormationsPage> createState() => _FormationsPageState();
}

class _FormationsPageState extends State<FormationsPage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController descriptionsController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  Uint8List? _imageBytes;

  @override
  void dispose() {
    nomController.dispose();
    descriptionsController.dispose();
    imageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteFormation(String formationId) async {
    try {
      await FirebaseFirestore.instance.collection('formations').doc(formationId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formation supprimée avec succès.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

  Future<void> _togglePublish(String formationId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('formations')
          .doc(formationId)
          .update({'published': !currentStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!currentStatus ? 'Formation publiée avec succès.' : 'Formation dépubliée.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du changement de statut: $e')),
      );
    }
  }

  Future<int> _getSubscribersCount(String formationId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('userFormations')
          .where('formationId', isEqualTo: formationId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint("Erreur lors du comptage: $e");
      return 0;
    }
  }

  Future<void> _submitFormation(BuildContext context) async {
    final title = nomController.text.trim();
    final descriptions = descriptionsController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le titre est obligatoire.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final col = FirebaseFirestore.instance.collection('formations');
      final docRef = col.doc();
      final data = {
        'formationID': docRef.id,
        'title': title,
        'descriptions': descriptions,
        'add_date': FieldValue.serverTimestamp(),
        'image': '',
        'formationModuleID': <String>[],
        'published': false,
      };
      await docRef.set(data);

      nomController.clear();
      descriptionsController.clear();
      imageController.clear();
      _imageBytes = null;

      Navigator.of(context).pop();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formation ajoutée avec succès.')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur Firestore: $e')),
      );
    }
  }

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
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 300,
                height: 36,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une formation...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => FormationForm(
                      nomController: nomController,
                      descriptionsController: descriptionsController,
                      imageController: imageController,
                      onPickImage: () async {},
                      onSubmit: _submitFormation,
                      imageBytes: _imageBytes,
                    ),
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
          const SizedBox(height: 60),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('formations').orderBy('add_date', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final filteredFormations = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['title']?.toString().toLowerCase() ?? '';
                      final search = searchController.text.toLowerCase();
                      return title.contains(search);
                    }).toList();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(const Color(0xFF23468E)),
                          headingTextStyle: const TextStyle(color: Colors.white),
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Nom')),
                            DataColumn(label: Text('Descriptions')),
                            DataColumn(label: Text('Date d\'ajout')),
                            DataColumn(label: Text('Modules')),
                            DataColumn(label: Text('Abonnés')),
                            DataColumn(label: Text('Publiée')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: filteredFormations.isNotEmpty
                              ? filteredFormations.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  return DataRow(cells: [
                                    DataCell(Text(data['formationID'] ?? '', overflow: TextOverflow.ellipsis)),
                                    DataCell(SizedBox(width: 150, child: Text(data['title'] ?? '', overflow: TextOverflow.ellipsis))),
                                    DataCell(SizedBox(width: 250, child: Text(data['descriptions'] ?? '', overflow: TextOverflow.ellipsis))),
                                    DataCell(Text(
                                      data['add_date'] != null ? (data['add_date'] as Timestamp).toDate().toString().split(' ')[0] : '',
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    DataCell(Text(((data['formationModuleID'] as List<dynamic>?)?.length ?? 0).toString(), overflow: TextOverflow.ellipsis)),
                                    DataCell(FutureBuilder<int>(
                                      future: _getSubscribersCount(data['formationID']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2));
                                        }
                                        if (snapshot.hasError) return const Text("Erreur");
                                        return Text(snapshot.data.toString());
                                      },
                                    )),
                                    DataCell(Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (data['published'] as bool? ?? false) ? Colors.green : Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        (data['published'] as bool? ?? false) ? 'Publiée' : 'Non publiée',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    )),
                                    DataCell(
                                      Center(
                                        child: PopupMenuButton<String>(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 4,
                                          onSelected: (value) {
                                            if (value == 'modifier') {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modifier action')));
                                            } else if (value == 'supprimer') {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text("Confirmation"),
                                                  content: const Text("Voulez-vous vraiment supprimer cette formation ?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text("Annuler"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        _deleteFormation(data['formationID']);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                        foregroundColor: Colors.white,
                                                      ),
                                                      child: const Text("Supprimer"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (value == 'publier') {
                                              _togglePublish(data['formationID'], data['published'] as bool? ?? false);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'modifier',
                                              height: 32,
                                              child: Text("Modifier", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                            ),
                                            const PopupMenuItem(
                                              value: 'supprimer',
                                              height: 32,
                                              child: Text("Supprimer", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                            ),
                                            PopupMenuItem(
                                              value: 'publier',
                                              height: 32,
                                              child: Text(
                                                (data['published'] as bool? ?? false) ? "Dépublier" : "Publier",
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                          child: const Icon(Icons.more_vert),
                                        ),
                                      ),
                                    ),
                                  ]);
                                }).toList()
                              : [DataRow(cells: List.generate(8, (index) => const DataCell(Text('-'))))],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}