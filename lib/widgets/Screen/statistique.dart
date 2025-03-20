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

  // Dictionnaire des types de mouvement et leurs couleurs respectives
  final Map<String, Color> movementColors = {
    'ENVOI D\'ARGENT': Colors.blue,
    'OPERATION DE RETRAIT': Colors.red,
    'OPERATION DE DEPOT': Colors.green,
  };

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
        // print("Réponse de l'API: $data");  // Afficher toute la réponse pour vérification

        // Vérifier si la réponse contient des données
        if (data.isNotEmpty && data[0] is Map<String, dynamic>) {
          // Si les données sont sous forme de liste d'objets
          List<dynamic> stats = data; // Liste des transactions


          List<BarChartGroupData> groups = [];
          Map<int, double> aggregatedDataEnvio = {}; // Agrégation pour ENVOI D'ARGENT
          Map<int, double> aggregatedDataRetrait = {}; // Agrégation pour OPERATION DE RETRAIT
          Map<int, double> aggregatedDataDepot = {}; // Agrégation pour OPERATION DE DEPOT

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

              // Extraire la date (createdat) et convertir en DateTime
              String dateString = stat['createdat']; // Exemple: "2025-03-17 12:44:09"
              DateTime date;
              try {
                // Essayer de convertir la chaîne en DateTime
                date = DateTime.parse(dateString); // Conversion en DateTime
              } catch (e) {
                print("Erreur lors de la conversion de la date: $e");
                continue; // Passer à l'élément suivant si la date est invalide
              }

              // Extraire le mois de la date (le mois est un entier, de 1 à 12)
              int monthIndex = date.month; // Mois extrait sous forme d'entier

              // Agrégation des montants par type de mouvement et par mois
              if (stat['type_mvt'] == 'ENVOI D\'ARGENT') {
                aggregatedDataEnvio[monthIndex] = (aggregatedDataEnvio[monthIndex] ?? 0.0) + value;
              } else if (stat['type_mvt'] == 'OPERATION DE RETRAIT') {
                aggregatedDataRetrait[monthIndex] = (aggregatedDataRetrait[monthIndex] ?? 0.0) + value;
              } else if (stat['type_mvt'] == 'OPERATION DE DEPOT') {
                aggregatedDataDepot[monthIndex] = (aggregatedDataDepot[monthIndex] ?? 0.0) + value;
              }
            }
          }

          // Ajout des données agrégées dans les groupes pour le graphique
          aggregatedDataEnvio.forEach((month, totalAmount) {
            groups.add(
              BarChartGroupData(
                x: month,
                barRods: [
                  BarChartRodData(
                    toY: totalAmount,
                    color: movementColors['ENVOI D\'ARGENT']!, // Utiliser la couleur pour ENVOI D'ARGENT
                    width: 10,
                  ),
                ],
              ),
            );
          });

          aggregatedDataRetrait.forEach((month, totalAmount) {
            groups.add(
              BarChartGroupData(
                x: month,
                barRods: [
                  BarChartRodData(
                    toY: totalAmount,
                    color: movementColors['OPERATION DE RETRAIT']!, // Utiliser la couleur pour RETRAIT
                    width: 10,
                  ),
                ],
              ),
            );
          });

          aggregatedDataDepot.forEach((month, totalAmount) {
            groups.add(
              BarChartGroupData(
                x: month,
                barRods: [
                  BarChartRodData(
                    toY: totalAmount,
                    color: movementColors['OPERATION DE DEPOT']!, // Utiliser la couleur pour DEPOT
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
                    SizedBox(height: 15),
                    Text(
                      'Statistiques sur les transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
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
              child: _head(), // Utilisation de _head
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : barData.isEmpty
                    ? Center(child: Text("Aucune donnée disponible"))
                    : Container(
                  height: 300, // Hauteur fixe pour le graphique
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(show: true),
                      barGroups: barData, // Affichage des barres
                    ),
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
