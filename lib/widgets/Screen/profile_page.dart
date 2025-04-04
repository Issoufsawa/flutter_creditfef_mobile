import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/signin_screen.dart';
import 'package:flutter_application_1/widgets/Screen/PasswordResetPage.dart';
import 'package:flutter_application_1/widgets/Screen/statistique.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'location.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});

  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nom_cli = ""; // Variable pour le nom du client
  String _num_cpte_cli = ""; // Variable pour le numéro de compte du client
  String _agence = "";

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Charger les données du profil au démarrage
  }

  // Charger les données du profil depuis SharedPreferences
  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      // Récupérer le numéro de compte et le nom depuis SharedPreferences
      _num_cpte_cli = prefs.getString('num_cpte') ?? 'Numéro de compte non défini';
      _nom_cli = prefs.getString('nom') ?? 'Nom non défini';
      _agence = prefs.getString('agence') ?? 'Agence non définie';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // AppBar sous forme de Card avec un dégradé linéaire
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0c355f), Color(0xff014f86)], // Couleurs du dégradé
                  begin: Alignment.topLeft, // Début du dégradé
                  end: Alignment.bottomRight, // Fin du dégradé
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                margin: EdgeInsets.all(0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff0c355f), Color(0xff014f86)], // Couleurs du dégradé
                      begin: Alignment.topLeft, // Début du dégradé
                      end: Alignment.bottomRight, // Fin du dégradé
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Profil',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Texte en blanc pour contraster avec le fond
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre "compte"
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Info Compte',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff0c355f),
                          ),
                        ),
                      ),
                      // Regrouper les deux Cards dans une seule Column à l'intérieur d'un Card
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.blue, // Couleur de la bordure
                            width: 0.5, // Épaisseur de la bordure
                          ),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.business, // Icône pour l'agence de création
                                color: Color(0xff0c355f),
                              ),
                              title: Text(
                                'Agence de Création',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xff0c355f),
                                ),
                              ),
                              subtitle: Text(
                                _agence, // Afficher l'agence de création
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                            ListTile(
                              leading: Image.asset(
                                'assets/location.png',  // Chemin vers votre image
                                width: 30,  // Définir la taille de l'image
                                height: 30, // Définir la taille de l'image
                              ),
                              title: Text(
                                'Localiser une Agence',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xff0c355f),
                                ),
                              ),
                              onTap: () {
                                // Rediriger vers la page de réinitialisation du mot de passe
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LocationPage(title: 'App  mobile'),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: Image.asset(
                                'assets/diagram.png',  // Chemin vers votre image
                                width: 30,  // Définir la taille de l'image
                                height: 30, // Définir la taille de l'image
                              ),
                              title: Text(
                                'Statistique',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xff0c355f),
                                ),
                              ),
                              onTap: () {
                                // Rediriger vers la page de réinitialisation du mot de passe
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StatistiquePage(title: 'App  mobile'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10), // Espacement après la Card "Compte"
                      // Titre "Info Client"
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Info Client',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff0c355f),
                          ),
                        ),
                      ),
                      // Card pour le nom et prénom
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.blue, // Couleur de la bordure
                            width: 0.5, // Épaisseur de la bordure
                          ),
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/user.png',  // Chemin vers votre image
                            width: 30,  // Définir la taille de l'image
                            height: 30, // Définir la taille de l'image
                          ),
                          title: Text(
                            'Nom et Prénom',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xff0c355f),
                            ),
                          ),
                          subtitle: Text(
                            _nom_cli, // Afficher le nom du client
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: 10), // Espacement entre les Card
                      // Titre "Sécurité"
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Sécurité',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff0c355f),
                          ),
                        ),
                      ),
                      // Card pour la modification du mot de passe
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.blue, // Couleur de la bordure
                            width: 0.5, // Épaisseur de la bordure
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.lock, // Icône de cadenas pour la modification du mot de passe
                            color: Color(0xff0c355f),
                          ),
                          title: Text(
                            'Modifier le mot de passe',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xff0c355f),
                            ),
                          ),
                          onTap: () {
                            // Rediriger vers la page de réinitialisation du mot de passe
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PasswordResetPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10), // Espacement entre les Card
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.blue, // Couleur de la bordure
                            width: 0.5, // Épaisseur de la bordure
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.exit_to_app, // Icône de porte pour la déconnexion
                            color: Color(0xff0c355f),
                          ),
                          title: Text(
                            'Se déconnecter',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xff0c355f),
                            ),
                          ),
                          onTap: () {
                            _showFicheDialog(context); // Afficher la boîte de dialogue de déconnexion
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode de déconnexion
  Future<void> _logOut(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('num_cpte'); // Supprimer le numéro de compte
    await prefs.remove('password'); // Supprimer le mot de passe
    await prefs.remove('nom'); // Supprimer le nom

    // Rediriger vers la page de connexion
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  // Méthode pour afficher une boîte de dialogue de confirmation pour la déconnexion
  void _showFicheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Déconnexion'),
          content: Text('Voulez-vous vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Annuler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xff0c355f),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
            TextButton(
              child: Text(
                'Se déconnecter',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xff0c355f),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                _logOut(context); // Appeler la fonction de déconnexion
              },
            ),
          ],
        );
      },
    );
  }
}
