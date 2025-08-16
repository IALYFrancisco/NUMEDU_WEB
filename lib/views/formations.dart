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
          Text(
            "Formations",
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[800]
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Ici s’affichera la liste des formations",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
