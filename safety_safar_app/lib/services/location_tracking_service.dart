import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/api_config.dart';

class AnomalyEvent {
  final String type;
  final String severity;
  final String message;
  final Map<String, dynamic> data;

  AnomalyEvent({required this.type, required this.severity, required this.message, required this.data});

  Color get color => severity == 'critical' ? Colors.red[900]! : Colors.orange[800]!;
  IconData get icon => type == 'geofence_exit' ? Icons.location_off : Icons.warning_amber_rounded;

  factory AnomalyEvent.fromJson(Map<String, dynamic> json) {
    return AnomalyEvent(
      type: json['type'] ?? 'unknown',
      severity: json['severity'] ?? 'info',
      message: json['description'] ?? 'Safety anomaly detected',
      data: Map<String, dynamic>.from(json),
    );
  }
}

class LocationTrackingService {
  final String _authToken;
  Timer? _periodicTimer;
  StreamSubscription<Position>? _positionStream;

  // Geofence Throttling State
  bool _isCurrentlyOutside = false;

  static const double safeRadiusKm = 2000.0; // Covers India
  static const double centerLat = 20.5937;
  static const double centerLng = 78.9629;

  LocationTrackingService(this._authToken);

  Future<void> startTracking(Function(String) onStatus, Function(String) onError, {Function(AnomalyEvent)? onAnomalyDetected}) async {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((pos) {
      onStatus('📍 ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
      _checkGeofenceThrottled(pos, onAnomalyDetected);
    }, onError: (e) => onError(e.toString()));

    _periodicTimer = Timer.periodic(const Duration(seconds: 15), (_) => _sendLocation());
  }

  void stopTracking() {
    _periodicTimer?.cancel();
    _positionStream?.cancel();
  }

  void _checkGeofenceThrottled(Position pos, Function(AnomalyEvent)? callback) {
    double dist = _calculateDistance(centerLat, centerLng, pos.latitude, pos.longitude);
    bool isOutside = dist > safeRadiusKm;

    // Only trigger if state CHANGED (prevents spamming every second)
    if (isOutside && !_isCurrentlyOutside) {
      _isCurrentlyOutside = true;
      callback?.call(AnomalyEvent(
        type: 'geofence_exit',
        severity: 'critical',
        message: 'CRITICAL: You have exited the Safe Travel Zone!',
        data: {'distance': dist}
      ));
    } else if (!isOutside && _isCurrentlyOutside) {
      _isCurrentlyOutside = false; // User returned to safe zone
    }
  }

  Future<void> _sendLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition();
      await http.post(
        Uri.parse(ApiConfig.trackLocation),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_authToken'},
        body: jsonEncode({
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'accuracy': pos.accuracy,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
          c(lat1 * p) * c(lat2 * p) *
          (1 - c((lon2 - lon1) * p))/2;
    return 12742 * math.asin(math.sqrt(a));
  }

  Future<Position?> getCurrentLocation() async => await Geolocator.getCurrentPosition();
}
