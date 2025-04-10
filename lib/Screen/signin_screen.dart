import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottomnavigationbar.dart';
import '../widgets/custom_scaffold.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  TextEditingController numero = TextEditingController();
  TextEditingController password = TextEditingController();
  bool rememberPassword = true;
  bool _isPasswordVisible = false; // To track visibility of the password

  // Function to handle login
  Future<void> _signIn(data) async {
    if (_formSignInKey.currentState!.validate()) {
      if (!rememberPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez accepter le traitement des données personnelles"),
          ),
        );
        return;
      }

      try {
        final response = await http.post(Uri.parse('https://api.credit-fef.com/mobile/loginMobilePage.php?action=connexion-user'), body: data);
        var responseData = jsonDecode(response.body);

        if (responseData is List && responseData.isNotEmpty) {
          responseData = responseData[0];
        }

        // Check for login failure
        if (responseData == "1" || responseData == "2") {
          print("Identifiants incorrects");
          return;
        }

        String nom = responseData['nom_cli'] ?? '';
        String contact = responseData['contact_cli'] ?? '';
        String num_cpte = responseData['num_cpte_cli'] ?? '';
        String types = responseData['type_cpte_cli'] ?? '';
        String solde = responseData['solde_cpte_cli'] ?? '';
        String agence = responseData['agence'] ?? '';

        // Save data to SharedPreferences
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        await localStorage.setString('nom', nom);
        await localStorage.setString('contact', contact);
        await localStorage.setString('num_cpte', num_cpte);
        await localStorage.setString('types', types);
        await localStorage.setString('solde', solde);
        await localStorage.setString('agence', agence);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Bottom(),
          ),
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        print("Erreur: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0c355f), Color(0xff014f86)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Content de vous revoir',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // Champ de texte numéro de compte avec ligne dessous
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre numéro de compte';
                          }
                          return null;
                        },
                        controller: numero,
                        style: const TextStyle(color: Colors.white, fontSize: 18), // Texte de l'utilisateur, couleur blanche et taille de police
                        decoration: InputDecoration(
                          labelText: 'Numéro de compte',
                          labelStyle: const TextStyle(
                            color: Colors.white, // Couleur du texte du label
                            fontSize: 20, // Taille du texte du label
                            fontWeight: FontWeight.bold, // Gras pour le label
                          ),
                          hintText: 'Entrez le numéro de compte',
                          hintStyle: const TextStyle(
                            color: Colors.white60, // Couleur plus claire pour le hint
                            fontSize: 18, // Taille du texte du hint
                          ),
                          border: InputBorder.none, // Aucune bordure par défaut
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange, width: 2), // Bordure sous l'élément en focus, orange ici
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // Bordure lorsqu'il est actif, couleur blanche
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.red, // Couleur du texte d'erreur
                            fontSize: 14, // Taille du texte d'erreur
                          ),
                          suffixIcon: Icon(
                            Icons.book, // L'icône souhaitée
                            color: Colors.white, // Couleur de l'icône
                            size: 25, // Taille de l'icône
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),
                      // Champ de texte mot de passe avec ligne dessous
                      TextFormField(
                        obscureText: !_isPasswordVisible, // Toggle visibility of the password
                        obscuringCharacter: '*', // Character used to obscure the password
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le mot de passe';
                          }
                          return null;
                        },
                        controller: password,
                        style: const TextStyle(color: Colors.white, fontSize: 18), // Personnaliser la couleur et la taille du texte
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          labelStyle: const TextStyle(
                            color: Colors.white, // Couleur du label
                            fontSize: 20, // Taille du texte du label
                            fontWeight: FontWeight.bold, // Gras pour le label
                          ),
                          hintText: 'Entrez le mot de passe',
                          hintStyle: const TextStyle(
                            color: Colors.white60, // Couleur du hint, légèrement plus clair
                            fontSize: 18, // Taille du texte du hint
                          ),
                          border: InputBorder.none, // Aucune bordure par défaut
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange, width: 2), // Bordure orange au focus
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // Bordure blanche en état normal
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.red, // Couleur du texte d'erreur
                            fontSize: 14, // Taille du texte d'erreur
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility, // Icône pour afficher/masquer
                              color: Colors.white,
                              size: 25, // Taille de l'icône
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible; // Basculer la visibilité du mot de passe
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: Colors.white,
                                  checkboxTheme: CheckboxThemeData(
                                    side: BorderSide(color: Colors.white),
                                  ),
                                ),
                                child: Checkbox(
                                  value: rememberPassword,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberPassword = value!;
                                    });
                                  },
                                  activeColor: Colors.orange,
                                ),
                              ),
                              const Text(
                                'Souviens-toi de moi',
                                style: TextStyle(fontSize: 20.0, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26, // Couleur de l'ombre
                                blurRadius: 8, // Flou de l'ombre
                                offset: Offset(0, 4), // Position de l'ombre (décalage horizontal et vertical)
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              var data = {
                                'numero': numero.text,
                                'mdp': password.text,
                              };
                              print(data);
                              _signIn(data);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange, // Couleur du bouton
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Bord arrondi
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                            ),
                            child: const Text(
                              'Se connecter',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
