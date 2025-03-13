import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour décoder la réponse JSON
import 'package:shared_preferences/shared_preferences.dart'; // Importer SharedPreferences

class PaymentFormPage extends StatefulWidget {
  final String qrCode; // Déclarez qrCode ici

  // Le constructeur prend un paramètre qrCode
  const PaymentFormPage({Key? key, required this.qrCode}) : super(key: key);

  @override
  _PaymentFormPageState createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final TextEditingController _amountSentController = TextEditingController();
  final TextEditingController _amountReceivedController = TextEditingController();
  String? _accountNumber; // Variable pour stocker le numéro de compte
  bool _isLoading = false; // Variable pour gérer l'état de chargement

  @override
  void initState() {
    super.initState();
    _loadAccountNumber(); // Charger le numéro de compte dès le début
  }

  // Charger le numéro de compte depuis SharedPreferences
  Future<void> _loadAccountNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _accountNumber = prefs.getString('num_cpte'); // Récupérer le numéro de compte
    });
  }

  // Méthode pour effectuer un paiement
  Future<void> _makePayment() async {
    setState(() {
      _isLoading = true; // Début du chargement
    });

    final String apiUrl = 'http://api.credit-fef.com/mobile/operationDepotMobilePage.php';

    // Récupérer les valeurs des champs du formulaire
    final String amountSent = _amountSentController.text;
    final String amountReceived = _amountReceivedController.text;

    // Vérifier que les champs ne sont pas vides
    if (amountSent.isEmpty || amountReceived.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      setState(() {
        _isLoading = false; // Fin du chargement
      });
      return;
    }

    try {
      // Faire la requête HTTP POST à l'API
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'num_cpte': amountSent,  // Le montant envoyé
          'montant_solde': amountReceived, // Le montant reçu
          'beneficiere': widget.qrCode,  // Passer le qrCode lors du paiement
        },
      );

      setState(() {
        _isLoading = false; // Fin du chargement
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('Réponse de l\'API : $data');

        // Si la réponse indique que le paiement est réussi
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Paiement effectué avec succès !')),
          );

          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.popUntil(context, ModalRoute.withName('/wallet_page'));
          });

        } else if (data['status'] == '2') {
          // Si le solde est insuffisant
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Solde insuffisant.')),
          );
        } else if (data['status'] == '3') {
          // Si un paramètre est manquant
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Paramètre manquant.')),
          );
        } else {
          // En cas d'échec général
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
        SnackBar(content: Text('Une erreur est survenue : $e')),
      );
      setState(() {
        _isLoading = false; // Fin du chargement
      });
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

            // Afficher le numéro de compte s'il est disponible
            _accountNumber != null
                ? Text(
              'Numéro de compte: $_accountNumber',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
                : CircularProgressIndicator(), // Afficher un loader si le numéro de compte est en cours de chargement

            SizedBox(height: 20),
            TextField(
              controller: _amountSentController,
              decoration: InputDecoration(labelText: 'Montant Envoyé'),
              keyboardType: TextInputType.number,
            ),

            Center(  // Centrer le bouton
              child: ElevatedButton(
                onPressed: _isLoading ? null : _makePayment,  // Désactive le bouton pendant le chargement
                child: _isLoading
                    ? CircularProgressIndicator()  // Afficher un indicateur de chargement au lieu du texte pendant le traitement
                    : Text('Envoyer'),
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
