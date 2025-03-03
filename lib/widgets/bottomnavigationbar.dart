
import 'package:flutter/material.dart';

import '../Screen/home_page.dart';
import 'Screen/location.dart';
import 'Screen/profile_page.dart';
import 'Screen/wallet_page.dart';



class Bottom extends StatefulWidget{
  const Bottom({Key? key}) : super(key: key);
  @override
  State<Bottom> createState()=> _BottomState();
}

class _BottomState extends State<Bottom> {
  int index_color = 0;
  List Screen = [MyHomePage(title: 'App  mobile') ,WalletPage(title: 'App  mobile'), LocationPage(title: 'App  mobile') ,ProfilePage(title: 'App  mobile')];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Screen[index_color],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 0;
                  });
                },
                child: Icon(
                  Icons.account_balance_outlined,
                  size: 30,
                  color: index_color == 0 ? Color(0xff0c355f): Colors.grey,
                ),
              ),



              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 1;
                  });
                },
                child: Icon(
                  Icons.credit_card,
                  size: 30,
                  color: index_color == 1 ? Color(0xff0c355f): Colors.grey,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 2;
                  });
                },
                child: Icon(
                  Icons.location_on,
                  size: 30,
                  color: index_color == 2 ? Color(0xff0c355f): Colors.grey,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 3;
                  });
                },
                child: Icon(
                  Icons.person_outlined,
                  size: 30,
                  color: index_color == 3 ? Color(0xff0c355f): Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
