# Professional Home Screen Example (For Reference)

## This shows how to redesign your home_screen.dart

```dart
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
            // Hello Banner
            Text(
              'Welcome, Safira',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Stay safe on your travels',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 24),

            // Status Card
            _buildStatusCard(
              icon: LucideIcons.checkCircle,
              title: 'Current Status',
              subtitle: 'You are in a safe zone',
              status: 'SAFE',
              statusColor: AppColors.successGreen,
            ),
            const SizedBox(height: 16),

            // Quick Actions Section
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
                  icon: LucideIcons.navigation,
                  label: 'Location',
                  color: AppColors.primarySkyBlue,
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: LucideIcons.alertTriangle,
                  label: 'Emergency',
                  color: AppColors.emergencyRed,
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: LucideIcons.map,
                  label: 'Attractions',
                  color: AppColors.amberGold,
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: LucideIcons.users,
                  label: 'Contacts',
                  color: AppColors.primaryDeepBlue,
                  onTap: () {},
                ),
              ],
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
              title: 'Location Updated',
              timestamp: '5 hours ago',
              color: AppColors.primarySkyBlue,
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: LucideIcons.alertCircle,
              title: 'Alert: Avoid this area',
              timestamp: '1 day ago',
              color: AppColors.warningOrange,
            ),
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

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
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
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 28),
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
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
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
```

---

## Key Professional Features in This Design:

✅ **Clean AppBar** - Professional header with actions
✅ **Status Indicator** - Visual feedback on user status
✅ **Quick Actions Grid** - Easy access to features
✅ **Activity History** - Recent user actions
✅ **Floating Action Button** - Emergency SOS prominent
✅ **Professional Spacing** - Consistent 20, 16, 12px gaps
✅ **Color Coding** - Each action has semantic color
✅ **Icons** - Modern Lucide icons throughout
✅ **Cards** - Proper elevation and borders
✅ **Gradients** - Subtle background gradients
✅ **Responsive** - Works on all screen sizes

---

## How to Implement:

1. Copy this code to your `home_screen.dart`
2. Replace your home_screen.dart content with this
3. Make sure `app_colors.dart` is imported
4. Run `flutter pub get`
5. Test on your device

