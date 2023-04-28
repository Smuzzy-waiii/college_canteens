import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class ServedOrders extends StatefulWidget {
  const ServedOrders({Key? key}) : super(key: key);

  @override
  _ServedOrdersState createState() => _ServedOrdersState();
}

class _ServedOrdersState extends State<ServedOrders>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //Keeps Widget Alive

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PaginateFirestore(
      query: FirebaseFirestore.instance
          .collection('Colleges/PES - RR/Canteens/13th Floor Canteen/Orders')
          .where("isServed", isEqualTo: true)
          .orderBy("timestamp", descending: true),
      itemBuilderType: PaginateBuilderType.listView,
      isLive: true,
      itemBuilder: (index, context, snapshot) {
        DocumentSnapshot order = snapshot as DocumentSnapshot<Object?>;
        Map items = order['items'];

        return Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Card(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${order['user']} - Rs ${order['price']}\n"),
                  Text("Orders:"),
                  for (var key in items.keys)
                    Text("$key - ${items[key]['quantity'].toString()}"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
