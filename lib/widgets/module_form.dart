import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/formation_module.dart';
import 'package:file_selector/file_selector.dart';

class ModuleForm extends StatefulWidget {
  final String formationId;

  const ModuleForm({super.key, required this.formationId});

  @override
  State<ModuleForm> createState() => _ModuleFormState();
}

class _ModuleFormState extends State<ModuleForm> {
  final TextEditingController titleController = TextEditingController();
  final QuillController quillController = QuillController(
    document: Document(),
    selection: const TextSelection.collapsed(offset: 0),
  );

  bool isSubmitting = false;

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    super.dispose();
  }

  Future<void> _submitModule() async {
    if (titleController.text.trim().isEmpty) return;

    setState(() => isSubmitting = true);

    try {
      final docRef =
          FirebaseFirestore.instance.collection('formationModules').doc();

      final module = FormationModule(
        formationModuleId: docRef.id,
        title: titleController.text.trim(),
        contents: jsonEncode(quillController.document.toDelta().toJson()),
      );

      await docRef.set(module.toJson());

      final formationRef = FirebaseFirestore.instance
          .collection('formations')
          .doc(widget.formationId);

      await formationRef.update({
        'formationModuleIds': FieldValue.arrayUnion([docRef.id]),
      });

      setState(() => isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Module ajouté avec succès')),
      );
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout du module : $e")),
      );
    }
  }

  Future<String?> _pickFile() async {
    final typeGroup = XTypeGroup(
      label: 'media',
      extensions: ['jpg', 'png', 'jpeg', 'mp4', 'mov', 'avi'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      return file.path;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ajouter un module"),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration:
                    const InputDecoration(labelText: "Titre du module"),
              ),
              const SizedBox(height: 20),
              // Toolbar pour le Web
              QuillToolbar.basic(
                controller: quillController,
                onImagePickCallback: _pickFile,
                onVideoPickCallback: _pickFile,
              ),
              const SizedBox(height: 10),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: QuillEditor(
                  controller: quillController,
                  focusNode: FocusNode(),
                  scrollController: ScrollController(),
                  scrollable: true,
                  autoFocus: false,
                  readOnly: false,
                  expands: false,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submitModule,
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Ajouter"),
        ),
      ],
    );
  }
}