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
  List<LineChartBarData> lineData = []; // Données pour le graphique en courbes
  int selectedMonth = DateTime.now().month; // Mois par défaut (mois actuel)

  // Liste des mois en texte
  final List<String> monthNames = [
    "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
  ];

  // Liste des types de mouvement
  final List<String> movementTypes = ['ENVOI D\'ARGENT', 'OPERATION DE RETRAIT', 'OPERATION DE DEPOT'];
  final List<Color> movementColors = [Colors.blue, Colors.red, Colors.green]; // Couleurs associées aux mouvements

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
          // Si les données sont sous forme de liste d'objets
          List<dynamic> stats = data; // Liste des transactions

          Map<String, List<FlSpot>> aggregatedData = {}; // Agrégation des différents types de mouvements

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
                // Initialisation des listes pour chaque type de mouvement
                if (!aggregatedData.containsKey(movementType)) {
                  aggregatedData[movementType] = [];
                }

                aggregatedData[movementType]?.add(FlSpot(monthIndex.toDouble(), value)); // Inverser X et Y
              }
            }
          }

          List<LineChartBarData> lineChartData = [];

          // Créer une ligne pour chaque type de mouvement
          for (int i = 0; i < movementTypes.length; i++) {
            String movementType = movementTypes[i];
            List<FlSpot>? dataPoints = aggregatedData[movementType];

            if (dataPoints != null && dataPoints.isNotEmpty) {
              lineChartData.add(
                LineChartBarData(
                  spots: dataPoints, // Les points de données pour la courbe
                  isCurved: true, // Rendre la ligne courbée
                  color: movementColors[i], // Couleur de la ligne
                  dotData: FlDotData(show: false), // Désactiver les points
                  belowBarData: BarAreaData(show: false), // Désactiver l'ombre sous la courbe
                ),
              );
            }
          }

          setState(() {
            lineData = lineChartData; // Affecter les courbes au graphique
            isLoading = false;
          });
        } else {
          print("Erreur : La structure des données n'est pas valide.");
          setState(() {
            isLoading = false;
            lineData = [];
          });
        }
      } else {
        print("Erreur HTTP : ${response.statusCode}");
        setState(() {
          isLoading = false;
          lineData = [];
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des données: $e");
      setState(() {
        isLoading = false;
        lineData = [];
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
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            _head(), // En-tête avec logo
            Expanded(
              child: SingleChildScrollView(  // Utilisation de SingleChildScrollView pour le reste du contenu
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Toujours afficher le bouton pour sélectionner le mois
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sélectionner le mois: ',
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
                                selectedMonth = value!; // Mise à jour du mois sélectionné
                                isLoading = true; // Réinitialiser le chargement
                              });
                              _fetchData(); // Recharger les données avec le mois sélectionné
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 1), // Espacement après le bouton de sélection

                      // Affichage du graphique ou du message "Aucune donnée disponible"
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : lineData.isEmpty
                          ? Center(child: Text("Aucune donnée disponible", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))
                          : Column(
                        children: [
                          SizedBox(height: 20), // Espace au-dessus du graphique
                          Container(
                            height: 410, // Hauteur fixe pour le graphique
                            child: LineChart(
                              LineChartData(
                                borderData: FlBorderData(show: true),
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, TitleMeta meta) {
                                        // Affichage des valeurs sur l'axe Y
                                        return Text(value.toString());
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, TitleMeta meta) {
                                        // Affichage des mois sur l'axe X
                                        int monthIndex = value.toInt();
                                        if (monthIndex >= 1 && monthIndex <= 12) {
                                          return Text(monthNames[monthIndex - 1]); // Affichage du mois
                                        }
                                        return Text('');
                                      },
                                    ),
                                  ),
                                ),
                                lineBarsData: lineData, // Affichage des courbes
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
