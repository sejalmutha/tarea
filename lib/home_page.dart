import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/super_admin/clients.dart';
import 'package:task_manager/client/admin.dart';
import 'package:task_manager/super_admin/update_client.dart';
import 'dart:async';
import 'package:task_manager/login_page.dart';
import 'package:task_manager/locales/locale.dart';
import 'package:task_manager/user/user.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignedOut, this.camera});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final CameraDescription camera;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final documentReference =
      Firestore.instance.collection("UserRoles");
  String role;
  String userid = '';
  StreamSubscription<QuerySnapshot> snapshots;
  getUid() {}

  @override
  void initState() {

    this.userid = "";
    widget.auth.currentUser().then((val) {
      setState(() {
        this.userid = val;
      });
    });
    super.initState();
  }

  void _navigate() {
    snapshots = documentReference
        .where("userid", isEqualTo: this.userid)
        .snapshots()
        .listen((querySnapshot) {
      querySnapshot.documents.forEach((doc) {
        String role = doc.data['role'];
        String _status = doc.data['status'];
        print(_status);
        print(role);
        if (role == 'super admin') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Client(
                        auth: widget.auth,
                        onSignedOut: widget.onSignedOut,
                      )));
        } else if (role == 'admin') {
          if (doc.data['status'] == 'new') {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdateClient(
                          auth: widget.auth,
                          onSignedOut: widget.onSignedOut,
                          title: doc.documentID,
                        )));
          } else {
            Route route = MaterialPageRoute(
                builder: (context) => AdminPage(
                      auth: widget.auth,
                      onSignedOut: widget.onSignedOut,
                      title: doc.documentID,
                    ));

            Navigator.pushReplacement(context, route);
          }
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => UserPage(
                        auth: widget.auth,
                        onSignedOut: widget.onSignedOut,
                    title: doc.documentID,
                    camera: widget.camera
                      )));
        }
      });
    });
  }

  void _signOut() async {
    try {
      await widget.auth.signOut1();
      widget.onSignedOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      print("Error: $e");
    }
  }

   @override
  void dispose() {
    snapshots.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Locale myLocale = Localizations.localeOf(context);
    return Scaffold(
      /* appBar: AppBar(
        title: Text("Home page"),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),*/
//        \n$uid
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.pinkAccent,
          Colors.orange,
        ], begin: Alignment.centerLeft, end: Alignment(0.8, 0.5))),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                DemoLocalizations.of(context).title,
                style: TextStyle(
                    fontSize:
                        myLocale.languageCode.contains("en") ? 50.0 : 60.0,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 100,
              ),
              RaisedButton(
                child: Text(
                  DemoLocalizations.of(context).continueButton,
                  style: TextStyle(color: Colors.pink),
                ),
                onPressed: _navigate,
                //userObj.authorizeAdmin(context),
                color: Colors.white,
              ),
              SizedBox(
                height: 100,
              ),
              RaisedButton(
                child: Text(
                  DemoLocalizations.of(context).signOutButton,
                  style: TextStyle(color: Colors.pink),
                ),
                onPressed: _signOut,
                //userObj.authorizeAdmin(context),
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
