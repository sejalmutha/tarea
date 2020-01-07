import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:task_manager/authentication.dart';
import 'package:task_manager/login_page.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  MapPage({this.auth, this.onSignedOut, this.location});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final List<Position> location;
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  String userid = '';
  getUid() {}

  List<Marker> markerList = <Marker>[];
  List<LatLng> _points = <LatLng>[];
  var j=1;

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    this.userid = "";
    widget.auth.currentUser().then((val) {
      setState(() {
        this.userid = val;
      });
    });
    for (var i = 0; i < widget.location.length; i++) {
      LatLng point =
          LatLng(widget.location[i].latitude, widget.location[i].longitude);
      _points.add(point);
    }
    //List<Position> position=widget.location.toList();
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('GeoFence'),
          backgroundColor: Colors.green[700],
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
          child: Stack(
            children: <Widget>[
              GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.location.first.latitude,
                        widget.location.first.longitude),
                    zoom: 11.0,
                  ),
                  polygons: Set<Polygon>.of(<Polygon>[
                    Polygon(
                        polygonId: PolygonId('area'),
                        points: _points,
                        geodesic: true,
                        strokeColor: Colors.blue,
                        fillColor: Colors.lightBlue.withOpacity(0.1),
                        visible: true)
                  ]),
                  markers: Set<Marker>.of(<Marker>[
                    Marker(
                        markerId: MarkerId('1'),
                        position: LatLng(widget.location.first.latitude,
                            widget.location.first.longitude),
                        visible: true,
                        draggable: true)
                  ])),
            ],
          ),
        ),
      ),
    );
  }
}
