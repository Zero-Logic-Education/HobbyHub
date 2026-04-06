import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  final Event? initialEvent;

  const MapScreen({super.key, this.initialEvent});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  LatLng get _initialPosition {
    final event = widget.initialEvent;
    if (event != null && event.latitude != 0 && event.longitude != 0) {
      return LatLng(event.latitude, event.longitude);
    }

    return const LatLng(55.751244, 37.618423); // Пример: Москва
  }

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
                context.push('/home/event/${event.id}', extra: event);
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
          zoom: widget.initialEvent == null ? 11.0 : 13.5,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
