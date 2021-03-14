import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:rxdart/subjects.dart';

//Hello world
//add this to git
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
  double percentUpload = 0.0;
  var percentUploadSubject = BehaviorSubject<double>();

  @override
  dispose() {
    super.dispose();
    percentUploadSubject.close();
  }

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

  testingPercentUpload(num maxkb, num transferedByte) {
    percentUpload = (transferedByte / maxkb);
    percentUploadSubject.add(percentUpload);
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    setState(() {
      if (pickedFile != null) {
        //create file where the photo path is stored
        percentUpload = 0;
        _image = File(pickedFile.path);
        FirebaseStorage.instance
            .ref(
                'images/${p.basename(_image.path).replaceAll('image_picker', '')}')
            .putFile(_image)
            .snapshotEvents
            .listen((event) {
          if (event.state == TaskState.running) {
            testingPercentUpload(event.totalBytes, event.bytesTransferred);
          }
          if (event.state == TaskState.error) {
            print("Can not upload image");
          }

          if (event.state == TaskState.success) {
            //retrieve uploaded image url
            //TODO: take this url to store in collection
            event.ref.getDownloadURL().then((value) => print(value));
          }
        });
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => getImage(ImageSource.camera),
      //   child: Icon(Icons.camera_alt_outlined),
      // ),
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
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (_) {
                          return Container(
                            height: 100,
                            child: Column(
                              children: [
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    getImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 20),
                                      Icon(Icons.photo),
                                      SizedBox(width: 20),
                                      Text('Gallery')
                                    ],
                                  ),
                                )),
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    getImage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 20),
                                      Icon(Icons.camera_alt),
                                      SizedBox(width: 20),
                                      Text('Camera')
                                    ],
                                  ),
                                ))
                              ],
                            ),
                          );
                        });
                  },
                  child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Colors.white,
                          boxShadow: [],
                          image: _image == null
                              ? null
                              : DecorationImage(
                                  fit: BoxFit.cover,
                                  // colorFilter: ColorFilter.mode(Colors.red, BlendMode.color),
                                  image: FileImage(_image))),
                      child: StreamBuilder(
                        initialData: 0.0,
                        stream: percentUploadSubject.stream,
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          return snapshot.data == 0
                              ? Container()
                              : new CircularPercentIndicator(
                                  radius: 100.0,
                                  lineWidth: 10.0,
                                  percent: snapshot.data,
                                  backgroundColor: Colors.grey,
                                  progressColor: Colors.blue,
                                );
                        },
                      )),
                )
              ],
            ),
            SizedBox(
              height: 50,
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
