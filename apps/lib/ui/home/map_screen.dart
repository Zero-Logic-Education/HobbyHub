import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  LatLng? _userPosition;
  bool _locationWarningShown = false;
  Timer? _markersDebounce;
  String _lastMarkersSignature = '';

  LatLng get _initialPosition {
    final event = widget.initialEvent;
    if (event != null && event.latitude != 0 && event.longitude != 0) {
      return LatLng(event.latitude, event.longitude);
    }

    if (_userPosition != null) {
      return _userPosition!;
    }

    return const LatLng(55.751244, 37.618423);
  }

  @override
  void initState() {
    super.initState();
    _resolveUserLocation();
  }

  @override
  void dispose() {
    _markersDebounce?.cancel();
    super.dispose();
  }

  Future<void> _resolveUserLocation() async {
    if (widget.initialEvent != null) return;

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled || permission == LocationPermission.deniedForever) {
        _showLocationUnavailableWarning();
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        if (!mounted) return;

        final target = LatLng(position.latitude, position.longitude);
        setState(() {
          _userPosition = target;
        });

        await _mapController?.animateCamera(CameraUpdate.newLatLng(target));
      } else {
        _showLocationUnavailableWarning();
      }
    } catch (_) {
      _showLocationUnavailableWarning();
    }
  }

  void _showLocationUnavailableWarning() {
    if (!mounted || _locationWarningShown || widget.initialEvent != null) {
      return;
    }

    _locationWarningShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Геолокация недоступна. Карта показывает события по умолчанию.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _scheduleMarkersUpdate();

    if (_userPosition != null && widget.initialEvent == null) {
      controller.animateCamera(CameraUpdate.newLatLng(_userPosition!));
    }
  }

  String _buildMarkersSignature(List<Event> events) {
    final prepared = events
        .where((e) => e.latitude != 0 && e.longitude != 0)
        .map((e) => '${e.id}:${e.latitude}:${e.longitude}')
        .toList()
      ..sort();
    return prepared.join('|');
  }

  void _scheduleMarkersUpdate() {
    _markersDebounce?.cancel();
    _markersDebounce = Timer(const Duration(milliseconds: 220), _updateMarkers);
  }

  void _updateMarkers() {
    final events =
        ref.read(eventsStreamProvider).valueOrNull ?? const <Event>[];
    final signature = _buildMarkersSignature(events);
    if (signature == _lastMarkersSignature) {
      return;
    }

    _lastMarkersSignature = signature;

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
    // Слушаем изменения списка событий и обновляем маркеры с дебаунсом.
    ref.listen(eventsStreamProvider, (previous, next) {
      if (_mapController != null) {
        _scheduleMarkersUpdate();
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
