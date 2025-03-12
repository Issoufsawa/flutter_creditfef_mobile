import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour décoder la réponse JSON

class PaymentFormPage extends StatefulWidget {
  @override
  _PaymentFormPageState createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final TextEditingController _amountSentController = TextEditingController();
  final TextEditingController _amountReceivedController = TextEditingController();

  // Méthode pour effectuer un paiement
  Future<void> _makePayment() async {
    final String apiUrl = 'http://api.credit-fef.com/mobile/operationDepotMobilePage.php';

    // Récupérer les valeurs des champs du formulaire
    final String amountSent = _amountSentController.text;
    final String amountReceived = _amountReceivedController.text;

    // Vérifier que les champs ne sont pas vides
    if (amountSent.isEmpty || amountReceived.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    try {
      // Faire la requête HTTP POST à l'API
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'montant_envoye': amountSent,  // Le montant envoyé
          'montant_recu': amountReceived, // Le montant reçu
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('Réponse de l\'API : $data');

        // Si la réponse indique que le paiement est réussi
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Paiement effectué avec succès !')),
          );

          // Retourner à la page précédente (WalletPage)
          Navigator.popUntil(context, ModalRoute.withName('/wallet_page')); // Retour explicite à WalletPage
        } else {
          // En cas d'échec du paiement
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec du paiement. Veuillez réessayer.')),
          );
        }
      } else {
        throw Exception('Erreur lors de la requête API');
      }
    } catch (e) {
      print('Erreur lors de l\'appel à l\'API : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Envoyer de l\'argent'),
        backgroundColor: Color(0xff0c355f), // Couleur personnalisée
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Envoyer de l\'argent',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _amountSentController,
              decoration: InputDecoration(labelText: 'Montant Envoyé'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _amountReceivedController,
              decoration: InputDecoration(labelText: 'Montant Reçu'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Center(  // Centrer le bouton
              child: ElevatedButton(
                onPressed: _makePayment,  // Appeler la méthode pour effectuer le paiement
                child: Text('Envoyer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Couleur de fond
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
