import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class LiveAlertsMapScreen extends StatefulWidget {
  final String authToken;
  final List alerts;

  const LiveAlertsMapScreen({
    super.key,
    required this.authToken,
    required this.alerts,
  });

  @override
  State<LiveAlertsMapScreen> createState() => _LiveAlertsMapScreenState();
}

class _LiveAlertsMapScreenState extends State<LiveAlertsMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  dynamic _selectedEntity;
  Timer? _pollingTimer;
  List _allTourists = [];
  bool _showSatellite = false;

  @override
  void initState() {
    super.initState();
    _fetchAllTouristsLocations();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchAllTouristsLocations();
    });
  }

  Future<void> _fetchAllTouristsLocations() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.tourists),
        headers: {'Authorization': 'Bearer ${widget.authToken}'},
      );
      if (res.statusCode == 200 && mounted) {
        final dynamic decoded = jsonDecode(res.body);
        final List tourists = (decoded is Map) ? (decoded['tourists'] ?? []) : decoded;
        setState(() {
          _allTourists = tourists;
          _updateMarkers();
        });

        // Auto-focus on first active SOS if found
        if (widget.alerts.any((a) => a['status'] == 'active')) {
          final activeAlert = widget.alerts.firstWhere((a) => a['status'] == 'active');
          _focusOnAlert(activeAlert);
        }
      }
    } catch (e) {
      debugPrint('Map fetch error: $e');
    }
  }

  void _focusOnAlert(dynamic alert) {
    final lat = double.tryParse(alert['latitude']?.toString() ?? '');
    final lng = double.tryParse(alert['longitude']?.toString() ?? '');
    if (lat != null && lng != null && _mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14));
    }
  }

  void _updateMarkers() {
    final Set<Marker> updated = {};
    final Set<String> usersWithSOS = {};

    // 1. SOS Alert markers (HIGHEST PRIORITY)
    for (var alert in widget.alerts) {
      if (alert['latitude'] != null && alert['longitude'] != null) {
        final bool isActive = alert['status'] == 'active';
        final latStr = alert['latitude']?.toString() ?? '';
        final lngStr = alert['longitude']?.toString() ?? '';
        final lat = double.tryParse(latStr);
        final lng = double.tryParse(lngStr);

        if (lat != null && lng != null) {
          usersWithSOS.add(alert['user_id'].toString());
          updated.add(Marker(
            markerId: MarkerId('alert_${alert['id']}'),
            position: LatLng(lat, lng),
            zIndex: 10,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isActive ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
            ),
            onTap: () => setState(() => _selectedEntity = {...alert, 'type': 'alert'}),
          ));
        }
      }
    }

    // 2. Regular Tourist markers (Only if safe)
    for (var tourist in _allTourists) {
      if (tourist['last_location'] != null && !usersWithSOS.contains(tourist['id'].toString())) {
        final loc = tourist['last_location'];
        final lat = (loc['latitude'] as num?)?.toDouble();
        final lng = (loc['longitude'] as num?)?.toDouble();
        
        if (lat != null && lng != null) {
          updated.add(Marker(
            markerId: MarkerId('tourist_${tourist['id']}'),
            position: LatLng(lat, lng),
            zIndex: 1,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            alpha: 0.85,
            onTap: () => setState(() => _selectedEntity = {...tourist, 'type': 'tourist'}),
          ));
        }
      }
    }

    setState(() {
      _markers.clear();
      _markers.addAll(updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5),
            mapType: _showSatellite ? MapType.hybrid : MapType.normal,
            markers: _markers,
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap: (_) => setState(() => _selectedEntity = null),
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(children: [
                  Expanded(child: _buildControlCard()),
                  const SizedBox(width: 10),
                  _buildRoundButton(Icons.satellite_alt_rounded, () => setState(() => _showSatellite = !_showSatellite), active: _showSatellite),
                  const SizedBox(width: 10),
                  _buildRoundButton(Icons.refresh_rounded, _fetchAllTouristsLocations),
                ]),
              ),
            ),
          ),

          if (_selectedEntity != null)
            Positioned(bottom: 30, left: 16, right: 16, child: _buildDetailCard()),
        ],
      ),
    );
  }

  Widget _buildControlCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: const Offset(0, 4))]),
      child: Row(children: [
        const Icon(Icons.radar_rounded, color: Color(0xFF0E3A7E), size: 18),
        const SizedBox(width: 10),
        Text('${_allTourists.length} Tracked Tourists', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontSize: 13)),
      ]),
    );
  }

  Widget _buildRoundButton(IconData icon, VoidCallback onTap, {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: active ? const Color(0xFF0E3A7E) : Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)]),
        child: Icon(icon, color: active ? Colors.white : const Color(0xFF0E3A7E), size: 20),
      ),
    );
  }

  Widget _buildDetailCard() {
    final bool isAlert = _selectedEntity['type'] == 'alert';
    final name = isAlert ? _selectedEntity['name'] : '${_selectedEntity['first_name']} ${_selectedEntity['last_name']}';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 24, offset: const Offset(0, 10))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          CircleAvatar(radius: 24, backgroundColor: isAlert ? Colors.red.withOpacity(0.1) : const Color(0xFF0E3A7E).withOpacity(0.1), child: Icon(isAlert ? Icons.emergency : Icons.person, color: isAlert ? Colors.red : const Color(0xFF0E3A7E))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(_selectedEntity['phone'] ?? 'No phone', style: const TextStyle(color: Colors.grey, fontSize: 12))])),
          if (isAlert) Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)), child: const Text('SOS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => launchUrl(Uri.parse("tel:${_selectedEntity['phone']}")), icon: const Icon(Icons.call), label: const Text("Call User"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(onPressed: () {
            final lat = isAlert ? _selectedEntity['latitude'] : _selectedEntity['last_location']['latitude'];
            final lng = isAlert ? _selectedEntity['longitude'] : _selectedEntity['last_location']['longitude'];
            launchUrl(Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$lng"));
          }, icon: const Icon(Icons.directions), label: const Text("Navigate"))),
        ])
      ]),
    );
  }
}
