import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loginMemo/add_user.dart';
import 'package:loginMemo/showdata.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isEditMode = false;
  List<String> selectedIds = [];
  CollectionReference col = FirebaseFirestore.instance.collection('user');

  Widget toggleActive(docId) {
    if (selectedIds.contains(docId)) {
      return Icon(CupertinoIcons.check_mark_circled_solid);
    }
    return Icon(CupertinoIcons.circle);
  }

  _handleRemove() {
    selectedIds.forEach((id) {
      col.doc(id).delete();
    });
    setState(() {
      isEditMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    return Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AddUser();
          }));
        }),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("${user.uid}"),
                accountEmail: Text("${user.email}"),
              ),
              ListTile(
                title: Text("Logout"),
                onTap: () => FirebaseAuth.instance.signOut(),
              )
            ],
          ),
        ),
        appBar: AppBar(
          leading: isEditMode
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      selectedIds = [];
                      isEditMode = false;
                    });
                  })
              : null,
          backgroundColor: Colors.orange,
          actions: [
            isEditMode
                ? IconButton(icon: Icon(Icons.delete), onPressed: _handleRemove)
                : Container(),
            !isEditMode
                ? Container()
                : selectedIds.length == 1
                    ? IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AddUser(
                                        docId: selectedIds[0],
                                      )));
                        })
                    : Container(),
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(data: [
                        {"name": "lywat"},
                        {"name": "kevin"}
                      ]));
                },
                icon: Icon(Icons.search))
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('user').snapshots(),
          builder: (context, snapshot) {
            return ListView.builder(
              itemCount: snapshot.hasData ? snapshot.data.docs.length : 0,
              itemBuilder: (context, indext) {
                if (snapshot.hasData) {
                  var doc = snapshot.data.docs[indext];

                  return Column(
                    children: [
                      InkWell(
                        onTap: !isEditMode
                            ? null
                            : () {
                                setState(() {
                                  if (selectedIds.contains(doc.id)) {
                                    selectedIds.remove(doc.id);
                                    if (selectedIds.length == 0) {
                                      isEditMode = false;
                                    }
                                  } else {
                                    selectedIds.add(doc.id);
                                  }
                                });
                              },
                        onLongPress: () {
                          setState(() {
                            isEditMode = true;
                            selectedIds.add(doc.id);
                          });
                        },
                        child: ListTile(
                          leading: isEditMode
                              ? selectedIds.contains(doc.id)
                                  ? Icon(Icons.check_circle)
                                  : Icon(CupertinoIcons.circle)
                              : null,
                          title: Text(doc['name']),
                          subtitle: Text(doc['age']),
                        ),
                      ),
                      Divider()
                    ],
                  );
                }
                return Container();
              },
            );
          },
        ));
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Map> data;

  CustomSearchDelegate({this.data});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.search), onPressed: () => showResults(context)),
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('user');
    return FutureBuilder(
      initialData: null,
      future: users.where('name', isGreaterThanOrEqualTo: query).get(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        var data = snapshot.data;
        return data == null
            ? "No result found"
            : ListView(
                children: List.generate(data.docs.length, (index) {
                  QueryDocumentSnapshot doc = data.docs[index];
                  return ListTile(
                    title: Text("${doc.data()['name']}"),
                  );
                }),
              );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map> filterData = data
        .where((element) =>
            element['name'].toLowerCase().toString().startsWith(query))
        .toList();
    return ListView(
      children: List.generate(filterData.length, (index) {
        Map map = filterData[index];
        return ListTile(
          onTap: () {
            query = map['name'];
            showResults(context);
          },
          title: Text("${map['name']}"),
        );
      }),
    );
  }
}
