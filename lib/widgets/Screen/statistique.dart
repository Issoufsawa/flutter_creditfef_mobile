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
    _fetchData();
  }

  // Fonction pour récupérer les données de l'API
  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    numCpte = prefs.getString('num_cpte') ?? ''; // Utiliser un compte par défaut si non trouvé

    final url =
        'http://api.credit-fef.com/mobile/MouvementMobilePageStat.php?num_cpte=$numCpte';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        // Vérifier si la réponse contient les données attendues
        if (data['status'] == 'success') {
          final List<dynamic> stats = data['data'];

          // Construire les données pour le graphique en barres
          List<BarChartGroupData> groups = [];

          // Ajouter un mappage explicite des mois en entiers
          Map<String, int> monthMap = {
            "Jan": 1,
            "Feb": 2,
            "Mar": 3,
            "Apr": 4,
            "May": 5,
            "Jun": 6,
            "Jul": 7,
            "Aug": 8,
            "Sep": 9,
            "Oct": 10,
            "Nov": 11,
            "Dec": 12,
          };

          for (var stat in stats) {
            double value = stat['mtnt_dep_mvt'].toDouble();  // Montant de la transaction
            String month = stat['createdat'].substring(5, 7);  // Extraire le mois de la date (format "2025-03-17")

            // Convertir le mois de chaîne à entier
            int xValue = monthMap[month] ?? 0;  // Si le mois n'est pas trouvé, on met 0 par défaut

            groups.add(BarChartGroupData(
              x: xValue,  // Utiliser l'entier comme index pour le mois
              barRods: [
                BarChartRodData(
                  toY: value,  // La valeur des transactions
                  color: Colors.blue,
                  width: 10,
                ),
              ],
            ));
          }

          setState(() {
            barData = groups;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            barData = [];  // Vide les données du graphique si le statut n'est pas success
          });
        }
      } else {
        setState(() {
          isLoading = false;
          barData = [];  // Vide les données du graphique en cas de réponse HTTP non valide
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des données: $e");
      setState(() {
        isLoading = false;
        barData = [];  // Vide les données en cas d'erreur
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
              child: _head(), // Utilisation de _head sans hauteur spécifique ici
            ),
            // Affichage du graphique des statistiques
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : barData.isEmpty
                    ? Center(child: Text("Aucune donnée disponible"))
                    : BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: true),
                    barGroups: barData,
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
