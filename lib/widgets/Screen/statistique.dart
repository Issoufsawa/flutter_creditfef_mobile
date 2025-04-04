import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour décoder la réponse JSON
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class StatistiquePage extends StatefulWidget {
  const StatistiquePage({super.key, required this.title});

  final String title;

  @override
  State<StatistiquePage> createState() => _StatistiquePageState();
}

class _StatistiquePageState extends State<StatistiquePage> {
  late String numCpte; // Variable pour stocker le numéro de compte
  bool isLoading = true; // Indicateur pour afficher le chargement
  List<BarChartGroupData> barData = []; // Données pour le graphique en barres
  int selectedMonth = DateTime.now().month; // Mois par défaut (mois actuel)

  // Liste des mois en texte
  final List<String> monthNames = [
    "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
  ];

  @override
  void initState() {
    super.initState();
    _fetchData(); // Appeler la fonction pour récupérer les données au démarrage
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    numCpte = prefs.getString('num_cpte') ?? ''; // Utiliser un compte par défaut si non trouvé

    final url = 'http://api.credit-fef.com/mobile/MouvementMobilePageStat.php?num_cpte=$numCpte';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Décoder la réponse de l'API comme une liste de données
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty && data[0] is Map<String, dynamic>) {
          List<dynamic> stats = data; // Liste des transactions

          List<BarChartGroupData> groups = [];
          Map<String, double> aggregatedData = {}; // Agrégation des différents types de mouvements

          // Parcourir les données des transactions
          for (var stat in stats) {
            if (stat is Map<String, dynamic>) {
              // Extraire le montant et le convertir en double
              double value = 0.0;
              if (stat['mtnt_dep_mvt'] != null) {
                value = (stat['mtnt_dep_mvt'] is num)
                    ? (stat['mtnt_dep_mvt'] as num).toDouble()
                    : double.tryParse(stat['mtnt_dep_mvt'].toString()) ?? 0.0;
              }

              // Extraire le mois et le type de mouvement
              String movementType = stat['type_mvt']; // Type de mouvement
              int monthIndex = DateTime.parse(stat['createdat']).month; // Mois de la transaction

              // Si le mois de la transaction correspond au mois sélectionné, l'agréger
              if (monthIndex == selectedMonth) {
                aggregatedData[movementType] = (aggregatedData[movementType] ?? 0.0) + value;
              }
            }
          }

          // Ajout des données agrégées dans les groupes pour le graphique
          final movementTypes = ['ENVOI D\'ARGENT', 'OPERATION DE RETRAIT', 'OPERATION DE DEPOT'];
          final movementColors = [Colors.blue, Colors.red, Colors.green];

          for (int i = 0; i < movementTypes.length; i++) {
            String movementType = movementTypes[i];
            double totalAmount = aggregatedData[movementType] ?? 0.0;

            groups.add(
              BarChartGroupData(
                x: i, // Utilisation de l'index des types de mouvements
                barRods: [
                  BarChartRodData(
                    toY: totalAmount / 5000, // Utilisation d'une échelle avec 1 cm = 5000
                    color: movementColors[i], // Couleur assignée pour chaque type de mouvement
                    width: 16, // Largeur des barres plus grande pour un meilleur affichage
                  ),
                ],
              ),
            );
          }

          setState(() {
            barData = groups; // Affecter les groupes au graphique
            isLoading = false;
          });
        } else {
          print("Erreur : La structure des données n'est pas valide.");
          setState(() {
            isLoading = false;
            barData = [];
          });
        }
      } else {
        print("Erreur HTTP : ${response.statusCode}");
        setState(() {
          isLoading = false;
          barData = [];
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des données: $e");
      setState(() {
        isLoading = false;
        barData = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0c355f), Color(0xff014f86)], // Couleurs du dégradé
              begin: Alignment.topLeft, // Début du dégradé
              end: Alignment.bottomRight, // Fin du dégradé
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)), // Coins arrondis
          ),
          child: AppBar(
            title: Text('Statistiques sur les Transactions'),
            centerTitle: true,
            backgroundColor: Colors.transparent, // AppBar transparent pour laisser apparaître le dégradé
            elevation: 0, // Supprimer l'ombre de l'AppBar
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sélectionner le mois:',
                            style: TextStyle(fontSize: 18),
                          ),
                          DropdownButton<int>(
                            value: selectedMonth,
                            items: List.generate(12, (index) {
                              return DropdownMenuItem<int>(
                                value: index + 1,
                                child: Text(monthNames[index]), // Affichage du mois en texte
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value!;
                                isLoading = true;
                              });
                              _fetchData(); // Recharger les données avec le mois sélectionné
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : barData.isEmpty
                          ? Center(child: Text("Aucune donnée disponible", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))
                          : Column(
                        children: [
                          Container(
                            height: 410, // Hauteur fixe pour le graphique
                            child: BarChart(
                              BarChartData(
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, TitleMeta meta) {
                                        if (value == 0) {
                                          return Text('ENVOI');
                                        } else if (value == 1) {
                                          return Text('RETRAIT');
                                        } else if (value == 2) {
                                          return Text('DEPOT');
                                        }
                                        return Text('');
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, TitleMeta meta) {
                                        return Text('${value * 5000}'); // Afficher les valeurs sur l'axe X
                                      },
                                    ),
                                  ),
                                ),
                                barGroups: barData, // Affichage des barres
                                gridData: FlGridData(show: true),
                              ),
                            ),
                          ),
                        ],
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
