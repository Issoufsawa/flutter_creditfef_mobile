import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'transactiondetaillepage.dart';  // Assurez-vous d'importer la page de détails

class detaillehistoriquePage extends StatelessWidget {
  final List<Map<String, dynamic>> historiqueTransactions; // Liste des transactions

  // Constructeur pour recevoir la liste des transactions
  detaillehistoriquePage({required this.historiqueTransactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des transactions'),
        backgroundColor: Color(0xff0c355f),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Espace entre l'AppBar et le début du contenu
            SliverToBoxAdapter(
              child: SizedBox(height: 30),
            ),

            // Ajouter le logo au-dessus du contenu
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Image.asset(
                  'assets/images/logo.png', // Chemin de votre logo
                  height: 150, // Ajuster la taille du logo
                  width: MediaQuery.of(context).size.width, // Utiliser toute la largeur de l'écran
                  fit: BoxFit.cover, // Le logo remplira toute la largeur tout en respectant le ratio
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Historique des transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  var transaction = historiqueTransactions[index];

                  // Vérification des types de transaction pour appliquer la couleur
                  Color montantColor = Colors.green; // Valeur par défaut (dépôt)
                  String montantPrefix = ''; // Pas de signe au début pour les dépôts

                  if (transaction['type_mvt'] == 'OPERATION DE RETRAIT' || transaction['type_mvt'] == 'FRAIS D\'ENTRETIEN DE COMPTE') {
                    montantColor = Colors.red; // Si c'est un retrait ou frais d'entretien
                    montantPrefix = '-'; // Ajouter le signe - pour les retraits et frais d'entretien
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0), // Ajout d'un espacement vertical
                    child: Card(
                      elevation: 5, // Ombre de la Card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Coins arrondis
                      ),
                      child: ListTile(
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${transaction['type_mvt']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${transaction['createdat']}',
                              style: TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '$montantPrefix${transaction['mtnt_dep_mvt']} FCFA',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 19,
                            color: montantColor, // Applique la couleur selon le type
                          ),
                        ),
                        onTap: () {
                          // Naviguer vers la page de détails de la transaction
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
                childCount: historiqueTransactions.length, // Afficher toutes les transactions
              ),
            ),
          ],
        ),
      ),
    );
  }
}
