
import 'package:flutter/material.dart';

import 'chargepage.dart';


class WalletPage extends StatefulWidget {
  const WalletPage({super.key, required this.title});

  final String title;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: 340, child: _head()),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>chargepage(), // La page vers laquelle vous naviguez
                      ),
                    );       },
                  child: Row(

                    children: [
                       Icon(
                        Icons.account_balance_outlined,
                        size: 30,
                        color: Colors.black,
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Recharger sa carte QR code',
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
                          'Services',
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
