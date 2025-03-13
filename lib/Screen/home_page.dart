import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../widgets/Screen/detaillehistoriquepage.dart';
import '../widgets/Screen/transactiondetaillepage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isTextVisible = true;
  String _num_cpte = "";
  String _solde = "";

  List<Map<String, dynamic>> historiqueTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _num_cpte = prefs.getString('num_cpte') ?? 'Numéro de compte non défini';
      _solde = prefs.getString('solde') ?? 'Solde non défini';
    });

    await _getUserNameFromApi(_num_cpte);
  }

  Future<void> _getUserNameFromApi(String num_cpte) async {
    final response = await http.get(
      Uri.parse('http://api.credit-fef.com/mobile/listeMobilePage.php?num_cpte=$num_cpte'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        setState(() {
          historiqueTransactions = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() {
          _num_cpte = 'Erreur de format de données';
          _solde = 'Erreur de format de données';
        });
      }
    } else {
      setState(() {
        _num_cpte = 'Erreur de connexion';
        _solde = 'Erreur de connexion';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 340, child: _head())),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => detaillehistoriquePage(
                              historiqueTransactions: historiqueTransactions,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Voir tout',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: List.generate(
                    historiqueTransactions.length > 5 ? 5 : historiqueTransactions.length,
                        (index) {
                      var transaction = historiqueTransactions[index];
                      Color montantColor = Colors.green;
                      String montantPrefix = '';

                      if (transaction['type_mvt'] == 'OPERATION DE RETRAIT' || transaction['type_mvt'] == 'FRAIS D\'ENTRETIEN DE COMPTE') {
                        montantColor = Colors.red;
                        montantPrefix = '-';
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionDetailsPage(transaction: transaction),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${transaction['type_mvt']}',
                                      style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${transaction['createdat']}',
                                      style: TextStyle(fontSize: 15, color: Colors.black),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  '$montantPrefix${transaction['mtnt_dep_mvt']} \FCFA',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: montantColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _head() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 248,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0c355f), Color(0xff014f86)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 35, left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crédit fef',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 90,
          left: 30,
          child: Container(
            height: 200,
            width: 300,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 6, 113, 213),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'COMPTE COURANT SOCIAL (C COS)',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Text(
                        _num_cpte,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: Color(0xff0c355f),
                            child: Icon(Icons.arrow_downward, color: Colors.white, size: 19),
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Solde',
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color.fromARGB(255, 216, 216, 216)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isTextVisible ? ' ${_solde} \FCFA' : '********',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white),
                      ),
                      IconButton(
                        icon: Icon(
                          _isTextVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isTextVisible = !_isTextVisible;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
