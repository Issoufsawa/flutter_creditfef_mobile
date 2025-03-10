import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/Screen/payementformpage.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

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

  // Définir la valeur à comparer
  final String expectedQRCode = "123456"; // Le QR Code attendu

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

    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        setState(() {
          qrText = scanData.code!;
        });
        print('QR Code scanné: $qrText');  // Debug info

        // Comparer le QR Code scanné avec la valeur attendue
        if (qrText == expectedQRCode) {
          // Si le QR Code correspond, naviguer vers une nouvelle page
          Navigator.pop(context); // Fermer le dialogue
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PaymentFormPage()), // Page de succès
          );
        } else {
          // Si le QR Code ne correspond pas, afficher un message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Code QR invalide. Veuillez réessayer.')),
          );
          Navigator.pop(context); // Fermer le dialogue
        }
      }
    });
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
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}



