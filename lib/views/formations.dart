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
  // Controllers
  final TextEditingController nomController = TextEditingController();
  final TextEditingController formateurController = TextEditingController(); // pour descriptions
  final TextEditingController imageController = TextEditingController();
  Uint8List? _imageBytes;

  static const String _uploadApiUrl = 'https://numedu.onrender.com/api/images/';

  @override
  void dispose() {
    nomController.dispose();
    formateurController.dispose();
    imageController.dispose();
    super.dispose();
  }

  // --- Sélection d'image ---
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

  // --- Upload image vers API ---
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

  // --- Soumission vers Firestore ---
  Future<void> _submitFormation(BuildContext context) async {
    final title = nomController.text.trim();
    final descriptions = formateurController.text.trim();

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
        'publised': false,
      };
      await docRef.set(data);

      nomController.clear();
      formateurController.clear();
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
                            const SizedBox(height: 30),
                            // Image
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
                            const SizedBox(height: 30),
                            // Descriptions
                            TextField(
                              controller: formateurController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Descriptions',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              style: const TextStyle(fontSize: 12),
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
          // Tableau statique
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(const Color(0xFF23468E)),
                  headingTextStyle: const TextStyle(color: Colors.white),
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
