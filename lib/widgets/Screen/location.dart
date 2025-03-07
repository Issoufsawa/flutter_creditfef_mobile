import 'package:flutter/material.dart';


class LocationPage extends StatefulWidget {
  const LocationPage({super.key, required this.title});

  final String title;

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: 340, child: _head()),
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
                      'Localiser une de nos agences ',
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

}
