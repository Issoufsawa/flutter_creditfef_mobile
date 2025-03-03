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
      appBar: AppBar(
        title: Text('Détails de la transaction'),
        backgroundColor: Color(0xff0c355f),
      ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ajouter le logo au-dessus du contenu
                Image.asset(
                  'assets/images/logo.png',
                  height: 200, // Ajuster la taille du logo
                  width: MediaQuery.of(context).size.width, // Utiliser toute la largeur de l'écran
                  fit: BoxFit.cover, // Le logo remplit toute la largeur tout en respectant le ratio
                ),
                // Supprimer ou ajuster le SizedBox si besoin
                // SizedBox(height: 0), // Espacement après le logo (inutile si height est 0)

                // Card sans hauteur fixe, utilise tout l'espace disponible
                Card(
                  elevation: 5,
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
        )


    );
  }
}
