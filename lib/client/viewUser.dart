import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/authentication.dart';
import 'package:task_manager/super_admin/new_client.dart';

class UserView extends StatefulWidget {
  UserView({this.auth, this.onSignedOut, this.title});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String title;
  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  String uid = '';
  getUid() {}
  final snackBar = SnackBar(content: Text('Deleted successfully'));
  String _area, _type, _name;

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

  deleteData(String id) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentReference reference =
          Firestore.instance.collection('Users').document(id);
      await transaction.get(reference);

      await reference.delete();

      DocumentReference reference1 =
          Firestore.instance.collection('UserRoles').document(id);
      await transaction.get(reference1);

      await reference1.delete();
    });
    print('Deleted successfully');
  }

  navigateToNewClient() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => NewClient(
                auth: widget.auth,
                onSignedOut: widget.onSignedOut,
                role: 'ad',
                title: widget.title)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        padding: EdgeInsets.all(10.0),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Container(
            child: StreamBuilder(
                stream: Firestore.instance
                    .collection('Users')
                    .where("clientName", isEqualTo: widget.title)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return const Text('Loading...');
                  return new ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children:
                        snapshot.data.documents.map((DocumentSnapshot document) {
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
                            //onTap: _assignTask(document['Name']),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
          ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonTheme(
                minWidth: 50.0,
                child: RaisedButton(
                    padding: EdgeInsets.all(20.0),
                    color: Colors.orange,
                    child: Text(
                      'Add new user',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: navigateToNewClient),
              ),
              SizedBox(
                width: 20.0,
              ),
              RaisedButton(
                child: Text('Assign tasks',style: TextStyle(color: Colors.white),),
                padding: EdgeInsets.all(20.0),
                color: Colors.orange,
                onPressed: _assignTask,
              )
            ],
          )
        ],
      ),
    );
  }

  _assignTask() {

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(10.0),
            children: <Widget>[
              ListTile(
                title: TextField(
                  decoration: InputDecoration(labelText: 'Username'),
                  onChanged: (value) => _name = value,
                ),
              ),
              ListTile(
                title: TextField(
                  decoration: InputDecoration(labelText: 'Area'),
                  onChanged: (value) => _area = value,
                ),
              ),
              ListTile(
                title: TextField(
                  decoration: InputDecoration(labelText: 'Type'),
                  onChanged: (value) => _type = value,
                ),
              ),
              RaisedButton(
                child: Text('Submit'),
                  color: Colors.blue,
                  onPressed: () {
                _updateData();
                Navigator.pop(context);
              })
            ],
          );
        });
  }

  _updateData() {
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentReference reference =
      Firestore.instance.collection('Users').document(_name);
      await transaction.get(reference);

      await reference.updateData({
        "task" : "$_area:$_type"
      });
      print('task: $_area - $_type');
    });

    print("Updated successfully");
  }
}
