import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeepBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Safety Safar'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.bell),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.menu),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Safira',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your travel safety at a glance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Card
            _buildStatusCard(
              context,
              icon: LucideIcons.checkCircle,
              title: 'Current Status',
              subtitle: 'You are in Lucknow, Uttar Pradesh',
              status: 'SAFE',
              statusColor: AppColors.successGreen,
              backgroundColor: AppColors.successGreen,
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildActionCard(
                  icon: LucideIcons.phone,
                  label: 'Emergency Call',
                  color: AppColors.emergencyRed,
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: LucideIcons.map,
                  label: 'Danger Zones',
                  color: AppColors.warningOrange,
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: LucideIcons.qrCode,
                  label: 'Digital ID',
                  color: AppColors.primarySkyBlue,
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: LucideIcons.navigation,
                  label: 'Live Tracking',
                  color: AppColors.primaryDeepBlue,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Safety Features
            Text(
              'Safety Features',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              icon: LucideIcons.mapPin,
              title: 'Location Sharing',
              subtitle: 'Share your location with trusted contacts',
              status: 'ON',
              statusColor: AppColors.successGreen,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              icon: LucideIcons.bell,
              title: 'Alert Notifications',
              subtitle: 'Get notified about nearby dangers',
              status: 'ON',
              statusColor: AppColors.successGreen,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              icon: LucideIcons.users,
              title: 'Emergency Contacts',
              subtitle: '3 contacts configured',
              status: 'SET',
              statusColor: AppColors.primarySkyBlue,
            ),
            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: LucideIcons.checkCircle,
              title: 'KYC Verification Approved',
              timestamp: '2 days ago',
              color: AppColors.successGreen,
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: LucideIcons.mapPin,
              title: 'Entered Safe Zone',
              timestamp: '5 hours ago',
              color: AppColors.primarySkyBlue,
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: LucideIcons.alertCircle,
              title: 'Safety Alert: Avoid this area',
              timestamp: '1 day ago',
              color: AppColors.warningOrange,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.emergencyRed,
        foregroundColor: AppColors.white,
        icon: const Icon(LucideIcons.alertTriangle),
        label: const Text('EMERGENCY SOS'),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor.withOpacity(0.1),
            backgroundColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: backgroundColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: backgroundColor, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.textLight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.textLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String timestamp,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.textLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timestamp,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            color: AppColors.textLight,
            size: 20,
          ),
        ],
      ),
    );
  }
}

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14), // Dark Space
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
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // TOP HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Welcome back,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text("Safira Farheen", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.bell, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // SAFETY STATUS CARD (Glassmorphism)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0E3A7E).withOpacity(0.8),
                          const Color(0xFF0E3A7E).withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("CURRENT STATUS", style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.shield, color: Colors.green, size: 12),
                                  SizedBox(width: 4),
                                  Text("SECURE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text("Lucknow, Uttar Pradesh", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text("No active alerts in your immediate vicinity.", style: TextStyle(color: Colors.white60, fontSize: 13)),
                        const SizedBox(height: 16),
                        _buildQuickAction(Icons.phone_in_talk_rounded, "Emergency Call", "Connect to nearest unit"),
                        const SizedBox(height: 8),
                        _buildQuickAction(Icons.map_rounded, "High-Risk Zones", "View areas to avoid"),
                        const SizedBox(height: 8),
                        _buildQuickAction(Icons.qr_code_scanner_rounded, "Scan Digital ID", "Verify your identity"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // QUICK ACTIONS GRID
                  const Text("EMERGENCY ACTIONS", style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(LucideIcons.shieldAlert, "Request\nSecurity", const Color(0xFFFF4D4D)),
                      _buildActionCard(LucideIcons.utensils, "Food &\nWater", const Color(0xFFFFBF00)),
                      _buildActionCard(Icons.medical_services_outlined, "Medical\nHelp", const Color(0xFF2E7D32)),
                      _buildActionCard(LucideIcons.car, "Safe\nTransport", const Color(0xFF00D2FF)),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // TRACKING PREVIEW (Mock)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("ACTIVE TRACKING", style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                      Text("View Map", style: TextStyle(color: Color(0xFFFF7A00), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: NetworkImage("https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?auto=format&fit=crop&q=80&w=1000"),
                        fit: BoxFit.cover,
                        opacity: 0.4,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildStatCard("Active Tourists", "2,480", Icons.people_outline, Colors.blue),
                              _buildStatCard("Safe Zones", "18 Zones", Icons.verified_user_outlined, Colors.green),
                              _buildStatCard("Alert History", "12 Today", Icons.history, Colors.orange),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // 🔘 EMERGENCY SOS FAB
          Positioned(
            bottom: 30,
            right: 0,
            left: 0,
            child: Center(
              child: Container(
                width: 160,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF4D4D), Color(0xFFD32F2F)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFF4D4D).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.alertTriangle, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text("S.O.S", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 2)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMiniAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
          ),
        ],
      ),
    );
  }
}
