import 'package:flutter/material.dart';
import 'package:task_manager/authentication.dart';
import 'package:task_manager/login_page.dart';
import 'viewTask.dart';
import 'viewUser.dart';

class AdminPage extends StatefulWidget {
  AdminPage({this.auth, this.onSignedOut, this.title});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String title;
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String userid = '';
  getUid() {}
  final snackBar = SnackBar(content: Text('Deleted successfully'));

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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.pinkAccent,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.call_made),
                tooltip: 'Sign Out',
                onPressed: _signOut),
          ],
          bottom: TabBar(tabs: [
            Tab(
              text: 'Tasks',
            ),
            Tab(
              text: 'Users',
            ),
          ]),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.pinkAccent,
            Colors.orange,
          ], begin: Alignment.centerLeft, end: Alignment(0.8, 0.5))),
          child: TabBarView(children: [
            TaskView(auth: widget.auth, title: widget.title),
            UserView(auth: widget.auth,onSignedOut: widget.onSignedOut, title: widget.title),
          ]),
        ),
        /*floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.call_made),
          label: Text(DemoLocalizations.of(context).signOutButton),
          onPressed: _signOut,
          backgroundColor: Colors.redAccent,
        ),*/
      ),
    );
  }
}
