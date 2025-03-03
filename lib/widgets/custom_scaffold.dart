import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Centrer l'image de fond
          Align(
            alignment: Alignment.topCenter, // Centrer horizontalement
            child: Image.asset(
              'assets/images/credit.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 380, // Ajuster la hauteur de l'image
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 100), // Espace pour l'AppBar
              child: child!, // Votre widget enfant
            ),
          ),
        ],
      ),
    );
  }
}
