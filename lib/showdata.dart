import 'package:flutter/material.dart';

class Showdata extends StatefulWidget {
  @override
  _ShowdataState createState() => _ShowdataState();
}

class _ShowdataState extends State<Showdata> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                Spacer(),
                Text(
                  'Information',
                  style: TextStyle(
                      color: Colors.white, fontSize: 20, letterSpacing: 2),
                ),
                Spacer(),
                Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 50,
                    spreadRadius: 10,
                    offset: Offset(10,10),
                    color: Colors.grey.withOpacity(0.5)
                  )
                ],
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/images/facebook.png'))),
            )
          ],
        ),
      ),
    );
  }
}
