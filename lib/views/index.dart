import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ✅ Sidebar
          Container(
            width: 175,
            color:  const Color(0xFF23468E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Container(
                height: 80, // 🔽 ajuste la hauteur ici (par ex. 60, 80, 100…)
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      "Numédu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      "assets/images/logo-de-numedu.png",
                      width: 30,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 75),

                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white, size: 22),
                  title: const Text("Accueil", style: TextStyle(color: Colors.white, fontSize: 15)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.library_books, color: Colors.white, size: 22),
                  title: const Text("Formations", style: TextStyle(color: Colors.white, fontSize: 15)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white, size: 22),
                  title: const Text("Paramètres", style: TextStyle(color: Colors.white, fontSize: 15)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white, size: 22),
                  title: const Text("Déconnexion", style: TextStyle(color: Colors.white, fontSize: 15)),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // ✅ Contenu principal
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: Text(
                  "Contenu principal ici",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}