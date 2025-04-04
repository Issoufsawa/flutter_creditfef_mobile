import 'package:flutter/material.dart';

import '../Screen/home_page.dart';
import 'Screen/location.dart';
import 'Screen/profile_page.dart';
import 'Screen/wallet_page.dart';
import 'Screen/statistique.dart';

class Bottom extends StatefulWidget {
  const Bottom({Key? key}) : super(key: key);

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int index_color = 0;
  List Screen = [
    MyHomePage(title: 'App  mobile'),
    WalletPage(title: 'App  mobile'),
    ProfilePage(title: 'App  mobile')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500], // Fond gris pour l'ensemble du Scaffold
      body: Screen[index_color],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 0; // Mettre à jour l'index de couleur lorsque l'icône est tapée
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,  // S'assurer que la colonne n'occupe pas trop d'espace
                    children: [
                      Image.asset(
                        'assets/home.png',  // Chemin vers votre image
                        width: 30,  // Définir la taille de l'image
                        height: 30, // Définir la taille de l'image
                        color: index_color == 0 ? Color(0xff0c355f) : Colors.grey,  // Change de couleur en fonction de l'index
                      ),

                      SizedBox(height: 4),  // Espacement entre l'icône et le texte
                      Text(
                        'Accueil',  // Le label sous l'icône
                        style: TextStyle(
                          color: index_color == 0 ? Color(0xff0c355f) : Colors.grey,  // Change la couleur du texte en fonction de l'index
                          fontSize: 15,  // Taille de police pour le label
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 1; // Mettre à jour l'index de couleur lorsque l'icône est tapée
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,  // S'assurer que la colonne n'occupe pas trop d'espace
                    children: [
                      Icon(
                        Icons.credit_card,
                        size: 30,
                        color: index_color == 1 ? Color(0xff0c355f) : Colors.grey, // Change de couleur en fonction de l'index
                      ),
                      SizedBox(height: 4),  // Espacement entre l'icône et le texte
                      Text(
                        'Services',  // Le label sous l'icône
                        style: TextStyle(
                          color: index_color == 1 ? Color(0xff0c355f) : Colors.grey,  // Change la couleur du texte en fonction de l'index
                          fontSize: 15,  // Taille de police pour le label
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 2;  // Mettre à jour l'index de couleur pour le bouton Profile
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,  // Assure que la colonne n'occupe pas trop d'espace
                    children: [
                      Image.asset(
                        'assets/setting.png',  // Chemin vers votre image
                        width: 30,  // Définir la taille de l'image
                        height: 30, // Définir la taille de l'image
                        color: index_color == 2 ? Color(0xff0c355f) : Colors.grey,  // Change de couleur en fonction de l'index
                      ),
                      SizedBox(height: 4),  // Espacement entre l'icône et le texte
                      Text(
                        'Paramettre',  // Le label sous l'icône
                        style: TextStyle(
                          color: index_color == 2 ? Color(0xff0c355f) : Colors.grey,  // Change la couleur du texte en fonction de l'index
                          fontSize: 15,  // Taille de la police pour le label
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
