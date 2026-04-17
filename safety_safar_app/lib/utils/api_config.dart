class ApiConfig {
  // ── Change this IP when you switch networks ──────────────────
  static const String serverIp = '192.168.29.143';
  static const String baseUrl = 'http://$serverIp:8000';

  // ── Auth ─────────────────────────────────────────────────────
  static const String login          = '$baseUrl/login';
  static const String register       = '$baseUrl/register';
  static const String sendOtp        = '$baseUrl/send-otp';
  static const String verifyOtp      = '$baseUrl/verify-otp';
  static const String forgotPassword = '$baseUrl/forgot-password';
  static const String resetPassword  = '$baseUrl/reset-password';

  // ── Dashboard & Alerts ───────────────────────────────────────
  static const String dashboardStats = '$baseUrl/dashboard/stats';
  static const String alerts         = '$baseUrl/alerts';
  static String resolveAlert(dynamic id) => '$baseUrl/alerts/resolve/$id';

  // ── KYC & Tourists ───────────────────────────────────────────
  static const String kycPending               = '$baseUrl/kyc/pending';
  static String kycDocuments(String uid)        => '$baseUrl/kyc/$uid/documents';
  static String kycDownload(String uid, String t) => '$baseUrl/kyc/$uid/download/$t';
  static String kycApprove(String uid)          => '$baseUrl/kyc/$uid/approve';
  static String kycReject(String uid)           => '$baseUrl/kyc/$uid/reject';

  static const String tourists            = '$baseUrl/tourists';
  static String touristProfile(String id) => '$baseUrl/tourists/$id';

  // ── Anomaly / Geofencing ─────────────────────────────────────
  static const String trackLocation  = '$baseUrl/anomaly/track-location';
  static const String anomalyAlerts  = '$baseUrl/anomaly/alerts';
  static const String anomalyConfig  = '$baseUrl/anomaly/config';
  static String resolveAnomalyAlert(String id) =>
      '$baseUrl/anomaly/alerts/resolve/$id';

  // Danger zones
  static const String dangerZones = '$baseUrl/anomaly/danger-zones';
  static String dangerZonesNear(double lat, double lng, {double radiusKm = 5}) =>
      '$baseUrl/anomaly/danger-zones?latitude=$lat&longitude=$lng&radius_km=$radiusKm';
}
