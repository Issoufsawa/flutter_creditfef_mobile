import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class payementpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réinitialisation du mot de passe'),
        backgroundColor:Color(0xff0c355f), // Définir la couleur de l'AppBar en bleu
      ),


      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Réinitialiser votre mot de passe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Si vous avez oublié votre mot de passe, entrez votre adresse e-mail ci-dessous pour recevoir un lien de réinitialisation.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Code pour envoyer le lien de réinitialisation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:Color(0xff0c355f),// Définir la couleur du bouton ici (bleu)
              ),
              child: Text(
                'Envoyer le lien de réinitialisation',
                style: TextStyle(
                  color: Colors.white, // Couleur du texte (blanc)
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

}
