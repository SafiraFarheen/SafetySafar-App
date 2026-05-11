import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/weather_service.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  double _latitude = 0.0;
  double _longitude = 0.0;
  late DateTime _lastUpdated;

  @override
  void initState() {
    super.initState();
    _lastUpdated = DateTime.now();
    _fetchLocationAndWeather();
  }

  /// Fetch user's current location
  Future<void> _fetchLocationAndWeather() async {
    try {
      setState(() => _isLoading = true);

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permissions denied. Using default location (India Center).';
          _latitude = 20.5937;
          _longitude = 78.9629;
          _isLoading = false;
        });
        _loadWeather();
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Fallback to India center if timeout
          return Position(
            latitude: 20.5937,
            longitude: 78.9629,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        },
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      debugPrint('[WeatherScreen] Location: $_latitude, $_longitude');
      _loadWeather();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  /// Load weather data
  Future<void> _loadWeather() async {
    try {
      final weatherData = await WeatherService.fetchWeather(
        latitude: _latitude,
        longitude: _longitude,
      );

      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
        _errorMessage = null;
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /// Refresh weather data
  Future<void> _refreshWeather() async {
    await _loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: Stack(
        children: [
          // 🌌 BACKGROUND GRADIENT
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0E3A7E).withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00BCD4).withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshWeather,
              color: AppColors.primaryDeepBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Weather & Alerts',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_latitude.toStringAsFixed(2)}, ${_longitude.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _refreshWeather,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryDeepBlue.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.rotateCcw,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // LOADING STATE
                    if (_isLoading)
                      _buildLoadingState()
                    // ERROR STATE
                    else if (_errorMessage != null)
                      _buildErrorState()
                    // SUCCESS STATE
                    else if (_weatherData != null)
                      _buildWeatherContent()
                    else
                      _buildEmptyState(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDeepBlue.withOpacity(0.2),
                ),
                child: const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0E3A7E),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Fetching Weather Data...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.2),
            ),
            child: const Icon(
              LucideIcons.alertCircle,
              color: Colors.red,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to Fetch Weather',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshWeather,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDeepBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build weather content
  Widget _buildWeatherContent() {
    final weather = _weatherData!;
    final weatherCode = int.tryParse(weather.weatherCode) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MAIN WEATHER CARD - Temperature & Condition
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDeepBlue.withOpacity(0.8),
                const Color(0xFF1A5FAA),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        WeatherService.getWeatherDescription(weatherCode),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    WeatherService.getWeatherEmoji(weatherCode),
                    style: const TextStyle(fontSize: 64),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWeatherDetail(
                    icon: LucideIcons.wind,
                    label: 'Wind Speed',
                    value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                  ),
                  _buildWeatherDetail(
                    icon: LucideIcons.mapPin,
                    label: 'Location',
                    value: '${_latitude.toStringAsFixed(2)}°\n${_longitude.toStringAsFixed(2)}°',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // HAZARD ALERT CARD
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: weather.hazardColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: weather.hazardColor.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: weather.hazardColor.withOpacity(0.3),
                    ),
                    child: Icon(
                      _getHazardIcon(weather.hazardLevel),
                      color: weather.hazardColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hazard Alert',
                          style: TextStyle(
                            color: weather.hazardColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          weather.hazardLevel,
                          style: TextStyle(
                            color: weather.hazardColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: weather.hazardColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getHazardBadge(weather.hazardLevel),
                      style: TextStyle(
                        color: weather.hazardColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                weather.hazardMessage,
                style: TextStyle(
                  color: weather.hazardColor.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildHazardRecommendation(weather.hazardLevel),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // DETAILED WEATHER METRICS
        Text(
          'Detailed Metrics',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: LucideIcons.thermometer,
                label: 'Temperature',
                value: '${weather.temperature.toStringAsFixed(1)}°C',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: LucideIcons.wind,
                label: 'Wind Speed',
                value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                color: AppColors.primarySkyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: LucideIcons.cloud,
                label: 'Condition',
                value: WeatherService.getWeatherDescription(weatherCode),
                color: AppColors.primaryDeepBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: LucideIcons.clock,
                label: 'Updated',
                value: DateFormat('hh:mm a').format(_lastUpdated),
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // SAFETY TIPS
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E4A).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryDeepBlue.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.shield,
                    color: AppColors.primarySkyBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Safety Recommendations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSafetyTip(
                '✓ Stay hydrated',
                'Drink water regularly to stay safe',
              ),
              const SizedBox(height: 8),
              _buildSafetyTip(
                '✓ Seek shelter if needed',
                'Move to safe areas during hazardous weather',
              ),
              const SizedBox(height: 8),
              _buildSafetyTip(
                '✓ Monitor alerts',
                'Keep checking weather updates regularly',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build weather detail widget
  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build metric card
  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build hazard recommendation
  Widget _buildHazardRecommendation(String hazardLevel) {
    String recommendation = '';
    Color bgColor = const Color(0xFF4CAF50);

    switch (hazardLevel) {
      case 'CRITICAL':
        recommendation =
            '🚨 CRITICAL: Avoid outdoor activities. Seek shelter immediately.';
        bgColor = const Color(0xFFF44336);
        break;
      case 'HIGH':
        recommendation =
            '⚠️ HIGH RISK: Limit outdoor exposure. Wear protective gear.';
        bgColor = const Color(0xFFFF9800);
        break;
      case 'MODERATE':
        recommendation = '⚡ MODERATE: Take precautions and stay alert.';
        bgColor = const Color(0xFFFFC107);
        break;
      default:
        recommendation = '✓ All clear! Enjoy your activities safely.';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        recommendation,
        style: TextStyle(
          color: bgColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build safety tip
  Widget _buildSafetyTip(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.cloud,
            size: 64,
            color: Colors.white30,
          ),
          const SizedBox(height: 20),
          const Text(
            'No Weather Data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unable to load weather information',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Get hazard icon based on level
  IconData _getHazardIcon(String hazardLevel) {
    switch (hazardLevel) {
      case 'CRITICAL':
        return LucideIcons.alertTriangle;
      case 'HIGH':
        return LucideIcons.alertCircle;
      case 'MODERATE':
        return LucideIcons.info;
      default:
        return LucideIcons.checkCircle;
    }
  }

  /// Get hazard badge text
  String _getHazardBadge(String hazardLevel) {
    switch (hazardLevel) {
      case 'CRITICAL':
        return 'CRITICAL';
      case 'HIGH':
        return 'HIGH';
      case 'MODERATE':
        return 'MODERATE';
      default:
        return 'SAFE';
    }
  }
}
