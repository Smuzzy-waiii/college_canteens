import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .doc('Users/${widget.username}')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final usrdata = snapshot.data!.data();

          return Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(20),
            child: Card(
              color: Colors.blue,
              child: Container(
                  height: 200,
                  width: double.infinity,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Wallet",
                        style: TextStyle(color: Colors.black54, fontSize: 20),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Rs ${usrdata!['Balance']}",
                        style: TextStyle(fontSize: 40),
                      ),
                    ],
                  ))),
            ),
          );
        });
  }
}
