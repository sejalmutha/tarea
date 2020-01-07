import 'package:flutter/material.dart';
import 'package:task_manager/authentication.dart';
import 'package:task_manager/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/super_admin/new_client.dart';
import 'package:task_manager/super_admin/update_client.dart';
import 'package:task_manager/locales/locale.dart';
import 'package:task_manager/super_admin/geo_fence.dart';

class Client extends StatefulWidget {
  Client({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  @override
  _ClientState createState() => _ClientState();
}

class _ClientState extends State<Client> {
  String uid = '';
  getUid() {}
  final snackBar = SnackBar(content: Text('Deleted successfully'));

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

  navigateToNewClient() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => NewClient(
                auth: widget.auth,
                onSignedOut: widget.onSignedOut,
                role: 'su')));
  }

  updateData(String name) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => UpdateClient(title: name)));
  }

  deleteData(String id) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentReference reference =
          Firestore.instance.collection('Clients').document(id);
      await transaction.get(reference);

      await reference.delete();

      DocumentReference reference1 =
          Firestore.instance.collection('UserRoles').document(id);
      await transaction.get(reference1);

      await reference1.delete();
    });
    print('Deleted successfully');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(DemoLocalizations.of(context).cTitle),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.pinkAccent,
          Colors.orange,
        ], begin: Alignment.centerLeft, end: Alignment(0.8, 0.5))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: ListView(
                //mainAxisAlignment: MainAxisAlignment.start,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  //new Container(
                  //child:
                  StreamBuilder(
                      stream:
                          Firestore.instance.collection('Clients').snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) return const Text('Loading...');
                        return new ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            String docid = document.documentID;
                            return Dismissible(
                              key: Key(docid),
                              onDismissed: (direction) async {
                                deleteData(docid);
                                Scaffold.of(context).showSnackBar(snackBar);
                              },
                              child: Card(
                                child: new ListTile(
                                  title: new Text(
                                    document['Name'],
                                  ),
                                  /*onTap: () {
                                      updateData(docid);
                                    },*/
                                  //subtitle: new Text(document['author']),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                  //),
                  SizedBox(
                    height: 50.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        child: Text(
                          DemoLocalizations.of(context).addButton,
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: navigateToNewClient,
                        color: Colors.orangeAccent,
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      RaisedButton(
                        child: Text(
                          'Maps',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GeoFence(
                                      auth: widget.auth,
                                      onSignedOut: widget.onSignedOut,
                                    ))),
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text('Swipe left to delete'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.call_made),
        label: Text(DemoLocalizations.of(context).signOutButton),
        onPressed: _signOut,
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

/*

FutureBuilder(builder: (context, snapshot) {
future:
_getClients();
if (snapshot.connectionState == ConnectionState.waiting) {
return Center(
child: Text('Loading...'),
);
}
return ListView.builder(
//itemCount: snapshot.data.length,
itemBuilder: (context, index) {
return ListTile(
title: Text(snapshot.data[index].data["Name"]),
);
});
}),*/
