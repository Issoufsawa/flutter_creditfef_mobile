import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../widgets/Screen/detaillehistoriquepage.dart';
import '../widgets/Screen/slideqrcode.dart';
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
  String selectedAccount = "compteCourant";

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 🔄 Lire le type de compte sauvegardé
    selectedAccount = prefs.getString('selectedAccount') ?? 'compteCourant';

    // 🔁 Charger selon le type de compte
    if (selectedAccount == 'compteEpargne') {
      _num_cpte = prefs.getString('num_cpte_ep') ?? 'Numéro épargne non défini';
      _solde = prefs.getString('solde_cpte_ep') ?? 'Solde non défini';
    } else {
      _num_cpte = prefs.getString('num_cpte') ?? 'Numéro courant non défini';
      _solde = prefs.getString('solde') ?? 'Solde non défini';
    }

    setState(() {});

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

  Future<void> _getAccountData(String action) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 🔒 Sauvegarde du compte sélectionné
    await prefs.setString('selectedAccount', action);

    if (action == 'compteCourant') {
      setState(() {
        _num_cpte = prefs.getString('num_cpte') ?? 'Compte non défini';
        _solde = prefs.getString('solde') ?? 'Solde non défini';
      });
      await _getUserNameFromApi(_num_cpte);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://api.credit-fef.com/mobile/CompteMobilePage.php?action=$action'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Données brutes de l'API ($action): $data");
        if (action == 'compteEpargne') {
          if (data is List && data.isNotEmpty && data[0] is Map<String, dynamic>) {
            final compteData = data[0];
            final compte = (compteData['num_cpte_ep'] ?? 'N/A').toString();
            final solde = (compteData['solde_cpte_ep'] ?? '0').toString();

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('num_cpte_ep', compte);
            await prefs.setString('solde_cpte_ep', solde);

            setState(() {
              _num_cpte = compte;
              _solde = solde;
            });

            print('✅ Compte épargne chargé et sauvegardé : $_num_cpte');

            await _getUserNameFromApi(compte);
          } else {
            print('❌ Format inattendu pour compteEpargne : $data');
          }
        }

      } else {
        print('Erreur HTTP: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur API : ${response.statusCode}")),
        );
      }
    } catch (e) {
      print('Exception attrapée : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Une erreur est survenue : $e")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 360, child: _head()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transactions',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 23,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => detaillehistoriquePage(numCpte: _num_cpte),
                        ),
                      );
                    },
                    child: Text(
                      'Voir tout',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 23,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: List.generate(
                      historiqueTransactions.length > 5 ? 5 : historiqueTransactions.length,
                          (index) {
                        var transaction = historiqueTransactions[index];
                        Color montantColor = Colors.green;
                        String montantPrefix = '';

                        if (transaction['type_mvt'] == 'OPERATION DE RETRAIT' ||
                            transaction['type_mvt'] == 'FRAIS D\'ENTRETIEN DE COMPTE') {
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
                              color: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: Colors.blue, width: 0.5),
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
                                        style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w600),
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
          height: 300,
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
              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 35, left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccountTitle(),
                SizedBox(height: 50),
                _buildAccountNumber(),
                SizedBox(height: 50),
                _buildAccountBalance(),
              ],
            ),
          ),
        ),
        Positioned(
          top: 270,
          left: 12,
          right: 12,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SlideqrcodePage(title: 'slideqrcode')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text(
                "Effectuer une opération",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedAccount == "compteEpargne"
                ? 'COMPTE EPARGNE'
                : 'COMPTE COURANT SOCIAL (C COS)',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: Colors.white),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 40),
            onPressed: () async {
              final selected = await showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text("Sélectionner un compte"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text("Compte Courant"),
                        onTap: () => Navigator.pop(context, "compteCourant"),
                      ),
                      ListTile(
                        title: Text("Compte Epargne"),
                        onTap: () => Navigator.pop(context, "compteEpargne"),
                      ),
                      ListTile(
                        title: Text("Compte Crédit"),
                        onTap: () => Navigator.pop(context, "compteCredit"),
                      ),
                    ],
                  ),
                ),
              );
              if (selected != null) {
                setState(() {
                  selectedAccount = selected;
                });
                _getAccountData(selected);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountNumber() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Text(
            'N° $_num_cpte',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountBalance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isTextVisible ? '$_solde FCFA' : '********',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 32, color: Colors.white),
          ),
          IconButton(
            icon: Icon(
              _isTextVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              setState(() {
                _isTextVisible = !_isTextVisible;
              });
            },
          ),
        ],
      ),
    );
  }
}
