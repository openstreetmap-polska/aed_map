import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

import '../constants.dart';
import '../store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    BorderRadius radius = const BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    return CupertinoPageScaffold(
        child: SlidingUpPanel(borderRadius: radius, panel: Container(decoration: BoxDecoration(borderRadius: radius), child: _buildBottomPanel()), body: SafeArea(child: _buildMap(), top: false)));
  }

  Widget _buildBottomPanel() {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 24.0),
          Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: const BorderRadius.all(Radius.circular(12.0))),
          ),
        ],
      ),
    ]);
  }

  Widget _buildMap() {
    return FutureBuilder<Position>(
        future: Store.instance.determinePosition(),
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          if (snapshot.hasData || snapshot.hasError) {
            return Column(
              children: [
                Flexible(
                    child: FlutterMap(
                  options: MapOptions(center: snapshot.hasData ? LatLng(snapshot.data!.latitude, snapshot.data!.longitude) : warsaw, zoom: 14, maxZoom: 18, plugins: [VectorMapTilesPlugin()]),
                  layers: <LayerOptions>[
                    VectorTileLayerOptions(theme: _getMapTheme(context), tileProviders: TileProviders({'openmaptiles': Store.instance.buildCachingTileProvider()})),
                    MarkerLayerOptions(markers: [
                      Marker(point: rzeszow, builder: (context) => SvgPicture.asset('assets/map-pin.svg', color: Colors.red, semanticsLabel: 'A red up arrow')),
                    ])
                  ],
                  children: [LocationMarkerLayerWidget()],
                )),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  _getMapTheme(BuildContext context) {
    // maps are rendered using themes
    // to provide a dark theme do something like this:
    // if (MediaQuery.of(context).platformBrightness == Brightness.dark) return myDarkTheme();
    return ProvidedThemes.lightTheme();
  }
}
