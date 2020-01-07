import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/login_page.dart';
import 'package:task_manager/authentication.dart';
import 'package:task_manager/home_page.dart';


class RootPage extends StatefulWidget {
  RootPage({this.auth,this.camera});
  final BaseAuth auth;
  final CameraDescription camera;

  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {

  AuthStatus _status = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        _status = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    }).catchError((onError){
      print(onError);
    });
  }

  void _onSignedIn() {
    if(!mounted) return;
    setState(() {
      _status = AuthStatus.signedIn;
    });
  }

  void _onSignedOut() {
    if(!mounted) return;
    setState(() {
      _status = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch(_status) {
      case AuthStatus.notSignedIn:
        return LoginPage(auth: widget.auth, onSignedIn: _onSignedIn, camera: widget.camera);
        break;
      case AuthStatus.signedIn:
        return HomePage(auth: widget.auth, onSignedOut: _onSignedOut, camera: widget.camera);
        break;
    }
  }
}
