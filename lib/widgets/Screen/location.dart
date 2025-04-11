import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart'; // Importer le package location

class LocationPage extends StatefulWidget {
  const LocationPage({super.key, required this.title});

  final String title;

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  LatLng _currentLocation = LatLng(48.8566, 2.3522); // Exemple: Paris
  late Location _location; // Variable pour gérer la localisation
  late LocationData _locationData; // Contiendra les données de localisation de l'utilisateur
  late MapController _mapController; // Déclarer un MapController

  // Liste des nouvelles coordonnées supplémentaires à ajouter
  final List<LatLng> _additionalLocations = [
    LatLng(5.403278, -4.006528), // ABOBO DOKUI | 27 24 54 96 98
    LatLng(5.348639, -4.017222), // ADJAME LIBERTE
    LatLng(5.3449284, -4.0838084), // YOPOUGON
    LatLng(5.290778, -3.958556), // KOUMASSI GRAND MARCHE
    LatLng(5.300528, -3.976000), // MARCORY GRAND MARCHE
    LatLng(5.3566104, -3.879401), // BINGERVILLE non loin du lycée Moderne "le Conquérant"
    LatLng(5.3922778, -3.9780833), // COCODY ANGRE 8 EME TRANCHE
    LatLng(5.4854722, -4.0534444), // ANYAMA
    LatLng(5.3237835, -4.3766238), // DABOU gare de taxi
  ];

  @override
  void initState() {
    super.initState();
    _location = Location();
    _mapController = MapController(); // Initialiser MapController
    _getCurrentLocation();  // Récupérer la localisation dès que l'écran est initialisé
  }

  // Fonction pour obtenir la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return; // Si le service est toujours désactivé, arrêter
      }
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return; // Si la permission est toujours refusée, arrêter
      }
    }

    _locationData = await _location.getLocation();

    // Mettre à jour la localisation
    setState(() {
      _currentLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    });

    // Centrer la carte sur la position actuelle après avoir récupéré la localisation
    // Déplacer la carte à la nouvelle position avec un zoom de 13
    _mapController.move(_currentLocation, 13.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Augmenter la taille de l'AppBar à 100 pixels
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Localiser une de nos agences',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            centerTitle: true, // Centrer le titre
            backgroundColor: Colors.transparent, // AppBar transparent pour laisser apparaître le dégradé
            elevation: 0, // Supprimer l'ombre de l'AppBar
          ),
        ),
      ),

      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Affichage de la carte
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5, // 50% de la hauteur de l'écran
                child: FlutterMap(
                  mapController: _mapController, // Passer le MapController ici
                  options: MapOptions(
                    // Retirer 'center' et 'zoom' ici, car il faut gérer ça avec le MapController
                    // Ces propriétés ne sont plus directement disponibles dans la MapOptions
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        // Marqueur pour la position actuelle
                        Marker(
                          point: _currentLocation, // Position actuelle de l'utilisateur
                          width: 40, // Largeur de l'icône
                          height: 40, // Hauteur de l'icône
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        // Marqueurs pour les nouvelles positions supplémentaires
                        for (var location in _additionalLocations)
                          Marker(
                            point: location, // Chaque point de la liste des coordonnées supplémentaires
                            width: 30, // Largeur de l'icône
                            height: 30, // Hauteur de l'icône
                            child: Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 30,
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
    );
  }
}
