import 'dart:typed_data';
import 'package:flutter/material.dart';

class FormationForm extends StatefulWidget {
  final TextEditingController nomController;
  final TextEditingController introductionController; // 🔥 Nouveau champ
  final TextEditingController descriptionsController;
  final TextEditingController imageController;
  final Future<void> Function(BuildContext) onSubmit;
  final Future<void> Function()? onPickImage;
  final Uint8List? imageBytes;

  const FormationForm({
    super.key,
    required this.nomController,
    required this.introductionController, // 🔥
    required this.descriptionsController,
    required this.imageController,
    required this.onSubmit,
    required this.onPickImage,
    this.imageBytes,
  });

  @override
  State<FormationForm> createState() => _FormationFormState();
}

class _FormationFormState extends State<FormationForm> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              // Titre
              SizedBox(
                height: 36,
                child: TextField(
                  controller: widget.nomController,
                  decoration: InputDecoration(
                    labelText: 'Titre de la formation',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 15),
              // Introduction
              TextField(
                controller: widget.introductionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Introduction',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 15),
              // Description
              TextField(
                controller: widget.descriptionsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descriptions',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 15),
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
                        onPressed: widget.onPickImage,
                        icon: const Icon(Icons.upload_file,
                            color: Colors.white, size: 18),
                        label: const Text("Choisir un fichier"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23468E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.imageController.text.isEmpty
                                ? "Aucun fichier sélectionné"
                                : widget.imageController.text,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.imageBytes != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        widget.imageBytes!,
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
          onPressed: () => widget.onSubmit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF23468E),
            foregroundColor: Colors.white,
          ),
          child: const Text("Ajouter"),
        ),
      ],
    );
  }
}