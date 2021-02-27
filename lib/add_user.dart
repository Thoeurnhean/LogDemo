import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddUser extends StatefulWidget {
  final String docId;

  const AddUser({Key key, this.docId}) : super(key: key);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController age = TextEditingController();
  bool isValidate = false;
  CollectionReference colRef = FirebaseFirestore.instance.collection('user');
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  _addDoc() {
    Map<String, dynamic> doc = {
      "name": username.text.trim(),
      "age": age.text.trim()
    };
    colRef.add(doc).then((val) {
      print(val);
    });
  }

  _handleEdit() {
    Map<String, dynamic> doc = {
      "name": username.text.trim(),
      "age": age.text.trim()
    };
    colRef.doc(widget.docId).update(doc).then((val) {
      print('success update');
    });
  }

  File _image;
  final picker = ImagePicker();

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    setState(() {
      if (pickedFile != null) {
        //create file where the photo path is stored
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    if (widget.docId != null) {
      colRef.doc(widget.docId).get().then((doc) {
        if (doc.exists) {
          username.text = doc.data()['name'];
          age.text = doc.data()['age'];
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      floatingActionButton: FloatingActionButton(
        onPressed: () => getImage(ImageSource.camera),
        child: Icon(Icons.camera_alt_outlined),
      ),
      appBar: AppBar(
        title: Text("Add user"),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: () {
          var currentState = _formKey.currentState;
          if (currentState.validate()) {
            setState(() {
              isValidate = true;
            });
          } else {
            setState(() {
              isValidate = false;
            });
          }
        },
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: Colors.blue,
                      image: _image == null ? null : DecorationImage(
                        fit: BoxFit.cover,
                        // colorFilter: ColorFilter.mode(Colors.red, BlendMode.color),
                        image: FileImage(_image)
                      )
                    ),

                  )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              validator: (val) {
                if (val.isNotEmpty && val.length > 0) {
                  return null;
                }

                return "Username is required";
              },
              controller: username,
              decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              validator: (val) {
                if (val.isNotEmpty && val.length > 0) {
                  return null;
                }

                return "Age is required";
              },
              controller: age,
              decoration: InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  )),
            ),
            OutlineButton(
              onPressed: !isValidate
                  ? null
                  : widget.docId != null
                      ? _handleEdit
                      : _addDoc,
              child: Text("Save user"),
            )
          ],
        ),
      ),
    );
  }
}
