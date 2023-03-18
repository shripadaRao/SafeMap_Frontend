import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safemap/utils/getLiveLocation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        // appBar: AppBar(
        //   title: Text('SafeMap'),
        // ),
        body: MapScreen(),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController = MapController();
  late Position? _currentPosition = Position(
      longitude: 77.59,
      latitude: 12.97,
      timestamp: DateTime.now(),
      accuracy: 15.0,
      altitude: 10.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0);
  // Position(longitude: 12.9716, latitude: 77.5946)

  bool _isReportButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    determinePosition().then((position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print('Error: $e');
    });
  }

  void _centerMap() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        18.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition != null
          ? FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                  center: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  zoom: 18.0,
                  maxZoom: 18.2,
                  minZoom: 12.0),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      builder: (ctx) => Container(
                        child: Icon(
                          Icons.accessibility_new_sharp,
                          size: 45.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: ReportButton(),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _centerMap,
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ReportButton extends StatefulWidget {
  const ReportButton({Key? key}) : super(key: key);

  @override
  _ReportButtonState createState() => _ReportButtonState();
}

class _ReportButtonState extends State<ReportButton> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16, left: 16),
      child: FloatingActionButton(
        backgroundColor: _isButtonPressed ? Colors.red : Colors.grey,
        onPressed: () {
          setState(() {
            _isButtonPressed = !_isButtonPressed;
          });
        },
        child: Icon(Icons.report),
      ),
    );
  }
}
