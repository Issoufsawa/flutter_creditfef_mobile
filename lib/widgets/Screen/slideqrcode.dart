import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/Screen/payementformpage.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SlideqrcodePage extends StatefulWidget {
  const SlideqrcodePage({super.key, required this.title});

  final String title;

  @override
  State<SlideqrcodePage> createState() => _SlideqrcodePageState();
}

class _SlideqrcodePageState extends State<SlideqrcodePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrText = "Scanner pour envoyer";
  String accountNumber = "";
  int _selectedIndex = 0; // 0 = Scanner un code, 1 = Ma carte
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadAccountNumber();
  }

  Future<void> _loadAccountNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accountNumber = prefs.getString('num_cpte') ?? "";
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        setState(() {
          qrText = scanData.code!;
        });

        bool isValid = await _callApi(qrText);

        if (!mounted) return;

        if (isValid) {
          await Future.delayed(Duration(milliseconds: 200));
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentFormPage(qrCode: qrText),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Code QR invalide. Veuillez réessayer.')),
          );
        }
      }
    });
  }

  Future<bool> _callApi(String qrCode) async {
    final String apiUrl =
        'http://api.credit-fef.com/mobile/VerificationMobilePage.php?num_cpte=$qrCode';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data == 1;
      } else {
        throw Exception('Échec de la requête API');
      }
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Barre supérieure avec le bouton de fermeture
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, size: 30, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Ferme la page et revient en arrière
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  _buildScannerPage(),
                  _buildQrCodePage(),
                ],
              ),
            ),
            _buildSegmentedControl(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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
          cutOutSize: 250.0,
        ),
      ),
    );
  }

  Widget _buildQrCodePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xff0c355f),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                if (accountNumber.isNotEmpty)
                  QrImageView(
                    data: accountNumber,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.L,
                  )
                else
                  Text(
                    'Aucun numéro de compte trouvé',
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 10),
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xff0c355f), // Couleur de fond
          borderRadius: BorderRadius.circular(30), // Bordures arrondies
          border: Border.all(color: Colors.grey.shade500, width: 2), // Bordure personnalisée
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2), // Ombre en bas pour effet de relief
            ),
          ],
        ),
        child: CupertinoSegmentedControl<int>(
          groupValue: _selectedIndex,
          selectedColor: Colors.grey.shade500, // Bleu foncé sélectionné
          unselectedColor: Colors.transparent,
          borderColor: Colors.transparent, // On masque la bordure d'origine
          pressedColor: Colors.blue.shade100, // Effet appuyé
          children: {
            0: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Text(
                "Scanner un code",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _selectedIndex == 0 ? Colors.white : Colors.black,
                ),
              ),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Text(
                "Ma carte",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _selectedIndex == 1 ? Colors.white : Colors.black,
                ),
              ),
            ),
          },
          onValueChanged: (int value) {
            setState(() {
              _selectedIndex = value;
            });
            _pageController.animateToPage(
              value,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }

}
