import 'package:flutter/material.dart';
import 'package:task_manager/authentication.dart';
import 'package:task_manager/user/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewTaskPage extends StatefulWidget {
  NewTaskPage({this.auth, this.onSignedOut, this.title});
  final VoidCallback onSignedOut;
  final BaseAuth auth;
  final String title;
  @override
  _NewTaskPageState createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final _form = new GlobalKey<FormState>();
  static String _taskName, _taskType, _area, _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Task'),
        ),
        body: Container(
          child: Form(
            key: _form,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 18.0,
                      ),
                      Text(
                        'Area: ',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      DropdownButton<String>(
                        value: _area,
                        hint: Text('<select area>'),
                        onChanged: (value) {
                          setState(() {
                            _area = value;
                          });
                        },
                        items: <String>[
                          'Hall', 'Lawn'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 18.0,
                      ),
                      Text(
                        'Type: ',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      DropdownButton<String>(
                        value: _taskType,
                        hint: Text('<select task type>'),
                        onChanged: (value) {
                          setState(() {
                            _taskType = value;
                          });
                        },
                        items: <String>[
                          'Routine',
                          'Pre-function',
                          'Post-function',
                          'One-time'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  ListTile(
                    title: TextFormField(
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Task Name: ',
                          labelStyle:
                          TextStyle(color: Colors.blue, fontSize: 20.0)),
                      validator: (value) =>
                      value.isEmpty ? 'Enter name of the task' : null,
                      keyboardType: TextInputType.text,
                      onSaved: (value) => _taskName = value,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    title: TextFormField(
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'User Name: ',
                          labelStyle:
                          TextStyle(color: Colors.blue, fontSize: 20.0)),
                      validator: (value) =>
                      value.isEmpty ? 'Enter name of the user' : null,
                      keyboardType: TextInputType.text,
                      onSaved: (value) => _user = value,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        child: Text('Submit'),
                        onPressed: submit,
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      RaisedButton(
                        child: Text('Back'),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserPage(
                                        auth: widget.auth,
                                        onSignedOut: widget.onSignedOut,
                                      title: widget.title
                                      )));
                         //Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  submit() async {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      Firestore.instance.runTransaction((Transaction transaction) async {
        CollectionReference ref = Firestore.instance
            .collection('TaskList')
            .document(_area)
            .collection(_taskType);

        await ref.add({'taskName': _taskName});
      });
    }
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UserPage(
                  auth: widget.auth,
                  onSignedOut: widget.onSignedOut,
                title: widget.title
                )));
  }
}
