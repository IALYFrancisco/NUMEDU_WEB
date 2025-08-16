import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashnoard',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ✅ Sidebar
          Container(
            width: 250,
            color: Colors.blueGrey.shade900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Header avec texte + logo
                DrawerHeader(
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
                      // 👉 Remplace par ton logo
                      Image.asset(
                        "assets/images/logo-de-numedu.png", // place ton logo dans /assets
                        height: 40,
                        width: 40,
                      ),
                    ],
                  ),
                ),

                // ✅ Liens du menu
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: const Text("Accueil", style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text("Paramètres", style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
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
