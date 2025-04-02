import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'transactiondetaillepage.dart';

class detaillehistoriquePage extends StatefulWidget {
  final String numCpte;

  detaillehistoriquePage({required this.numCpte});

  @override
  _detaillehistoriquePageState createState() => _detaillehistoriquePageState();
}

class _detaillehistoriquePageState extends State<detaillehistoriquePage> {
  List<Map<String, dynamic>> historiqueTransactions = [];

  @override
  void initState() {
    super.initState();
    _getTransactions(widget.numCpte);  // Utilisez numCpte passé en argument
  }

  Future<void> _getTransactions(String num_cpte) async {
    final response = await http.get(
      Uri.parse('http://api.credit-fef.com/mobile/MouvementMobilePage.php?num_cpte=$num_cpte'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        setState(() {
          historiqueTransactions = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() {
          historiqueTransactions = []; // Si pas de données, mettre une liste vide
        });
      }
    } else {
      setState(() {
        historiqueTransactions = []; // Si erreur de connexion, liste vide
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Historique des transactions'),
      flexibleSpace: Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [Color(0xff0c355f), Color(0xff014f86)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    ),
    ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: historiqueTransactions.length,
          itemBuilder: (context, index) {
            var transaction = historiqueTransactions[index];
            Color montantColor = Colors.green;
            String montantPrefix = '';

            if (transaction['type_mvt'] == 'OPERATION DE RETRAIT' || transaction['type_mvt'] == 'FRAIS D\'ENTRETIEN DE COMPTE') {
              montantColor = Colors.red;
              montantPrefix = '-';
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: Colors.blue, // Couleur de la bordure
                    width: 0.5, // Épaisseur de la bordure
                  ),
                ),
                child: ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${transaction['type_mvt']}',
                        style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${transaction['createdat']}',
                        style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '$montantPrefix${transaction['mtnt_dep_mvt']} FCFA',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: montantColor),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailsPage(transaction: transaction),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
