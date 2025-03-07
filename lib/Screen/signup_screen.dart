import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/signin_screen.dart';
import 'package:http/http.dart' as http;
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController prename = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool agreePersonalData = true;

  Future<void> insertrecord() async {
    if (name.text != "" &&
        prename.text != "" &&
        email.text != "" &&
        password.text != "") {
      try {
        String uri = "http://10.0.2.2/mobile_API/insert.php"; // Votre URI
        var res = await http.post(
          Uri.parse(uri),
          body: {
            "name": name.text,
            "prename": prename.text,
            "email": email.text,
            "password": password.text,
          },
        );

        var response = jsonDecode(res.body);

        if (response['status'] == 'success') {
          print("Data inserted successfully");
          print("Email: ${email.text}");
          print("Mot de passe: ${password.text}");
          // Vider les champs après une insertion réussie
          name.text = "";
          prename.text = "";
          email.text = "";
          password.text = "";

          // Optionnel: Afficher un message ou naviguer vers une autre page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inscription réussie !')),
          );
        } else {
          print("Error: ${response['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${response['message']}')),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Une erreur s\'est produite')),
        );
      }
    } else {
      print("Veuillez remplir tous les champs");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
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
              decoration: BoxDecoration(
                color: Color(0xff0c355f), // Fond bleu
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Commencer',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white, // Texte en blanc
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      // full name
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom ';
                          }
                          return null;
                        },
                        controller: name,
                        style: const TextStyle(color: Colors.white), // Texte blanc
                        decoration: InputDecoration(
                          label: const Text('Nom '),
                          labelStyle: const TextStyle(color: Colors.white), // White label
                          hintText: 'Entrez le nom ',
                          hintStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Couleur de la bordure
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Couleur de la bordure
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Bordure blanche quand focus
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre prénom ';
                          }
                          return null;
                        },
                        controller: prename,
                        style: const TextStyle(color: Colors.white), // Texte blanc
                        decoration: InputDecoration(
                          label: const Text('Prénom'),
                          labelStyle: const TextStyle(color: Colors.white), // White label
                          hintText: 'Entrez le prénom complet',
                          hintStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Couleur de la bordure
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Couleur de la bordure
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Bordure blanche quand focus
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      // email
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre e-mail';
                          }
                          return null;
                        },
                        controller: email,
                        style: const TextStyle(color: Colors.white), // Texte blanc
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          labelStyle: const TextStyle(color: Colors.white), // White label
                          hintText: 'Entrer votre e-mail',
                          hintStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Couleur de la bordure
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Couleur de la bordure
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Bordure blanche quand focus
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      // password
                      TextFormField(
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le mot de passe';
                          }
                          return null;
                        },
                        controller: password,
                        style: const TextStyle(color: Colors.white), // Texte blanc
                        decoration: InputDecoration(
                          label: const Text('Mot de passe'),
                          labelStyle: const TextStyle(color: Colors.white), // White label
                          hintText: 'Entrez le mot de passe',
                          hintStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Couleur de la bordure
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Couleur de la bordure
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Bordure blanche quand focus
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      // i agree to the processing
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: Colors.orange,
                          ),
                          const Text(
                            'J\'accepte le traitement de ',
                            style: TextStyle(
                                fontSize: 10.0,
                                color: Colors.white),
                          ),
                          Text(
                            'Données personnelles',
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      // signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Traitement des données'),
                                ),
                              );
                              insertrecord();
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Veuillez accepter le traitement des données personnelles',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'S\'inscrire',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold, // Make the text bold
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Modifier ici la couleur du bouton
                          ),

                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Vous avez déjà un compte ? ',
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Se connecter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
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
