import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/signup_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme.dart';
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

  // Fonction pour gérer la connexion
  Future<void> _signIn(data) async {
    // Vérifiez si le formulaire est valide
    if (_formSignInKey.currentState!.validate()) {
      if (!rememberPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Veuillez accepter le traitement des données personnelles",
            ),
          ),
        );
        return;
      }

      print("Email: ${numero.text}");
      print("Mot de passe: ${password.text}");

      // Envoi de la requête HTTP pour vérifier les informations de connexion
      try {

final response = await http.post(Uri.parse('https://api.credit-fef.com/mobile/loginMobilePage.php?action=connexion-user'),body:data);
var responseData = jsonDecode(response.body);
print(responseData);

if (responseData is List && responseData.isNotEmpty) {
  responseData = responseData[0];
}

// Vérifier si la connexion a échoué
if (responseData == "1" || responseData == "2") {
  ///Fluttertoast.showToast(msg: "Identifiants incorrects");
  print("Identifiants incorrects");
 // return "Error";
}
        String nom = responseData['nom_cli'] ?? '';
        String contact = responseData['contact_cli'] ?? '';
        String num_cpte = responseData['num_cpte_cli'] ?? '';
        String types = responseData['type_cpte_cli'] ?? '';
        String solde = responseData['solde_cpte_cli'] ?? '';
        String agence = responseData['agence'] ?? '';

        // Stocker les données dans SharedPreferences
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
            builder:
                (context) =>
            const Bottom(), // Remplacez par votre page d'accueil
          ),
        );


      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        print("content: Text('Erreur: $e')");
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
                color: Color(0xff0c355f),// Background set to blue
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
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
                          color: Colors.white, // Change text color to white
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre numéro de compte';
                          }
                          return null;
                        },
                        controller: numero,
                        style: const TextStyle(color: Colors.white), // Définir la couleur du texte à blanc
                        decoration: InputDecoration(
                          label: const Text(
                            'Numéro de compte',
                            style: TextStyle(
                              color: Colors.white, // Change label color to white
                            ),
                          ),
                          hintText: 'Entrez le numéro de compte',
                          hintStyle: const TextStyle(color: Colors.white), // Lighter white for hints
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white), // White border color
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white), // White border color when focused
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white), // White border color when enabled
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      TextFormField(
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le mot de passe';
                          }
                          return null;
                        },
                        controller: password,
                        style: const TextStyle(color: Colors.white), // Définir la couleur du texte à blanc
                        decoration: InputDecoration(
                          label: const Text(
                            'Mot de passe',
                            style: TextStyle(
                              color: Colors.white, // Change label color to white
                            ),
                          ),
                          hintText: 'Entrez le mot de passe',
                          hintStyle: const TextStyle(color: Colors.white), // Lighter white for hints
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white), // White border color
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white), // White border color when focused
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white), // White border color when enabled
                            borderRadius: BorderRadius.circular(10),
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
                                  unselectedWidgetColor: Colors.white, // Color of the checkbox border
                                  checkboxTheme: CheckboxThemeData(
                                    side: BorderSide(color: Colors.white), // Set border color to white
                                  ),
                                ),
                                child: Checkbox(
                                  value: rememberPassword,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberPassword = value!;
                                    });
                                  },
                                  activeColor: Colors.orange, // Checkbox color when checked (orange)
                                ),
                              ),
                              const Text(
                                'Souviens-toi de moi',
                                style: TextStyle(color: Colors.white), // Light white color for text
                              ),
                            ],

                          ),
                          GestureDetector(
                            child: Text(
                              'Mot de passe oublié?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Change color to white
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (){
                        var data = {
                         'numero': numero.text,
                          'mdp': password.text,
                        };
                        print(data);
                        _signIn(data);
                        }
                          , // Appeler la fonction de connexion
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Or use this Color(0xFFFFA500) for a specific shade

                          ),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold, // Mettre le texte en gras
                            ),
                          ),

                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Vous n\'avez pas de compte ?',
                            style: TextStyle(color: Colors.white), // Light white color for text
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'S\'inscrire',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Change color to white
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
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
