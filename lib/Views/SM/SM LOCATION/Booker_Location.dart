import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../API/Globals.dart';

Future<Map<String, LatLng>> fetchMarkersByDesignation(List<String> designations) async {
  Map<String, LatLng> markers = {};
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('location') // Adjust this collection path as needed
      .where('designation', whereIn: designations)
      .where('SM_ID', whereIn: [userId]) // Fetch markers for specified designations
      .get();

  for (var doc in snapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;
    markers[data['name']] = LatLng(data['latitude'], data['longitude']); // Ensure that your document has 'name', 'latitude', 'longitude' fields
  }

  return markers;
}

class BookerLocation extends StatefulWidget {
  @override
  _BookerLocationState createState() => _BookerLocationState();
}

class _BookerLocationState extends State<BookerLocation> {
  late GoogleMapController mapController;
  Map<String, LatLng> _markers = {};
  LatLng _initialCameraPosition = const LatLng(24.8607, 67.0011);
  final List<String> designations = ['ASM', 'SO', 'SOS', 'SPO']; // List of designations to fetch

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    Map<String, LatLng> fetchedMarkers = await fetchMarkersByDesignation(designations);
    setState(() {
      _markers = fetchedMarkers; // Update state with fetched markers
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitAllMarkers();
  }

  void _onMarkerSelected(String markerName) {
    LatLng? position = _markers[markerName];
    if (position != null) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
    }
  }

  void _fitAllMarkers() {
    if (_markers.isNotEmpty) {
      LatLngBounds bounds;
      LatLng southwest = LatLng(
        _markers.values.map((latlng) => latlng.latitude).reduce((a, b) => a < b ? a : b),
        _markers.values.map((latlng) => latlng.longitude).reduce((a, b) => a < b ? a : b),
      );
      LatLng northeast = LatLng(
        _markers.values.map((latlng) => latlng.latitude).reduce((a, b) => a > b ? a : b),
        _markers.values.map((latlng) => latlng.longitude).reduce((a, b) => a > b ? a : b),
      );
      bounds = LatLngBounds(southwest: southwest, northeast: northeast);

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50), // Padding of 50 pixels
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialCameraPosition,
                zoom: 4.0,
              ),
              markers: _markers.entries.map((entry) {
                return Marker(
                  markerId: MarkerId(entry.key),
                  position: entry.value,
                  infoWindow: InfoWindow(title: entry.key),
                );
              }).toSet(),
            ),
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownSearch<String>(
                  items: _markers.keys.toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _onMarkerSelected(newValue);
                    }
                  },
                  selectedItem: _markers.isNotEmpty ? _markers.keys.first : null,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Select Marker",
                      prefixIcon: const Icon(Icons.location_on),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Search Marker",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    menuProps: MenuProps(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mapController.animateCamera(CameraUpdate.newLatLngZoom(_initialCameraPosition, 6));
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
