import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:task_manager/authentication.dart';
import 'package:task_manager/locales/locale.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn, this.camera});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final CameraDescription camera;

  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  static String _email, _password;
  FormType _formType = FormType.login;
  String role;
  Auth authorize;
  final _formKey = new GlobalKey<FormState>();

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          String userId =
              await widget.auth.signInWithEmailAndPassword(_email, _password);
          print("Signed In $userId");
        } else {
          String userId = await widget.auth
              .createUserWithEmailAndPassword(_email, _password);
          print("Registered User $userId");
        }
        widget.onSignedIn();
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  void _moveToRegister() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void _moveToLogin() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  void _signInWithGoogle() async {
    try {
      String st = await widget.auth.googleSignedIn();
      print(st);
      widget.onSignedIn();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.orange, Colors.orangeAccent],
                begin: Alignment.centerLeft,
                end: Alignment(0.8, 0.5))),
        width: double.infinity,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _formField(context),
                  RaisedButton(
                      child: Icon(
                        FontAwesomeIcons.google,
                        color: Colors.red,
                      ),
                      color: Colors.white,
                      onPressed: _signInWithGoogle),
                  SizedBox(
                    width: 50.0,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(BuildContext context) {
    if (_formType == FormType.login) {
      return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                title: TextFormField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: DemoLocalizations.of(context).email,
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                    icon: Icon(
                      FontAwesomeIcons.envelope,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                  validator: (value) =>
                      value.isEmpty ? "Email Address can't empty" : null,
                  onSaved: (value) => _email = value,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              ListTile(
                title: TextFormField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: DemoLocalizations.of(context).password,
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                    icon: Icon(
                      FontAwesomeIcons.lock,
                      color: Colors.white,
                      size: 20.0,
                    ),
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
              RaisedButton(
                  child: Text(
                    DemoLocalizations.of(context).loginButton,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  color: Colors.indigoAccent,
                  padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  onPressed: _validateAndSubmit),
              FlatButton(
                splashColor: Colors.lightBlueAccent,
                child: Text(
                  DemoLocalizations.of(context).signUp,
                  style: TextStyle(color: Colors.lightBlue),
                ),
                onPressed: _moveToRegister,
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      );
    } else {
      return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                //leading: Icon(Icons.email, color: Colors.blue),
                title: TextFormField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: DemoLocalizations.of(context).email,
                    labelStyle:
                        TextStyle(color: Colors.deepPurple, fontSize: 20),
                    hintText: 'Email must contain @',
                    icon: Icon(
                      FontAwesomeIcons.envelope,
                      color: Colors.deepPurple,
                      size: 22.0,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                  validator: (value) =>
                      value.isEmpty ? "Email Address can't empty" : null,
                  onSaved: (value) => _email = value,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                //leading: Icon(Icons.lock, color: Colors.blue),
                title: TextFormField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: DemoLocalizations.of(context).password,
                    labelStyle:
                        TextStyle(color: Colors.deepPurple, fontSize: 20),
                    hintText: 'Password must contain 1 letter',
                    icon: Icon(
                      FontAwesomeIcons.lock,
                      color: Colors.deepPurple,
                      size: 22.0,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  maxLength: 10,
                  obscureText: true,
                  validator: (value) {
                    value.isEmpty ? "Password can't be empty" : null;
                  },
                  onSaved: (value) => _password = value,
                ),
              ),
              RaisedButton(
                  child: Text(
                    DemoLocalizations.of(context).signUpButton,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  color: Colors.blue,
                  onPressed: _validateAndSubmit),
              FlatButton(
                child: Text(
                  DemoLocalizations.of(context).login,
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: _moveToLogin,
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      );
    }
  }
}
