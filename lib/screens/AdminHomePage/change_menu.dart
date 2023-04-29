import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_canteens/shared/funcs.dart';
import 'package:flutter/material.dart';

class ChangeMenu extends StatefulWidget {
  const ChangeMenu({Key? key}) : super(key: key);

  @override
  _ChangeMenuState createState() => _ChangeMenuState();
}

class _ChangeMenuState extends State<ChangeMenu> {
  final DocumentReference<Map<String, dynamic>> canteen = FirebaseFirestore
      .instance
      .doc('Colleges/PES - RR/Canteens/13th Floor Canteen');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: canteen.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var data = snapshot.requireData.get("Menu");
          Map<String, dynamic> menu = Map<String, dynamic>.from(data);
          Map<String, dynamic> available_menu = {};
          Map<String, dynamic> unavailable_menu = {};
          for (var key in menu.keys) {
            if (menu[key]['isAvailable']) {
              available_menu[key] = menu[key];
            } else {
              unavailable_menu[key] = menu[key];
            }
          }
          menu = {
            ...available_menu,
            ...unavailable_menu,
          };
          return ListView.builder(
            itemCount: menu.length + 1,
            itemBuilder: (context, index) {
              if (index == menu.length) {
                return Container(
                  height: 60,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton.icon(
                        icon: Icon(Icons.add),
                        label: Text("Add an item"),
                        onPressed: () {},
                      ),
                    ),
                  ),
                );
              } else {
                String key = menu.keys.toList()[index];
                return Container(
                  height: 60,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  foregroundDecoration: menu[key]["isAvailable"]
                      ? null
                      : const BoxDecoration(
                          color: Colors.grey,
                          backgroundBlendMode: BlendMode.saturation,
                        ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(key),
                          Row(
                            children: [
                              Text("Rs ${menu[key]['Price']}"),
                              const SizedBox(
                                width: 5,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.lightGreen,
                                ),
                                onPressed: () {
                                  menu[key]['isAvailable'] =
                                  !menu[key]['isAvailable'];
                                  canteen.update({"Menu": menu});

                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  menu[key]["isAvailable"]
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.lightBlue,
                                ),
                                onPressed: () {
                                  menu[key]['isAvailable'] =
                                      !menu[key]['isAvailable'];
                                  canteen.update({"Menu": menu});
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        });
  }
}

/* 
IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Confirm Delete"),
                                        content: Text(
                                            "Are you sure you want to delete item: $key"),
                                        actions: [
                                          TextButton(
                                            child: Text("Yes"),
                                            onPressed: () async {
                                              menu.remove(key);
                                              await canteen
                                                  .update({"Menu": menu});
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text("No"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    });
                              },
                            )
*/