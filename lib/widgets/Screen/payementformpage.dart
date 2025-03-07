import 'package:flutter/material.dart';

class PaymentFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Envoyer de l\'Argent'),
        backgroundColor: Color(0xff0c355f), // Couleur personnalisée
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Envoyer de l\'Argent',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Montant Envoyé'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Montant Reçu'),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 20),
            Center(  // Centrer le bouton
              child: ElevatedButton(
                onPressed: () {
                  // Action lors de la soumission du formulaire
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Envoyé avec succès !')),
                  );

                  // Retourner à la page précédente (Wallet_Page)
                  Navigator.pop(context);  // Ferme la page actuelle et revient à la page précédente
                },
                child: Text('Envoyer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Couleur de fond
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
