import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController username  = TextEditingController();
  TextEditingController age = TextEditingController();
  bool isValidate = false;
  CollectionReference colRef = FirebaseFirestore.instance.collection('user');
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
 _addDoc () {
      Map<String , dynamic> doc = {
        "name": username.text.trim(),
        "age": age.text.trim()
      };
      colRef
          .add(doc).then((doc) {
            print(doc);

      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Add user"),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: () {
          var currentState = _formKey.currentState;
          if(currentState.validate()) {
            setState(() {
              isValidate = true;
            });
          }else{
            setState(() {
              isValidate = false;
            });
          }
        },
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          children: [
              TextFormField(
                validator: (val) {
                  if(val.isNotEmpty && val.length > 0) {
                    return null;
                  }

                  return "Username is required";
                },
                controller: username,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),

                    )
                  ),
              ),
            SizedBox(height: 10,),
            TextFormField(
              validator: (val) {
                if(val.isNotEmpty && val.length > 0) {
                  return null;
                }

                return "Age is required";
              },
              controller: age,
              decoration: InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),

                  )
              ),
            ),
            OutlineButton(onPressed: !isValidate ? null :_addDoc,child: Text("Save user"),)
          ],
        ),
      ),
    );
  }
}
