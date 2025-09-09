import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../models/formation_module.dart';

class ModuleForm extends StatefulWidget {
  final String formationId;

  const ModuleForm({super.key, required this.formationId});

  @override
  State<ModuleForm> createState() => _ModuleFormState();
}

class _ModuleFormState extends State<ModuleForm> {
  final TextEditingController titleController = TextEditingController();
  final quill.QuillController quillController = quill.QuillController.basic();

  bool isSubmitting = false;

  Future<void> _submitModule() async {
    if (titleController.text.trim().isEmpty) return;

    setState(() => isSubmitting = true);

    final docRef = FirebaseFirestore.instance.collection('formationModules').doc();
    final module = FormationModule(
      moduleId: docRef.id,
      formationId: widget.formationId,
      title: titleController.text.trim(),
      content: quillController.document.toDelta().toJson(),
    );

    await docRef.set(module.toJson());

    // Ajouter l'ID du module dans la formation correspondante
    final formationRef = FirebaseFirestore.instance.collection('formations').doc(widget.formationId);
    await formationRef.update({
      'formationModuleIds': FieldValue.arrayUnion([docRef.id])
    });

    setState(() => isSubmitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Module ajouté avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ajouter un module"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Titre du module"),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: quill.QuillEditor.basic(
                controller: quillController,
                readOnly: false,
              ),
            ),
            quill.QuillToolbar.basic(controller: quillController),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submitModule,
          child: isSubmitting ? const CircularProgressIndicator() : const Text("Ajouter"),
        ),
      ],
    );
  }
}