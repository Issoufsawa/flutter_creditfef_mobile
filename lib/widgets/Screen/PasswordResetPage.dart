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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Clé de validation du formulaire
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Fonction pour vérifier et changer le mot de passe via l'API
  Future<void> _updatePassword() async {
    // Validation du formulaire avant d'envoyer la requête
    if (_formKey.currentState?.validate() ?? false) {
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

      // Corps de la requête
      final Map<String, String> requestBody = {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
        'account_number': accountNumber ?? "", // Ajouter le numéro de compte dans la requête
      };

      try {
        // Envoi de la requête POST avec requestBody
        final response = await http.post(
          Uri.parse('http://api.credit-fef.com/mobile/UpdatePasseMobilePage.php'),
          body: requestBody,  // Utiliser requestBody ici
        );

        if (response.statusCode == 200) {
          // Vérifier si la réponse contient du JSON
          var responseData = json.decode(response.body);

          // Traiter la réponse selon le code de statut
          if (responseData['status'] == '1') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Le mot de passe actuel est incorrect")),
            );
          } else if (responseData['status'] == '2') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Autre erreur, vérifie tes informations")),
            );
          } else if (responseData['status'] == '4') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Tous les champs doivent être remplis")),
            );
          } else if (responseData['status'] == '3') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Les mots de passe ne correspondent pas")),
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
        child: Form(
          key: _formKey, // Ajout de la clé pour validation
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

              // Ancien mot de passe
              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_isOldPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Ancien mot de passe',
                  labelStyle: TextStyle(color: Color(0xff0c355f)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff0c355f)), // Bordure bleue
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOldPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xff0c355f),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isOldPasswordVisible = !_isOldPasswordVisible;
                      });
                    },
                  ),
                ),
                style: TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre ancien mot de passe';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

// Nouveau mot de passe
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_isNewPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  labelStyle: TextStyle(color: Color(0xff0c355f)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff0c355f)), // Bordure bleue
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xff0c355f),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                ),
                style: TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nouveau mot de passe';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

// Confirmer le nouveau mot de passe
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirmer le nouveau mot de passe',
                  labelStyle: TextStyle(color: Color(0xff0c355f)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff0c355f)), // Bordure bleue
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xff0c355f),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                style: TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer le nouveau mot de passe';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),


              // Bouton de validation
              Center(
                child: ElevatedButton(
                  onPressed: _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 130, vertical: 7),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text(
                    'Modifier',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
