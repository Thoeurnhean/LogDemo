import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<String> selectedIds  = [];
  CollectionReference col =  FirebaseFirestore.instance.collection('user');
  Widget toggleActive(docId) {
      if(selectedIds.contains(docId)) {
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
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return AddUser();
            }));
          }
        ),
        appBar: AppBar(
          leading: isEditMode ? IconButton(icon: Icon(Icons.close), onPressed: (){
            setState(() {
              selectedIds = [];
              isEditMode = false;
            });
          }) : null,
          backgroundColor: Colors.orange,actions: [
           isEditMode ? IconButton(icon: Icon(Icons.delete), onPressed: _handleRemove) : Container(),
           !isEditMode ? Container() :  selectedIds.length == 1 ? IconButton(icon: Icon(Icons.edit), onPressed: (){}) : Container()
        ],),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('user').snapshots(),
          builder: (context, snapshot) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, indext) {
                var doc = snapshot.data.docs[indext];

                return Column(
                  children: [
                    InkWell(
                      onTap: !isEditMode ? null : () {
                        setState(() {
                          if(selectedIds.contains(doc.id)){
                             selectedIds.remove(doc.id);
                             if(selectedIds.length == 0 ) {
                               isEditMode = false;
                             }
                          }else{
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
                        leading: isEditMode ? selectedIds.contains(doc.id) ?Icon(Icons.check_circle) : Icon(CupertinoIcons.circle) : null,
                        title: Text(doc['name']),
                        subtitle: Text(doc['age']),
                      ),
                    ),
                    Divider()
                  ],
                );
              },
            );
          },
        ));
  }
}
