import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour décoder la réponse JSON
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchData(); // Appeler la fonction pour récupérer les données au démarrage
  }

  // Fonction pour récupérer les données de l'API
  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    numCpte =
        prefs.getString('num_cpte') ??
        ''; // Utiliser un compte par défaut si non trouvé

    final url =
        'http://api.credit-fef.com/mobile/MouvementMobilePageStat.php?num_cpte=$numCpte';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Réponse de l'API: $data");

        if (data['status'] == 'success') {
          final stats = data['data']; // Liste des transactions
          print(
            "Type des données reçues: ${stats.runtimeType}",
          ); // Vérification du type des données

          List<BarChartGroupData> groups = [];
          Map<int, double> aggregatedData =
              {}; // Utiliser un int pour les mois (1-12)

          // Parcourir les données
          for (var stat in stats) {
            if (stat is Map<String, dynamic>) {
              // Affichage de la structure de chaque transaction pour débogage
              print("Transaction reçue: $stat");

              // Extraire le montant et le convertir en double
              double value = 0.0;
              if (stat['mtnt_dep_mvt'] != null) {
                value =
                    (stat['mtnt_dep_mvt'] is num)
                        ? (stat['mtnt_dep_mvt'] as num).toDouble()
                        : double.tryParse(stat['mtnt_dep_mvt'].toString()) ??
                            0.0;
              }

              // Extraire la date (createdat) et convertir en DateTime
              String dateString =
                  stat['createdat']; // Exemple: "2025-03-17 12:44:09"
              DateTime date;
              try {
                date = DateTime.parse(dateString); // Conversion en DateTime
              } catch (e) {
                print("Erreur lors de la conversion de la date: $e");
                continue; // Passer à l'élément suivant si la date est invalide
              }

              // Extraire le mois de la date (le mois est un entier, de 1 à 12)
              int monthIndex = date.month; // Mois extrait sous forme d'entier
              print(
                "Mois extrait: $monthIndex (Type: ${monthIndex.runtimeType})",
              ); // Afficher le type du mois

              // Vérification pour s'assurer que le mois est un entier valide
              if (monthIndex is! int) {
                print(
                  "Erreur: mois n'est pas un entier. Mois reçu: $monthIndex",
                );
                continue;
              }

              // Agrégation des montants par mois
              if (!aggregatedData.containsKey(monthIndex)) {
                aggregatedData[monthIndex] = 0.0;
              }
              aggregatedData[monthIndex] = aggregatedData[monthIndex]! + value;
            } else {
              print("Element inattendu dans stats: $stat");
            }
          }

          // Ajouter les données agrégées dans les groupes pour le graphique
          aggregatedData.forEach((month, totalAmount) {
            print(
              "Mois: $month, Total: $totalAmount",
            ); // Affichage pour débogage
            groups.add(
              BarChartGroupData(
                x: month, // Le mois est un entier entre 1 et 12
                barRods: [
                  BarChartRodData(
                    toY: totalAmount,
                    color: Colors.blue,
                    width: 10,
                  ),
                ],
              ),
            );
          });

          setState(() {
            barData = groups; // Affecter les groupes au graphique
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            barData = [];
          });
        }
      } else {
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

  // Méthode pour afficher l'en-tête avec le logo et le titre "Statistiques sur les transactions"
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
                    SizedBox(height: 15), // Ajuster l'espacement sous le logo
                    Text(
                      'Statistiques sur les transactions',
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
            // Affichage de l'en-tête
            SliverToBoxAdapter(
              child:
                  _head(), // Utilisation de _head sans hauteur spécifique ici
            ),
            // Affichage du graphique des statistiques
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : barData.isEmpty
                        ? Center(child: Text("Aucune donnée disponible"))
                        : BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(show: true),
                            barGroups: barData, // Affichage des barres
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
