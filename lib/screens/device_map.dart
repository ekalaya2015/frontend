import 'package:flutter_map/plugin_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DeviceMap extends StatelessWidget {
  final double lat;
  final double lon;
  final String name;
  const DeviceMap(
      {Key? key, required this.name, required this.lat, required this.lon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('$name\'s Location')),
        body: FlutterMap(
          options: MapOptions(
            center: LatLng(lat, lon),
            zoom: 15,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.monitax.app',
            ),
            MarkerLayerOptions(markers: [
              Marker(
                  point: LatLng(lat, lon),
                  builder: (context) => const Icon(
                        Icons.pin_drop,
                        size: 32,
                        color: Color.fromRGBO(4, 79, 241, 1),
                      ))
            ])
          ],
          nonRotatedChildren: [
            AttributionWidget.defaultWidget(
              source: 'OpenStreetMap contributors',
              onSourceTapped: null,
            ),
          ],
        ));
  }
}
