import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/event_provider.dart';
import 'event_detail_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  final LatLng _initialPosition = const LatLng(
    55.751244,
    37.618423,
  ); // Пример: Москва

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMarkers();
  }

  void _updateMarkers() {
    final events = ref.read(eventsStreamProvider).value ?? [];
    final markers = events
        .where((e) => e.latitude != 0 && e.longitude != 0)
        .map((event) {
          return Marker(
            markerId: MarkerId(event.id),
            position: LatLng(event.latitude, event.longitude),
            infoWindow: InfoWindow(
              title: event.title,
              snippet: event.address,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(event: event),
                  ),
                );
              },
            ),
          );
        })
        .toSet();

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем изменения со стрима, чтобы обновлять маркеры
    ref.listen(eventsStreamProvider, (previous, next) {
      if (_mapController != null) {
        _updateMarkers();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Карта событий',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 11.0,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
