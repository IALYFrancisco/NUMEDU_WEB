import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/formation_form.dart';
import '../widgets/module_form.dart';
import '../models/formation.dart';
import '../models/formation_module.dart'; // <-- Import du modèle module

class FormationsPage extends StatefulWidget {
  const FormationsPage({super.key});

  @override
  State<FormationsPage> createState() => _FormationsPageState();
}

class _FormationsPageState extends State<FormationsPage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController introductionController = TextEditingController();
  final TextEditingController descriptionsController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  Uint8List? _imageBytes;
  static const String _uploadApiUrl = 'https://numedu.onrender.com/api/images/';

  @override
  void dispose() {
    nomController.dispose();
    introductionController.dispose();
    descriptionsController.dispose();
    imageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        imageController.text = result.files.single.name;
        _imageBytes = result.files.single.bytes;
      });
    }
  }

  Future<String?> _uploadImageToApi({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final uri = Uri.parse(_uploadApiUrl);
      final request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: filename));
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        return (json['url'] ?? json['image'] ?? json['file'])?.toString();
      } else {
        debugPrint('Upload échoué (${streamed.statusCode}): $body');
        return null;
      }
    } catch (e) {
      debugPrint('Erreur upload: $e');
      return null;
    }
  }

  Future<void> _submitFormation(BuildContext context) async {
    final title = nomController.text.trim();
    final introduction = introductionController.text.trim();
    final description = descriptionsController.text.trim();

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

    String imageUrl = '';
    if (_imageBytes != null && imageController.text.isNotEmpty) {
      final url = await _uploadImageToApi(bytes: _imageBytes!, filename: imageController.text);
      if (url == null || url.isEmpty) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'upload de l'image.")),
        );
        return;
      }
      imageUrl = url;
    }

    try {
      final col = FirebaseFirestore.instance.collection('formations');
      final docRef = col.doc();
      final formation = Formation(
        formationId: docRef.id,
        title: title,
        description: description,
        addDate: DateTime.now(),
        image: imageUrl,
        formationModuleIds: [],
        published: false,
        introduction: introduction,
      );

      await docRef.set(formation.toJson());

      nomController.clear();
      introductionController.clear();
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
          content: Text(!currentStatus
              ? 'Formation publiée avec succès.'
              : 'Formation dépubliée.'),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
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
                      introductionController: introductionController,
                      descriptionsController: descriptionsController,
                      imageController: imageController,
                      onPickImage: _pickImage,
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
                  stream: FirebaseFirestore.instance
                      .collection('formations')
                      .orderBy('addDate', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final filteredFormations = snapshot.data!.docs
                        .map((doc) => Formation.fromJson(doc.data() as Map<String, dynamic>))
                        .where((f) => f.title.toLowerCase().contains(searchController.text.toLowerCase()))
                        .toList();

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
                              ? filteredFormations.map((f) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(f.formationId, overflow: TextOverflow.ellipsis)),
                                      DataCell(SizedBox(width: 150, child: Text(f.title, overflow: TextOverflow.ellipsis))),
                                      DataCell(SizedBox(width: 250, child: Text(f.description, overflow: TextOverflow.ellipsis))),
                                      DataCell(Text(f.addDate != null ? f.addDate!.toLocal().toString().split(' ')[0] : '', overflow: TextOverflow.ellipsis)),
                                      DataCell(Text(f.formationModuleIds.length.toString())),
                                      DataCell(FutureBuilder<int>(
                                        future: _getSubscribersCount(f.formationId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const SizedBox(
                                              width: 15,
                                              height: 15,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            );
                                          }
                                          if (snapshot.hasError) return const Text("Erreur");
                                          return Text(snapshot.data.toString());
                                        },
                                      )),
                                      DataCell(Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: f.published ? Colors.green : Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          f.published ? 'Publiée' : 'Non publiée',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      )),
                                      DataCell(PopupMenuButton<String>(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 4,
                                        onSelected: (value) {
                                          if (value == 'modifier') {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Modifier action')),
                                            );
                                          } else if (value == 'supprimer') {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text("Confirmation"),
                                                content: const Text("Voulez-vous vraiment supprimer cette formation ?"),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Annuler")),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      _deleteFormation(f.formationId);
                                                    },
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                    child: const Text("Supprimer"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else if (value == 'publier') {
                                            _togglePublish(f.formationId, f.published);
                                          } else if (value == 'ajouter_module') {
                                            // **Affiche le formulaire module avec WYSIWYG**
                                            showDialog(
                                              context: context,
                                              builder: (_) => ModuleForm(
                                                formationId: f.formationId,
                                              ),
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(value: 'modifier', height: 32, child: Text("Modifier", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                          const PopupMenuItem(value: 'supprimer', height: 32, child: Text("Supprimer", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                          PopupMenuItem(value: 'publier', height: 32, child: Text(f.published ? "Dépublier" : "Publier", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                          const PopupMenuItem(value: 'ajouter_module', height: 32, child: Text("Ajouter un module", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                        ],
                                        child: const Icon(Icons.more_vert),
                                      )),
                                    ],
                                  );
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
