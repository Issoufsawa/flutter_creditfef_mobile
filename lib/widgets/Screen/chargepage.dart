import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class chargepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recharger sa carte QR code'),
        backgroundColor:Color(0xff0c355f), // Définir la couleur de l'AppBar en bleu
      ),


      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recharger sa carte QR code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Entrez le montant à recharger dans le champ ci-dessous .',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Montant à recharger',
                border: OutlineInputBorder(), // Définit la bordure par défaut
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black, // Couleur de la bordure lorsqu'elle est inactive
                    width: 2.0, // Épaisseur de la bordure
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:Colors.black,// Couleur de la bordure lorsqu'elle est active (focus)
                    width: 2.0, // Épaisseur de la bordure
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Montant à recevoir',
                border: OutlineInputBorder(), // Définit la bordure par défaut
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black, // Couleur de la bordure lorsqu'elle est inactive
                    width: 2.0, // Épaisseur de la bordure
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black, // Couleur de la bordure lorsqu'elle est active (focus)
                    width: 2.0, // Épaisseur de la bordure
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center( // Centrer le bouton ici
              child: ElevatedButton(
                onPressed: () {
                  // Code pour envoyer le lien de réinitialisation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:Color(0xff0c355f), // Définir la couleur du bouton ici (bleu)
                ),
                child: Text(
                  'Envoyer',
                  style: TextStyle(
                    color: Colors.white, // Couleur du texte (blanc)
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
