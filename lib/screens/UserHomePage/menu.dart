import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'dart:core';
import 'package:uuid/uuid.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key, required this.usrdata}) : super(key: key);
  final Map usrdata;

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  //Razorpay stuff
  Razorpay razorpay = Razorpay();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerError);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_3zZaRWFALdsXve",
      "amount": subtotal * 100,
      "name": "Sample App",
      "description": "Payment for the product",
      "prefill": {
        "contact": "8618950413", //"9513388379",
        "email": "smaran.jawalkar@gmail.com",
      },
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void handlerError(PaymentFailureResponse response) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Payment failed"),
            content: Text("Transaction failed. Please try again"),
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
    print('Payment error');
  }

  void handlerExternalWallet(ExternalWalletResponse response) {
    print('External Wallet');
  }

  //Actual product stuff
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
                                      return;
                                    }
                                    openCheckout();
                                  }),
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

  void handlerPaymentSuccess(PaymentSuccessResponse response) {
    String username = widget.usrdata['username'];
    var collection = FirebaseFirestore.instance
        .collection('Colleges/PES - RR/Canteens/13th Floor Canteen/Orders');
    var uuid = Uuid();
    var ord_id = uuid.v4().toString();
    DateTime now = DateTime.now();
    collection.doc(ord_id).set({
      "user": username,
      "price": subtotal,
      "items": cart,
      "timestamp": now,
      "isServed": false,
      "transaction_details": {
        "razorpay_payment_id": response.paymentId,
        "razorpay_order_id": response.orderId,
        "razorpay_signature": response.signature
      }
    });

    showDialog(
        context: context,
        builder: (context) {
          List<Widget> wlist = [];
          cart.keys.toList().forEach((key) {
            wlist.add(Text("${key} - ${cart[key]['quantity'].toString()}"));
          });
          return AlertDialog(
            title: Text("Order Confirmed!"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
        }).then((value) {
      setState(() {
        subtotal = 0;
        cart = {};
      });
    });
  }
}
