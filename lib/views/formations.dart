import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

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

  static const String _uploadApiUrl = 'https://numedu.onrender.com/api/images/';

  @override
  void dispose() {
    nomController.dispose();
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
      final data = {
        'formationID': docRef.id,
        'title': title,
        'descriptions': descriptions,
        'add_date': FieldValue.serverTimestamp(),
        'image': imageUrl,
        'formationModuleID': <String>[],
        'published': false,
      };
      await docRef.set(data);

      nomController.clear();
      descriptionsController.clear();
      imageController.clear();
      _imageBytes = null;

      Navigator.of(context).pop(); // loader
      Navigator.of(context).pop(); // dialog
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (_) => setState(() {}), // Rafraîchit le tableau
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text("Ajout de formation"),
                      titleTextStyle: TextStyle(
                        color: Colors.blueGrey[800],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      content: SizedBox(
                        width: 350,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 15),
                            SizedBox(
                              height: 36,
                              child: TextField(
                                controller: nomController,
                                decoration: InputDecoration(
                                  labelText: 'Titre de la formation',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                                ),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: descriptionsController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Descriptions',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Image de mise en avant",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _pickImage,
                                      icon: const Icon(Icons.upload_file, color: Colors.white, size: 18),
                                      label: const Text("Choisir un fichier"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF23468E),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                        textStyle: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          imageController.text.isEmpty
                                              ? "Aucun fichier sélectionné"
                                              : imageController.text,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_imageBytes != null) ...[
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      _imageBytes!,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                          ),
                          child: const Text("Annuler"),
                        ),
                        ElevatedButton(
                          onPressed: () => _submitFormation(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF23468E),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Ajouter"),
                        ),
                      ],
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
                      .orderBy('add_date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final formations = snapshot.data!.docs.where((doc) {
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
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Nom')),
                            DataColumn(label: Text('Descriptions')),
                            DataColumn(label: Text('Date d\'ajout')),
                            DataColumn(label: Text('Modules')),
                            DataColumn(label: Text('Publiée')),
                          ],
                          rows: formations.isNotEmpty
                              ? formations.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  return DataRow(cells: [
                                    DataCell(Text(data['formationID'] ?? '', overflow: TextOverflow.ellipsis)),
                                    DataCell(
                                      SizedBox(
                                        width: 150, // largeur max de la colonne "Nom"
                                        child: Text(
                                          data['title'] ?? '',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 250, // largeur max de la colonne "Descriptions"
                                        child: Text(
                                          data['descriptions'] ?? '',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(
                                      data['add_date'] != null
                                          ? (data['add_date'] as Timestamp).toDate().toString().split(' ')[0]
                                          : '',
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    DataCell(
                                      Text(
                                        ((data['formationModuleID'] as List<dynamic>?)?.length ?? 0).toString(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (data['published'] as bool? ?? false) ? Colors.green : Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          (data['published'] as bool? ?? false) ? 'Publié' : 'Non publié',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ]);
                                }).toList()
                              : [
                                  DataRow(
                                    cells: List.generate(6, (index) => const DataCell(Text('-'))),
                                  ),
                                ],
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
