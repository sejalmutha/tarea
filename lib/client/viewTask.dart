import 'package:flutter/material.dart';
import 'package:task_manager/client/admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/authentication.dart';

class TaskView extends StatefulWidget {
  TaskView({this.auth, this.title});
  final BaseAuth auth;
  final String title;
  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  deleteData(String id) {
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
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.pinkAccent,
          Colors.orange,
        ], begin: Alignment.centerLeft, end: Alignment(0.8, 0.5))),
        child: Column(
          children: <Widget>[
            new Container(
              child: StreamBuilder(
                  stream: Firestore.instance.collection('TaskList').snapshots(),
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
                          },
                          child: Card(
                            child: new ListTile(
                              trailing: Icon(Icons.arrow_forward),
                              title: new Text(docid),
                              onTap: () {
                                print('Error');
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ExpansionList(
                                            auth: widget.auth,
                                            title: widget.title,
                                            name: docid)));
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Swipe left to delete'),
          ],
        ),
      ),
    );
  }
}

class ExpansionList extends StatefulWidget {
  ExpansionList({this.auth, this.title, this.name});
  final BaseAuth auth;
  final String title;
  final String name;
  @override
  _ExpansionListState createState() => _ExpansionListState();
}

class _ExpansionListState extends State<ExpansionList> {
  List<String> subR = <String>[];
  List<String> subPr = <String>[];
  List<String> subPo = <String>[];

  Widget getRoutine() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('TaskList')
            .document(widget.name)
            .collection('Routine')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          if(snapshot.hasData) {
            snapshot.data.documents.forEach((doc) {
              subR.add(doc.data['taskName']);
            });
            return new ExpansionTile(
              title: Text('Routine'),
              children: subR
                  .map((val) => ListTile(
                title: Text(val),
              ))
                  .toList(),
            );
          }
          return SizedBox(height: 10.0,);
        });
  }

  Widget getPreFunction() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('TaskList')
            .document(widget.name)
            .collection('Pre-function')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          if(snapshot.hasData) {
            snapshot.data.documents.forEach((doc) {
              subPr.add(doc.data['taskName']);
            });
            return new ExpansionTile(
              title: Text('Pre-function'),
              children: subPr
                  .map((val) => ListTile(
                title: Text(val),
              ))
                  .toList(),
            );
          }
          return SizedBox(height: 10.0,);
        });
  }

  Widget getPostFunction() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('TaskList')
            .document(widget.name)
            .collection('Post-function')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          if(snapshot.hasData) {
            snapshot.data.documents.forEach((doc) {
              subPo.add(doc.data['taskName']);
            });
            return new ExpansionTile(
              title: Text('Post-function'),
              children: subPo
                  .map((val) => ListTile(
                title: Text(val),
              ))
                  .toList(),
            );
          }
          return SizedBox(height: 10.0,);
        });
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.name} : Task list'),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.pinkAccent,
                Colors.orange,
              ], begin: Alignment.centerLeft, end: Alignment(0.8, 0.5))),
          child: Column(
            children: <Widget>[
              getRoutine(),
              getPreFunction(),
              getPostFunction(),
              RaisedButton(
                child: Text('Back'),
                color: Colors.orange,
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminPage(
                                auth: widget.auth,
                                title: widget.title,
                              )));
                },
              )
            ],
          ),
        ));
  }
}
