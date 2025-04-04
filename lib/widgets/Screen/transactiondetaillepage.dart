import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> transaction; // Recevoir la transaction détaillée

  TransactionDetailsPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Définir le signe moins et la couleur du montant
    String montantPrefix = '';
    Color montantColor = Colors.green; // Valeur par défaut (dépôt)

    if (transaction['type_mvt'] == 'OPERATION DE RETRAIT' || transaction['type_mvt'] == 'FRAIS D\'ENTRETIEN DE COMPTE') {
      montantPrefix = '-'; // Ajouter le signe - pour ces types de transactions
      montantColor = Colors.red; // Appliquer la couleur rouge pour les retraits et frais
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0c355f), Color(0xff014f86)], // Dégradé
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)), // Coins arrondis
          ),
          child: AppBar(
            title: Text(
              'Détails de la transaction',
              style: TextStyle(fontSize: 20),
            ),
            centerTitle: true, // Centrer le titre
            backgroundColor: Colors.transparent, // AppBar transparent pour laisser apparaître le dégradé
            elevation: 0, // Supprimer l'ombre de l'AppBar
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120),
              // Card sans hauteur fixe, utilise tout l'espace disponible
              Card(
                elevation: 1,
                margin: EdgeInsets.symmetric(vertical: 0), // Réduire ou supprimer l'espacement vertical
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Code de la transaction
                      Row(
                        children: [
                          SizedBox(width: 0),
                          Text(
                            'Code de la transaction: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Expanded(
                            child: Text(
                              '${transaction['code_mvt']}',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.end, // Aligner le texte à droite
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 90), // Espacement entre les lignes

                      // Type de la transaction
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            'Type d\'opération: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Expanded(
                            child: Text(
                              '${transaction['type_mvt']}',
                              style: TextStyle(fontSize: 16, color: Colors.blue),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 90), // Espacement entre les lignes

                      // Montant de la transaction
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            'Montant: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Expanded(
                            child: Text(
                              '$montantPrefix${transaction['mtnt_dep_mvt']} FCFA',
                              style: TextStyle(fontSize: 16, color: montantColor),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 90), // Espacement entre les lignes

                      // Date de la transaction
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            'Date et heure: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Expanded(
                            child: Text(
                              '${transaction['createdat']}',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
