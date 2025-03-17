import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/Screen/wallet_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour décoder la réponse JSON
import 'package:shared_preferences/shared_preferences.dart'; // Importer SharedPreferences

class PaymentFormPage extends StatefulWidget {
  final String qrCode; // Déclarez qrCode ici

  const PaymentFormPage({Key? key, required this.qrCode}) : super(key: key);

  @override
  _PaymentFormPageState createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final TextEditingController _amountSentController = TextEditingController();
  String? _accountNumber; // Variable pour stocker le numéro de compte
  String? _solde; // Variable pour stocker le solde du compte
  bool _isLoading = false; // Variable pour gérer l'état de chargement

  @override
  void initState() {
    super.initState();
    _loadAccountNumber(); // Charger le numéro de compte dès le début
  }

  // Charger le numéro de compte et le solde depuis SharedPreferences
  Future<void> _loadAccountNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _accountNumber = prefs.getString('num_cpte'); // Récupérer le numéro de compte
      _solde = prefs.getString('solde'); // Récupérer le solde
    });
  }

  // Méthode pour effectuer un paiement
  Future<void> _makePayment() async {
    if (_isLoading) return; // Empêcher de lancer plusieurs paiements simultanément

    setState(() {
      _isLoading = true; // Début du chargement
    });

    final String apiUrl = 'http://api.credit-fef.com/mobile/operationDepotMobilePage.php';

    // Récupérer les valeurs des champs du formulaire
    final String amountSent = _amountSentController.text;

    // Vérifier que les champs ne sont pas vides
    if (amountSent.isEmpty || double.tryParse(amountSent) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un montant valide.')),
      );
      setState(() {
        _isLoading = false; // Fin du chargement
      });
      return;
    }

    if (_accountNumber == null || _solde == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Numéro de compte ou solde non trouvés dans les préférences.')),
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
          'montant_solde': _solde!, // Le solde du compte
          'montant': amountSent,  // Ajouter le montant envoyé
          'beneficiaire': widget.qrCode,  // Passer le qrCode lors du paiement
          'num_cpte': _accountNumber ?? "",  // Le numéro de compte venant des SharedPreferences
        },
      );

      // Affichage des données envoyées pour débogage
      print("Données envoyées : ");
      print("Montant envoyé: $amountSent");
      print("QRCode: ${widget.qrCode}");
      print("Numéro de compte: $_accountNumber");

      setState(() {
        _isLoading = false; // Fin du chargement
      });

      if (response.statusCode == 200) {
        var data = response.body;  // La réponse est une chaîne (ex : "3")

        // Paiement réussi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paiement effectué avec succès !')),
        );

        // Vider le champ après l'envoi du paiement
        _amountSentController.clear();  // Vider le champ de texte
        // Après un paiement réussi, naviguer directement vers WalletPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WalletPage(title: '',)), // Remplacez avec le nom de votre page Wallet
        );

        // Vérifier si la réponse est "3"
        if (data == "3") {
          // Paramètre manquant ou erreur côté serveur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Paramètre manquant ou erreur côté serveur.')),
          );
        }
      } else {
        throw Exception('Erreur lors de la requête API');
      }
    } catch (e) {
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
    // Vérifiez si les données du compte ont été chargées
    if (_accountNumber == null || _solde == null) {
      return Center(child: CircularProgressIndicator());
    }

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
              controller: _amountSentController,
              decoration: InputDecoration(labelText: 'Montant à envoyer'),
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