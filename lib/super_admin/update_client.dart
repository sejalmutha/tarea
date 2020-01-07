import 'package:flutter/material.dart';
import 'package:task_manager/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/client/admin.dart';
import 'package:task_manager/locales/locale.dart';

class UpdateClient extends StatefulWidget {
  UpdateClient({this.auth, this.onSignedOut, this.title});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String title;
  @override
  _UpdateClientState createState() => _UpdateClientState();
}

class _UpdateClientState extends State<UpdateClient> {
  final _formKey = new GlobalKey<FormState>();
  //String _name;
  String _phoneno;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.pinkAccent,
            Colors.orange,
          ], begin: Alignment.centerLeft, end: Alignment(0.8, 0.5))),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      ListTile(
                        title: TextFormField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: DemoLocalizations.of(context).phoneNo,
                            labelStyle:
                                TextStyle(color: Colors.black, fontSize: 20),
                          ),
                          keyboardType: TextInputType.phone,
                          maxLines: 1,
                          validator: (value) =>
                              value.isEmpty ? "Phone no. can't empty" : null,
                          onSaved: (value) => _phoneno = value,
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton(
                        child: Text(
                          DemoLocalizations.of(context).submitButton,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Colors.pink,
                        onPressed: _updateData,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  _updateData() {
    //String ph= _phoneno.toString()
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentReference reference =
          Firestore.instance.collection('Clients').document(widget.title);
      await transaction.get(reference);

      await reference.updateData({
        "PhoneNumber": "$_phoneno",
        "UpdateDateAndTime": DateTime.now(),
        "status": "old"
      });

      DocumentReference reference1 =
      Firestore.instance.collection('UserRoles').document(widget.title);
      await transaction.get(reference1);

      await reference1.updateData({"status": "old"});
    });

    print("Updated successfully");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AdminPage(
                  auth: widget.auth,
                  onSignedOut: widget.onSignedOut,
              title: widget.title,
                )));
  }
}
