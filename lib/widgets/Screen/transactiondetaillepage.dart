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
      appBar: null, // Supprimer l'AppBar
      body: SafeArea(
        child: Column(
          children: [
            // Container avec dégradé et Card en remplacement de l'AppBar
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0c355f), Color(0xff014f86)], // Couleurs du dégradé
                  begin: Alignment.topLeft, // Début du dégradé
                  end: Alignment.bottomRight, // Fin du dégradé
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                margin: EdgeInsets.all(0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff0c355f), Color(0xff014f86)], // Couleurs du dégradé
                      begin: Alignment.topLeft, // Début du dégradé
                      end: Alignment.bottomRight, // Fin du dégradé
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Flèche de retour
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context); // Revenir à la page précédente
                          },
                        ),
                        Spacer(),
                        Text(
                          'Détails de la transaction', // Titre
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Texte en blanc pour contraster avec le fond
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Corps de la page
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 120), // Espace pour l'élément avec dégradé

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
                              // Ajouter le logo en haut de la Card
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 16), // Espacement sous le logo
                                  child: Image.asset(
                                    'assets/money.png', // Remplacer par le chemin de votre logo
                                    height: 50, // Ajuster la taille du logo
                                    width: 50, // Ajuster la taille du logo
                                  ),
                                ),
                              ),

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
                              SizedBox(height: 20), // Espacement entre les lignes

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
                              SizedBox(height: 20), // Espacement entre les lignes

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
                              SizedBox(height: 20), // Espacement entre les lignes

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
            ),
          ],
        ),
      ),
    );
  }
}
