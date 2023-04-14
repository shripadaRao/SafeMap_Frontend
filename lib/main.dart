import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
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

  bool _isReportButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // _mapTileController = MapTileLayerController();
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

  void _onReportButtonPressed(bool isPressed) {
    setState(() {
      _isReportButtonPressed = isPressed;
    });

    if (_isReportButtonPressed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Report mode is ON. Tap on map to register a crime'),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
      ));
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
                  minZoom: 12.0,
                  // onTap: _handleTap,
                  onTap: _isReportButtonPressed
                      ? ((tapPosition, point) => {print(point.toString())})
                      : null),
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
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: ReportButton(
              onPressed: (isPressed) => _onReportButtonPressed(isPressed),
            ),
          ),
          FloatingActionButton(
            onPressed: _centerMap,
            child: Icon(Icons.my_location),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ReportButton extends StatefulWidget {
  final ValueChanged<bool>? onPressed;

  const ReportButton({Key? key, this.onPressed}) : super(key: key);

  @override
  _ReportButtonState createState() => _ReportButtonState();
}

class _LocationReporter {
  Future<Position> reportLocation(LatLng tappedPosition) async {
    final currentPosition = Position(
      latitude: tappedPosition.latitude,
      longitude: tappedPosition.longitude,
      timestamp: DateTime.now(),
      altitude: 0.0,
      accuracy: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
    return currentPosition;
  }
}

class _ReportButtonState extends State<ReportButton> {
  bool _isButtonPressed = false;
  LatLng? _lastTappedPosition;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16, left: 16),
      child: FloatingActionButton(
        backgroundColor: _isButtonPressed ? Colors.red : Colors.grey,
        onPressed: () async {
          setState(() {
            _isButtonPressed = !_isButtonPressed;
          });
          if (widget.onPressed != null) {
            widget.onPressed!(_isButtonPressed);
          }
        },
        child: Icon(Icons.report),
      ),
    );
  }
}
