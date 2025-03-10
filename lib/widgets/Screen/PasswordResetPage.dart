import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour le décodage de la réponse JSON
import 'package:shared_preferences/shared_preferences.dart';

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Fonction pour vérifier et changer le mot de passe via l'API
  Future<void> _updatePassword() async {
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Récupérer le numéro de compte stocké dans SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountNumber = prefs.getString('num_cpte'); // Numéro de compte

    // Affichage des valeurs des champs pour débogage
    print("Ancien mot de passe: '$oldPassword'");
    print("Nouveau mot de passe: '$newPassword'");
    print("Confirmer le mot de passe: '$confirmPassword'");
    print("Numéro de compte: '$accountNumber'");

    // Validation pour s'assurer que les champs ne sont pas vides
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || accountNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur 4: Veuillez remplir tous les champs")),
      );
      return;
    }

    // Vérifier que les mots de passe correspondent
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur 3: Les mots de passe ne correspondent pas")),
      );
      return;
    }

    // URL de l'API
    final url = Uri.parse('http://api.credit-fef.com/mobile/UpdatePasseMobilePage.php');

    // Corps de la requête
    final Map<String, String> requestBody = {
      'old_password': oldPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
      'account_number': accountNumber, // Ajouter le numéro de compte dans la requête
    };

    try {
      // Envoi de la requête POST
      final response = await http.post(url, body: requestBody);

      if (response.statusCode == 200) {
        // Vérifier si la réponse contient du JSON
        var responseData = json.decode(response.body);

        // Traiter la réponse selon le code de statut
        if (responseData['status'] == '1') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(" Le mot de passe actuel est incorrect")),
          );
        } else if (responseData['status'] == '2') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(" Autre erreur, vérifie tes informations")),
          );
        } else if (responseData['status'] == '4') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(" Tous les champs doivent être remplis")),
          );
        } else if (responseData['status'] == '3') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(" Les mots de passe ne correspondent pas")),
          );
        } else if (responseData['status'] == '0') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Mot de passe modifié avec succès")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur inconnue")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de communication avec le serveur")),
        );
      }
    } catch (e) {
      // Si une erreur se produit, par exemple un problème de réseau
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Une erreur s'est produite")),
      );
      print("Erreur: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le mot de passe'),
        backgroundColor: Color(0xff0c355f),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Modifier le mot de passe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 30),
            TextField(
              controller: _oldPasswordController,
              obscureText: true, // Masquer le texte pour le mot de passe
              decoration: InputDecoration(
                labelText: 'Ancien mot de passe',
                labelStyle: TextStyle(color: Color(0xff0c355f)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff0c355f),
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff0c355f),
                    width: 2.0,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 40),
            TextField(
              controller: _newPasswordController,
              obscureText: true, // Masquer le texte pour le mot de passe
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                labelStyle: TextStyle(color: Color(0xff0c355f)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff0c355f),
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff0c355f),
                    width: 2.0,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 40),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true, // Masquer le texte pour le mot de passe
              decoration: InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
                labelStyle: TextStyle(color: Color(0xff0c355f)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff0c355f),
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff0c355f),
                    width: 2.0,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _updatePassword, // Appel de la fonction pour envoyer la requête
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Définir la couleur du bouton
                  padding: EdgeInsets.symmetric(horizontal: 150, vertical: 7), // Augmenter la taille du bouton
                  textStyle: TextStyle(
                    fontSize: 18, // Augmenter la taille du texte
                  ),
                ),
                child: Text(
                  'Modifier',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17, // Augmenter la taille du texte
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
