import 'package:flutter/material.dart';
import 'package:task_manager/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/super_admin/clients.dart';
import 'package:task_manager/locales/locale.dart';
import 'package:task_manager/client/admin.dart';

class NewClient extends StatefulWidget {
  NewClient({this.auth, this.onSignedOut, this.role, this.title});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String role;
  final String title;
  @override
  _NewClientState createState() => _NewClientState();
}

class _NewClientState extends State<NewClient> {
  final _formKey = new GlobalKey<FormState>();
  String _email, _password, _name;
  String uid = '';

  @override
  void initState() {
    this.uid = "";
    widget.auth.currentUser().then((val) {
      setState(() {
        this.uid = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text('Client details'),
        backgroundColor: Colors.pink,
      ),*/
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.pinkAccent,
            Colors.orangeAccent,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      ListTile(
                        title: TextFormField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: DemoLocalizations.of(context).name,
                            labelStyle:
                                TextStyle(color: Colors.indigo, fontSize: 20),
                          ),
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          validator: (value) =>
                              value.isEmpty ? "Name can't empty" : null,
                          onSaved: (value) => _name = value,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      ListTile(
                        title: TextFormField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: DemoLocalizations.of(context).email,
                            labelStyle:
                                TextStyle(color: Colors.indigo, fontSize: 20),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          maxLines: 1,
                          validator: (value) => value.isEmpty
                              ? "Email Address can't empty"
                              : null,
                          onSaved: (value) => _email = value,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      ListTile(
                        title: TextFormField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.indigoAccent)),
                            labelText: DemoLocalizations.of(context).password,
                            labelStyle: TextStyle(
                                color: Colors.indigoAccent, fontSize: 20),
                          ),
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          maxLength: 10,
                          obscureText: true,
                          validator: (value) =>
                              value.isEmpty ? "Password can't be empty" : null,
                          onSaved: (value) => _password = value,
                        ),
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            child: Text(
                              DemoLocalizations.of(context).submitButton,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            color: Colors.pink,
                            onPressed: _sendToServer,
                          ),
                          SizedBox(
                            width: 50,
                          ),
                          RaisedButton(
                              child: Text(
                                DemoLocalizations.of(context).backButton,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              color: Colors.pink,
                              onPressed: () {
                                if(widget.role=='su') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Client(
                                            auth: widget.auth,
                                            onSignedOut: widget.onSignedOut,
                                          )));
                                }
                                else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AdminPage(
                                            auth: widget.auth,
                                            onSignedOut: widget.onSignedOut,
                                            title: widget.title,
                                          )));
                                }

                              })
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  _sendToServer() {
    print(widget.auth.currentUser());
    if (_formKey.currentState.validate()) {
      //No error in validator
      _formKey.currentState.save();
      if (widget.role == 'su') {
        Firestore.instance.runTransaction((Transaction transaction) async {
          print('create doc');
          DocumentReference ref =
              Firestore.instance.collection('Clients').document(_name);
          await transaction.get(ref);

          await ref.setData({
            "Name": "$_name",
            "Email": "$_email",
            "Password": "$_password",
            "CurrentDateAndTime": DateTime.now(),
            "status": "new"
          });
        });
      } else {
        Firestore.instance.runTransaction((Transaction transaction) async {
          DocumentReference reference =
              Firestore.instance.collection('Users').document(_name);
          await transaction.get(reference);

          await reference.setData({
            "Name": "$_name",
            "Email": "$_email",
            "Password": "$_password",
            "status": "new",
            "clientName": widget.title
          });
        });
      }
      print("Added successfully");
      registerUser();
    }
  }

  registerUser() async {
    print('create email');
    String userId =
        await widget.auth.createUserWithEmailAndPassword(_email, _password);
    if (_formKey.currentState.validate()) {
      //No error in validator
      _formKey.currentState.save();
      if (widget.role == 'su') {
        Firestore.instance.runTransaction((Transaction transaction) async {
          DocumentReference reference =
              Firestore.instance.collection('UserRoles').document(_name);
          await transaction.get(reference);
          await reference
              .setData({"userid": "$userId", "role": "admin", "status": "new"});
        });

        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Client(
                      auth: widget.auth,
                      onSignedOut: widget.onSignedOut,
                    )));
      } else {
        Firestore.instance.runTransaction((Transaction transaction) async {
          DocumentReference reference =
              Firestore.instance.collection('UserRoles').document(_name);
          await transaction.get(reference);

          await reference
              .setData({"userid": "$userId", "role": "user", "status": "new"});
        });
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdminPage(
                      auth: widget.auth,
                      onSignedOut: widget.onSignedOut,
                      title: widget.title,
                    )));
      }
    }
  }
}
