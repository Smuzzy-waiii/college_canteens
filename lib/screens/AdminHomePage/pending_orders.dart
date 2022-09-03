import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PendingOrders extends StatefulWidget {
  const PendingOrders({Key? key}) : super(key: key);

  @override
  _PendingOrdersState createState() => _PendingOrdersState();
}

class _PendingOrdersState extends State<PendingOrders>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //Keeps Widget Alive

  final Stream<QuerySnapshot<Map<String, dynamic>>> ordersStream =
      FirebaseFirestore.instance
          .collection('Colleges/PES - RR/Canteens/13th Floor Canteen/Orders')
          .where("isServed", isEqualTo: false)
          .orderBy("timestamp", descending: true)
          .snapshots();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ordersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final orders = snapshot.requireData.docs;

          return orders.isEmpty
              ? Center(child: Text("No Pending Orders"))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    Map items = order['items'];
                    return Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Card(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${order['user']} - Rs ${order['price']}\n"),
                                  const Text("Orders:"),
                                  for (var key in items.keys)
                                    Text(
                                        "$key - ${items[key]['quantity'].toString()}")
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 30,
                                ),
                                onPressed: () async {
                                  DocumentReference doc =
                                      FirebaseFirestore.instance.doc(
                                          "Colleges/PES - RR/Canteens/13th Floor Canteen/Orders/${order.id}");
                                  doc.update({"isServed": true});
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
        });
  }
}
