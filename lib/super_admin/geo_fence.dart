import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/authentication.dart';
import 'package:task_manager/login_page.dart';
import 'package:task_manager/super_admin/map.dart';
import 'dart:async';

class GeoFence extends StatefulWidget {
  GeoFence({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  _GeoFenceState createState() => _GeoFenceState();
}

class _GeoFenceState extends State<GeoFence> {
  String userid = '';
  getUid() {}

  final List<Widget> listItems = <Widget>[];

  Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
  //StreamSubscription<Position> _positionStreamSubscription;
  static final List<Position> _positions = <Position>[];
  Position _pos;

  @override
  void initState() {
    this.userid = "";
    widget.auth.currentUser().then((val) {
      setState(() {
        this.userid = val;
      });
    });
    _getLocation();
    super.initState();
  }

  Future<void> _getLocation() async {
    Position currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    setState(() {
      _pos = currentLocation;
    });

    _positions.add(_pos);
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

  Widget _buildListView() {
    final List<Widget> listItems = <Widget>[
      ListTile(
        title: RaisedButton(
            child: Text('Get Location'),
            color: Colors.white,
            onPressed: _getLocation),
      ),
      RaisedButton(
          child: Text('Done'),
          color: Colors.white,
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MapPage(
                          auth: widget.auth,
                          onSignedOut: widget.onSignedOut,
                          location: _positions,
                        )));
          }),
    ];

    listItems.addAll(_positions
        .map((Position position) => PositionListItem(position))
        .toList());

    print(_positions);

    return ListView(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: listItems,
    );
  }

  /*bool _isListening() => !(_positionStreamSubscription == null ||
      _positionStreamSubscription.isPaused);

  Widget _buildButtonText() {
    return Text(_isListening() ? 'Stop listening' : 'Start listening');
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geo Fence'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.call_made),
              tooltip: 'Sign Out',
              onPressed: _signOut),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.pinkAccent,
          Colors.orange,
        ], begin: Alignment.centerLeft, end: Alignment(0.8, 0.5))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildListView(),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PositionListItem extends StatefulWidget {
  const PositionListItem(this._position);

  final Position _position;

  @override
  State<PositionListItem> createState() => PositionListItemState(_position);
}

class PositionListItemState extends State<PositionListItem> {
  PositionListItemState(this._position);

  final Position _position;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Lat: ${_position.latitude}',
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                ),
                Text(
                  'Lon: ${_position.longitude}',
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                ),
              ]),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _position.timestamp.toLocal().toString(),
                    style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                  )
                ]),
          ),
        ],
      ),
    );
  }
}

/*void _toggleListening() {
    if (_positionStreamSubscription == null) {
      const LocationOptions locationOptions =
          LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 10);
      final Stream<Position> positionStream =
          geolocator.getPositionStream(locationOptions);
      _positionStreamSubscription = positionStream.listen(
          (Position position) => setState(() => _positions.add(position)));
      _positionStreamSubscription.pause();
    }

    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
      } else {
        _positionStreamSubscription.pause();
      }
    });
  }*/

/* @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }

    super.dispose();
  }*/
