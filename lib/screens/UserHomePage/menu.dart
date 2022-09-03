import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:core';
import 'package:uuid/uuid.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key, required this.usrdata}) : super(key: key);
  final Map usrdata;

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final Stream<DocumentSnapshot<Map<String, dynamic>>> menuItems =
      FirebaseFirestore.instance
          .doc('Colleges/PES - RR/Canteens/13th Floor Canteen')
          .snapshots();
  Map cart = {};
  int subtotal = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: menuItems,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData.get('Menu');
          Map<String, dynamic> menu = Map<String, dynamic>.from(data);
          Map<String, dynamic> submenu = {};
          for (var item in menu.keys) {
            if (menu[item]['isAvailable']) {
              submenu[item] = menu[item];
            }
          }
          menu = submenu;

          return Column(
            children: [
              Expanded(
                flex: 10,
                child: ListView.builder(
                  itemCount: menu.length,
                  itemBuilder: (context, index) {
                    String key = menu.keys.toList()[index];
                    int count = 0;
                    return Container(
                      height: 60,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Card(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Text("${key.toString()} x" +
                                  (cart[key] == null
                                          ? 0
                                          : cart[key]['quantity'])
                                      .toString()),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Rs ${menu[key]['Price'].toString()}"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.add),
                                      iconSize: 20,
                                      color: Colors.orange,
                                      onPressed: () {
                                        setState(() {
                                          if (cart[key] == null) {
                                            cart[key] = {
                                              "quantity": 1,
                                              "price":
                                                  menu[key]['Price'] as int,
                                              "total_price":
                                                  menu[key]['Price'] as int
                                            };
                                          } else {
                                            cart[key] = {
                                              "quantity":
                                                  cart[key]["quantity"] + 1,
                                              "price":
                                                  menu[key]['Price'] as int,
                                              "total_price":
                                                  (cart[key]["quantity"] + 1) *
                                                      menu[key]['Price'] as int
                                            };
                                          }
                                          subtotal += menu[key]["Price"] as int;
                                        });
                                      }),
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    iconSize: 20,
                                    color: Colors.orange,
                                    onPressed: () {
                                      if (cart[key] == null) {
                                        return;
                                      }
                                      if (cart[key]['quantity'] == 0) {
                                        return;
                                      }
                                      if (cart[key]['quantity'] == 1) {
                                        setState(() {
                                          cart.remove(key);
                                          subtotal -= menu[key]['Price'] as int;
                                        });
                                        return;
                                      }
                                      setState(() {
                                        cart[key] = {
                                          "quantity": cart[key]["quantity"] - 1,
                                          "price": menu[key]['Price'] as int,
                                          "total_price":
                                              (cart[key]["quantity"] + 1) *
                                                  menu[key]['Price'] as int
                                        };
                                        subtotal -= menu[key]['Price'] as int;
                                      });
                                    },
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      )),
                    );
                  },
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Card(
                      color: Colors.lime[300],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Text("Subtotal: Rs ${subtotal}"),
                            ],
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                child: Text("Pay"),
                                onPressed: () async {
                                  String username = widget.usrdata['username'];
                                  var event = await FirebaseFirestore.instance
                                      .doc('Users/$username')
                                      .get();
                                  Map<String, dynamic> user =
                                      event.data() as Map<String, dynamic>;
                                  int balance = user['Balance'];

                                  if (subtotal == 0) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Cart Empty"),
                                            content: const Text(
                                                "Cart is Empty. Please Add items to cart"),
                                            actions: [
                                              TextButton(
                                                child: const Text("OK"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  } else if (balance < subtotal) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Alert"),
                                            content: const Text(
                                                "Insuffient balance. Please Recharge Wallet"),
                                            actions: [
                                              TextButton(
                                                child: const Text("OK"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  } else {
                                    var collection = FirebaseFirestore.instance
                                        .collection(
                                            'Colleges/PES - RR/Canteens/13th Floor Canteen/Orders');
                                    var uuid = Uuid();
                                    var ord_id = uuid.v4().toString();
                                    DateTime now = DateTime.now();
                                    collection.doc(ord_id).set({
                                      "user": username,
                                      "price": subtotal,
                                      "items": cart,
                                      "timestamp": now,
                                      "isServed": false
                                    });

                                    await showDialog(
                                        context: context,
                                        builder: (context) {
                                          List<Widget> wlist = [];
                                          cart.keys.toList().forEach((key) {
                                            wlist.add(Text(
                                                "${key} - ${cart[key]['quantity'].toString()}"));
                                          });
                                          return AlertDialog(
                                            title: Text("Order Confirmed!"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Order Id: ${ord_id}\n"),
                                                Text("Order:"),
                                                ...wlist
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text("OK"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });
                                    setState(() {
                                      subtotal = 0;
                                      cart = {};
                                    });
                                  }
                                },
                              ),
                              SizedBox(
                                width: 20,
                              )
                            ],
                          )
                        ],
                      )),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
