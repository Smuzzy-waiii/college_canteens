import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'UserHomePage/menu.dart';
import 'UserHomePage/wallet.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key, required this.usrdata}) : super(key: key);
  final Map usrdata;

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  int currIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bolt Snack"),
        actions: [
          TextButton(
            child: Text(
              "Sign Out",
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () async {
              await _auth.signOut();
              Navigator.popAndPushNamed(context, '/auth');
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Offstage(
            offstage: currIndex != 0,
            child: Menu(
              usrdata: widget.usrdata,
            ),
          ),
          Offstage(
            offstage: currIndex != 1,
            child: Wallet(
              username: widget.usrdata['username'],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen,
        selectedItemColor: Colors.black,
        currentIndex: currIndex,
        onTap: (int index) => setState(() {
          currIndex = index;
        }),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: "Order"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: "Wallet")
        ],
      ),
    );
  }
}
