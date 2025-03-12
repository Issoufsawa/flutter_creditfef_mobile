import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/Screen/payementformpage.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';  // Importer qr_flutter
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour décoder la réponse JSON
import 'package:shared_preferences/shared_preferences.dart'; // Importer shared_preferences

class WalletPage extends StatefulWidget {
  const WalletPage({super.key, required this.title});

  final String title;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrText = "Scanner pour envoyer"; // Texte par défaut avant le scan
  String accountNumber = ""; // Variable pour stocker le numéro de compte

  @override
  void initState() {
    super.initState();
    _loadAccountNumber(); // Charger le numéro de compte depuis SharedPreferences
  }

  // Charger le numéro de compte depuis SharedPreferences
  Future<void> _loadAccountNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accountNumber = prefs.getString('num_cpte') ?? "";  // Récupérer le numéro de compte
    });
  }

  // Afficher le scanner QR
  void _showQRScanner(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêcher la fermeture du dialogue en cliquant à l'extérieur
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 450, // Augmentation de la taille de la prévisualisation
            width: 450,  // Augmentation de la taille de la prévisualisation
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.green,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 400.0,  // Taille du découpage central pour scanner
              ),
            ),
          ),
        );
      },
    );
  }

  // Initialiser le scanner QR et écouter les données scannées
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        setState(() {
          qrText = scanData.code!; // Mettre à jour le texte QR
        });
        print('QR Code scanné: $qrText');  // Debug info

        // Appeler l'API pour vérifier le QR Code
        bool isValid = await _callApi(qrText);

        if (!mounted) return;  // Vérifier si le widget est toujours monté

        // Si le QR Code est valide, naviguer vers la page de paiement
        if (isValid) {
          // Add a delay here to ensure the widget finishes building
          await Future.delayed(Duration(milliseconds: 200));

          if (!mounted) return;  // Recheck if the widget is mounted before navigating
          Navigator.pop(context); // Fermer le dialogue
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PaymentFormPage()), // Page de succès
          );
        } else {
          // Si le QR Code est invalide, afficher un message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Code QR invalide. Veuillez réessayer.')),
          );
          Navigator.pop(context); // Fermer le dialogue
        }
      }
    });
  }


  Future<bool> _callApi(String qrCode) async {
    final String apiUrl = 'http://api.credit-fef.com/mobile/VerificationMobilePage.php?num_cpte=$qrCode';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Si l'API retourne un succès
        var data = json.decode(response.body);
        print("Réponse de l'API : $data");

        // Vérifier si la réponse de l'API est un entier et si c'est 1 ou 0
        if (data == 1) {
          return true;  // Le QR Code est valide
        } else if (data == 0) {
          return false;  // Le QR Code est invalide
        }
      } else {
        throw Exception('Échec de la requête API');
      }
    } catch (e) {
      print("Erreur lors de l'appel à l'API: $e");
      return false; // En cas d'erreur, retourner false
    }
    return false;  // En cas de données inattendues, retourner false par défaut
  }

  @override
  void dispose() {
    controller?.dispose(); // Libérer les ressources de la caméra
    super.dispose();
  }

  // Méthode pour afficher l'en-tête avec le logo et le titre "Localiser une de nos agences"
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
                      'Services',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _head(), // Affichage de l'en-tête avec le logo et le titre
            ),
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Aligner les enfants du Column vers le bas
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _showQRScanner(context); // Ouvrir le scanner QR
                      },
                      child: Text("Scanner le QR Code"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Espacement sous le bouton pour aérer un peu

                  // Nouveau bouton pour afficher le QR Code
                  ElevatedButton(
                    onPressed: () {
                      if (accountNumber.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 20),
                                    // Générer et afficher le QR Code du numéro de compte
                                    QrImageView(
                                      data: accountNumber, // Passer les données directement
                                      size: 200.0, // Taille du QR Code
                                      backgroundColor: Colors.white,
                                      errorCorrectionLevel: QrErrorCorrectLevel.L, // Niveau de correction des erreurs
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Aucun numéro de compte trouvé!')),
                        );
                      }
                    },
                    child: Text("Afficher QR Code"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 20), // Espacement sous le bouton pour aérer un peu
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
