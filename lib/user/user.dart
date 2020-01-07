import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/authentication.dart';
import 'package:task_manager/login_page.dart';
import 'package:task_manager/user/new_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/user/camera_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Task {
  Task({this.id, this.name});
  String id;
  String name;
}

class UserPage extends StatefulWidget {
  UserPage({this.auth, this.onSignedOut, this.title, this.camera});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String title;
  final CameraDescription camera;
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String userid = '';
  getUid() {}
  String _location, _area, _type;
  List<Task> sub = <Task>[];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final snackBar = SnackBar(content: Text('Good Work!!'));
  final snackBar1 = SnackBar(content: Text('Please complete all the tasks!'));
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    this.userid = "";
    widget.auth.currentUser().then((val) {
      setState(() {
        this.userid = val;
      });
    });
    getName();
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

  getName() async {
    print('Name');
    DocumentReference documentReference =
        Firestore.instance.collection('Users').document(widget.title);
    await documentReference.get().then((datasnapshot) {
      setState(() {
        _location = datasnapshot.data['task'];
      });
    });
    List<String> areaType = _location.split(':');
    _area = areaType[0];
    _type = areaType[1];
  }

  Widget _getTile() {

    return StreamBuilder(
        stream: Firestore.instance
            .collection('TaskList')
            .document(_area)
            .collection(_type)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          sub.clear();
          print(sub.toString());
          print('Stream');
          if (!snapshot.hasData) return const Text('Loading...');
          if (snapshot.hasData) {
            snapshot.data.documents.forEach((doc) {
              print("${doc.data['taskName']}");
              Task task = Task(id: doc.documentID, name: doc.data['taskName']);
              sub.add(task);
            });
            print(sub.toString());
            return Scrollbar(
              child: Card(
                child: ExpansionTile(
                  title: Text(
                    _area,
                    style: TextStyle(fontSize: 18.0),
                  ),
                  children: sub
                      .map(
                        (val) => Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          child: Container(
                            child: new ListTile(
                              title: Text(val.name),
                            ),
                          ),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                                caption: 'Done',
                                color: Colors.red,
                                icon: Icons.done,
                                onTap: () {}),
                            IconSlideAction(
                              caption: 'Take picture',
                              color: Colors.orange,
                              icon: Icons.camera,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CameraPage(
                                            camera: widget.camera,
                                            auth: widget.auth,
                                            onSignedOut: widget.onSignedOut,
                                          ))),
                            ),
                            IconSlideAction(
                                caption: 'Notes',
                                color: Colors.pink,
                                icon: Icons.description,
                                onTap: () {
                                  _addNotes(val.id);
                                })
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            );
          }
          return SizedBox(
            height: 10.0,
          );
        });
  }

  _addNotes(String id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Notes'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Add description"),
              maxLines: 3,
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text('Submit'),
                  onPressed: () {
                    Firestore.instance
                        .runTransaction((Transaction transaction) async {
                      DocumentReference reference = Firestore.instance
                          .collection('TaskList')
                          .document(_area)
                          .collection(_type)
                          .document(id);
                      await transaction.get(reference);

                      await reference.updateData({
                        "description": "${_textFieldController.text}",
                      });
                    });
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.call_made),
              tooltip: 'Sign Out',
              onPressed: _signOut),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.pinkAccent,
          Colors.orange,
        ], begin: Alignment.centerLeft, end: Alignment(0.8, 0.5))),
        child: Column(
          children: <Widget>[
            _getTile(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text(
                    'Create task',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewTaskPage(
                                auth: widget.auth,
                                onSignedOut: widget.onSignedOut,
                                title: widget.title)));
                  },
                ),
                SizedBox(
                  width: 20.0,
                ),
                RaisedButton(
                  child:
                      Text('Completed?', style: TextStyle(color: Colors.white)),
                  color: Colors.red,
                  onPressed: () {
                    _showAlertDialog();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _showAlertDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Have all the tasks been completed?'),
            actions: <Widget>[
              FlatButton(child: Text('Yes'), onPressed: _completed),
              FlatButton(child: Text('No'), onPressed: _notCompleted)
            ],
          );
        });
  }

  _completed() {
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentReference reference =
          Firestore.instance.collection('Users').document(widget.title);
      await transaction.get(reference);

      await reference.updateData({
        "CompletedDateAndTime": DateTime.now(),
      });
    });

    _scaffoldKey.currentState.showSnackBar(snackBar);
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CameraPage(
                  camera: widget.camera,
                  auth: widget.auth,
                  onSignedOut: widget.onSignedOut,
                )));
  }

  _notCompleted() {
    _scaffoldKey.currentState.showSnackBar(snackBar1);
    Navigator.pop(context);
  }
}
