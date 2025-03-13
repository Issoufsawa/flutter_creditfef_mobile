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
    final String amountReceived = _amountReceivedController.text;

    // Vérifier que les champs ne sont pas vides
    if (amountReceived.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      setState(() {
        _isLoading = false; // Fin du chargement
      });
      return;
    }

    if (_accountNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Numéro de compte non trouvé dans les préférences.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Faire la requête HTTP POST à l'API
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'montant_solde': amountReceived, // Le montant reçu
          'beneficiaire': widget.qrCode,  // Passer le qrCode lors du paiement
          'num_cpte': _accountNumber ?? "",  // Le numéro de compte venant des SharedPreferences
        },
      );

      // Affichage des données envoyées pour débogage
      print("Données envoyées : ");
      print("Montant envoyé: $amountReceived");
      print("QRCode: ${widget.qrCode}");
      print("Numéro de compte: $_accountNumber");

      // Afficher la réponse brute de l'API
      print('Réponse brute de l\'API: ${response.body}');

      setState(() {
        _isLoading = false; // Fin du chargement
      });

      if (response.statusCode == 200) {
        // Si la réponse est une chaîne comme "3" ou "success"
        var data = response.body;  // La réponse est une chaîne (ex : "3")
        print('Réponse de l\'API : $data');

        // Vérifier si la réponse est "3"
        if (data == "3") {
          // Paramètre manquant ou erreur côté serveur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Paramètre manquant ou erreur côté serveur.')),
          );
        } else if (data == "success") {
          // Paiement réussi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Paiement effectué avec succès !')),
          );

          // Naviguer après une petite pause
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.popUntil(context, ModalRoute.withName('/wallet_page'));
          });
        } else {
          // Autres codes de statut
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec du paiement. Code de statut : $data')),
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

            // Champ pour le montant reçu
            TextField(
              controller: _amountReceivedController,
              decoration: InputDecoration(labelText: 'Montant Reçu'),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 20),

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
