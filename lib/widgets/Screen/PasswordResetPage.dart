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

      // Corps de la requête
      final Map<String, String> requestBody = {
        'mdp': oldPassword,
        'nouveau': newPassword,
        'confirme': confirmPassword,
        'numero': accountNumber ?? "", // Ajouter le numéro de compte dans la requête
      };

      try {
        final response = await http.post(
          Uri.parse('http://api.credit-fef.com/mobile/UpdatePasseMobilePage.php'),
          body: requestBody,
        );

        // Afficher la réponse brute pour le débogage
        print("Réponse brute du serveur: ${response.body}");

        // Vérifier le code de statut de la réponse
        if (response.statusCode == 200) {
          String responseData = response.body.trim(); // La réponse brute est une chaîne, pas un objet JSON

          String message = "";
          switch (responseData) {
            case "1":
              message = "Le mot de passe actuel est incorrect";
              break;
            case "4":
              message = "Tous les champs doivent être remplis";
              break;
            case "3":
              message = "Les mots de passe ne correspondent pas";
              break;
            default:
              print("Réponse inattendue du serveur: $responseData");
              message = "Mot de passe modifié avec succès";

              // Réinitialiser les champs de texte après succès
              setState(() {
                _oldPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              });
              break;
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur de communication avec le serveur")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Une erreur s'est produite: $e")),
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
              Container(
                width: 300, // Définissez la largeur du champ ici
                child: TextFormField(
                  controller: _oldPasswordController,
                  obscureText: !_isOldPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Ancien mot de passe',
                    labelStyle: TextStyle(color: Color(0xff0c355f)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0c355f)),
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
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre ancien mot de passe';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 30),

// Nouveau mot de passe

              Container(
                width: 300, // Spécifiez la largeur souhaitée ici
                child: TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    labelStyle: TextStyle(color: Color(0xff0c355f)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0c355f)),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
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
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nouveau mot de passe';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 30),

// Confirmer le nouveau mot de passe
              Container(
                width: 300, // Largeur personnalisée
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le nouveau mot de passe',
                    labelStyle: TextStyle(color: Color(0xff0c355f)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0c355f)),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
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
                  style: TextStyle(color: Colors.black, fontSize: 16),
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
              ),

              SizedBox(height: 10),
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
