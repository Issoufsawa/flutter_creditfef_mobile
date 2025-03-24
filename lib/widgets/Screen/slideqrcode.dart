import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/Screen/payementformpage.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';  // Importer qr_flutter
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour décoder la réponse JSON
import 'package:shared_preferences/shared_preferences.dart'; // Importer shared_preferences

class SlideqrcodePage extends StatefulWidget {
  const SlideqrcodePage({super.key, required this.title});

  final String title;

  @override
  State<SlideqrcodePage> createState() => _SlideqrcodePageState();
}

class _SlideqrcodePageState extends State<SlideqrcodePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrText = "Scanner pour envoyer"; // Texte par défaut avant le scan
  String accountNumber = ""; // Variable pour stocker le numéro de compte
  double _sliderValue = 0.0; // Valeur du slider pour contrôler l'affichage des vues

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
          // Ajoutez un délai pour que le widget ait le temps de se construire
          await Future.delayed(Duration(milliseconds: 200));

          if (!mounted) return;  // Vérifiez si le widget est toujours monté avant de naviguer
          // Passer le QR code à la page de paiement
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentFormPage(qrCode: qrText), // Passer le QR code
            ),
          );
        } else {
          // Si le QR Code est invalide, afficher un message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Code QR invalide. Veuillez réessayer.')),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Partie principale : afficher la caméra pour scanner le QR Code
            Expanded(
              child: Stack(
                children: [
                  // Affichage de la vue caméra ou QR code en fonction du slider
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: _sliderValue < 0.5 ? _buildScannerPage() : _buildQrCodePage(),
                  ),
                  // Ajout d'un Slider pour changer de vue
                  Positioned(
                    bottom: 20.0, // Placer le Slider en bas
                    left: 20.0,
                    right: 20.0,
                    child: Slider(
                      value: _sliderValue,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page Scanner QR
  Widget _buildScannerPage() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.green,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250.0,  // Taille du découpage central pour scanner
        ),
      ),
    );
  }

  // Page QR Code du compte
  Widget _buildQrCodePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (accountNumber.isNotEmpty)
            QrImageView(
              data: accountNumber, // Passer les données directement
              size: 300.0, // Taille du QR Code
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.L,
            )
          else
            Text(
              'Aucun numéro de compte trouvé',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
