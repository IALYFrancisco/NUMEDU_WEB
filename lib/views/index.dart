import 'package:flutter/material.dart';
import 'formations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 🟢 Page actuelle affichée
  Widget currentPage = const Center(child: Text("Accueil", style: TextStyle(fontSize: 24)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ✅ Sidebar
          Container(
            width: 175,
            color: const Color(0xFF23468E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  height: 80,
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

                // 🟢 Menus
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white, size: 22),
                  title: const Text("Accueil", style: TextStyle(color: Colors.white, fontSize: 15)),
                  onTap: () {
                    setState(() {
                      currentPage = const Center(
                        child: Text("Accueil", style: TextStyle(fontSize: 24)),
                      );
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.library_books, color: Colors.white, size: 22),
                  title: const Text("Formations", style: TextStyle(color: Colors.white, fontSize: 15)),
                  onTap: () {
                    setState(() {
                      currentPage = const FormationsPage(); // change le contenu
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white, size: 22),
                  title: const Text("Paramètres", style: TextStyle(color: Colors.white, fontSize: 15)),
                  onTap: () {
                    setState(() {
                      currentPage = const Center(
                        child: Text("Paramètres", style: TextStyle(fontSize: 24)),
                      );
                    });
                  },
                ),
              ],
            ),
          ),

          // ✅ Contenu principal
          Expanded(
            child: Container(
              color: Colors.white,
              child: currentPage, // affichage dynamique
            ),
          ),
        ],
      ),
    );
  }
}
