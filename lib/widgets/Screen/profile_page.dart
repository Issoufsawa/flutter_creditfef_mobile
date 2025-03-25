import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/signin_screen.dart';
import 'package:flutter_application_1/widgets/Screen/PasswordResetPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});

  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nom_cli = ""; // Variable pour le nom du client
  String _num_cpte_cli = ""; // Variable pour le numéro de compte du client

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _head()), // En-tête avec logo et texte du profil
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20), // Ajouter un espace au-dessus du Card
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                'Numéro de compte',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xff0c355f),
                                ),
                              ),
                              subtitle: Text(
                                _num_cpte_cli, // Afficher le numéro de compte
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                            Divider(),
                            ListTile(
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
                            Divider(),
                            ListTile(
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
                            Divider(),
                            ListTile(
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher l'en-tête avec le logo et le titre "Détails du Profil"
  Widget _head() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 248,
              decoration: BoxDecoration(
                color: Color(0xff0c355f),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png', // Logo de l'application
                      height: 137,
                      width: 560,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 30), // Espacement sous le logo
                    Text(
                      'Détails du Profil',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center, // Centrer le texte
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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
