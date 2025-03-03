import 'package:flutter/material.dart';


class LocationPage extends StatefulWidget {
  const LocationPage({super.key, required this.title});

  final String title;

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  // Définir les coordonnées des points d'intérêt
  final List<List<double>> coordinates = [
    [-6.175329, 106.827253],  // Jakarta
    [-6.200000, 106.800000],  // Autre point
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: 340, child: _head()),
            ),

          ],
        ),
      ),
    );
  }

  Widget _head() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 248,  // You can adjust the height as needed, but it's fine here
              decoration: BoxDecoration(
                color: Color(0xff0c355f),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 35, left: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row to display image and text side by side
                        Row(
                          children: [
                            // Image instead of icon

                            Text(
                              'Crédit fef',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 60),
                        Text(
                          'Localiser une de nos agences',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ],
    );

  }

}
