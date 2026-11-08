import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../services/location_service.dart';

class GpsTrackingScreen extends ConsumerWidget {
  const GpsTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: location.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('GPS error: $error')),
        data: (gps) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(locationProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _statusCard(gps),
              const SizedBox(height: 18),

              _sectionTitle('Location Coordinates'),
              const SizedBox(height: 10),
              _coordinateCard(gps),
              const SizedBox(height: 20),

              _sectionTitle('Satellite Information'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      'Satellites',
                      '${gps.satellites}',
                      Icons.satellite_alt,
                      'Detected',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      'Altitude',
                      '${gps.altitude.toStringAsFixed(1)} m',
                      Icons.terrain,
                      'Above sea level',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _sectionTitle('Movement Information'),
              const SizedBox(height: 10),
              _infoCard(
                'Movement Speed',
                '${(gps.speed * 3.6).toStringAsFixed(1)} km/h',
                Icons.speed,
                'Current estimated speed',
              ),
              const SizedBox(height: 20),

              _sectionTitle('GPS Update'),
              const SizedBox(height: 10),
              _lastUpdated(gps.updatedAt),
              const SizedBox(height: 20),

              _sectionTitle('Live Location Map'),
              const SizedBox(height: 10),

              _LiveMap(latitude: gps.latitude, longitude: gps.longitude),

              const SizedBox(height: 12),

              const Text(
                'Drag to move the map. Pinch or use the map controls '
                'to zoom. The marker follows incoming GPS readings.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _statusCard(LocationModel gps) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: gps.hasFix
            ? AppColors.success.withValues(alpha: 0.09)
            : AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gps.hasFix
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            gps.hasFix ? Icons.gps_fixed : Icons.gps_off,
            size: 32,
            color: gps.hasFix ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gps.hasFix ? 'GPS Signal Available' : 'No GPS Fix',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gps.hasFix
                      ? 'Location coordinates received'
                      : 'Waiting for satellite connection',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coordinateCard(LocationModel gps) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _decoration(),
      child: Column(
        children: [
          _coordinateRow('Latitude', gps.latitude),
          const SizedBox(height: 14),
          _coordinateRow('Longitude', gps.longitude),
        ],
      ),
    );
  }

  Widget _coordinateRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        SelectableText(
          value.toStringAsFixed(6),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _infoCard(
    String title,
    String value,
    IconData icon,
    String description,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: _decoration(),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lastUpdated(DateTime time) {
    final formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: Row(
        children: [
          const Icon(Icons.update, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last GPS Update',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.border),
    );
  }
}

// --------------------------------------------------
// INTERACTIVE MAP
// --------------------------------------------------

class _LiveMap extends StatefulWidget {
  final double latitude;
  final double longitude;

  const _LiveMap({required this.latitude, required this.longitude});

  @override
  State<_LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<_LiveMap> {
  final MapController _mapController = MapController();

  final List<LatLng> _locationTrail = [];

  bool _mapReady = false;

  LatLng get _currentPosition => LatLng(widget.latitude, widget.longitude);

  @override
  void initState() {
    super.initState();
    _addCurrentPosition();
  }

  @override
  void didUpdateWidget(covariant _LiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _addCurrentPosition();

      if (_mapReady) {
        _mapController.move(_currentPosition, _mapController.camera.zoom);
      }
    }
  }

  void _addCurrentPosition() {
    final position = _currentPosition;

    // Avoid adding duplicate consecutive coordinates.
    if (_locationTrail.isEmpty || _locationTrail.last != position) {
      _locationTrail.add(position);
    }

    // Keep the trail limited to the latest 200 points.
    if (_locationTrail.length > 200) {
      _locationTrail.removeAt(0);
    }
  }

  void _recenterMap() {
    if (!_mapReady) return;

    _mapController.move(_currentPosition, 16);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition,
                initialZoom: 15,
                minZoom: 3,
                maxZoom: 19,
                onMapReady: () {
                  _mapReady = true;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.alertxband.alertxband_app',
                  maxZoom: 19,
                ),

                if (_locationTrail.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: List<LatLng>.of(_locationTrail),
                        strokeWidth: 4,
                        color: AppColors.primary,
                      ),
                    ],
                  ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition,
                      width: 55,
                      height: 55,
                      child: const Icon(
                        Icons.location_on,
                        size: 45,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),

                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),

            Positioned(
              right: 12,
              bottom: 45,
              child: FloatingActionButton.small(
                heroTag: 'gps_recenter',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                onPressed: _recenterMap,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
