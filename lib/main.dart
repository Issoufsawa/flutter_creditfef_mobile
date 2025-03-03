import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottomnavigationbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screen/welcome_screen.dart';
import 'Screen/signin_screen.dart'; // Assurez-vous que ce fichier est bien présent.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important pour l'initialisation de SharedPreferences
  bool isLoggedIn =
      await checkIfUserIsLoggedIn(); // Vérifiez si l'utilisateur est déjà connecté

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

// Fonction pour vérifier si l'utilisateur est connecté
Future<bool> checkIfUserIsLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Vérifiez si l'email est stocké dans SharedPreferences
  return prefs.getString('email') != null;
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      // Si l'utilisateur est connecté, redirigez vers la page d'accueil,
      // sinon vers l'écran de connexion
      home: isLoggedIn ? const Bottom() : const SignInScreen(),
    );
  }
}
