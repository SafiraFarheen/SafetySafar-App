import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'screens/authority_login_screen.dart';

class LoginRoleSelectorScreen extends StatelessWidget {
  const LoginRoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0E3A7E); // Deep Blue
    const Color secondaryColor = Color(0xFFFF7A00); // Vibrant Orange
    
    return Scaffold(
      backgroundColor: primaryColor, // Same dark blue as Tourist Login
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // TOP SECTION: Dark Blue Background
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                children: [
                  // Premium Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App Name
                  Text(
                    'Safety Safar',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Outfit',
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tagline
                  Text(
                    'Traveler Safety & Emergency Management',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // BOTTOM SECTION: White Container (Like the Login Screen)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'SELECT YOUR ROLE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
                            letterSpacing: 1.5,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Tourist Card (Primary Blue Focus)
                      _RoleCard(
                        icon: Icons.person_rounded,
                        title: 'I am a Tourist',
                        subtitle: 'Traveler Login',
                        description: 'Access safety features, travel maps, alerts, and emergency services',
                        themeColor: primaryColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Authority Card (Secondary Orange Focus)
                      _RoleCard(
                        icon: Icons.admin_panel_settings_rounded,
                        title: 'I am an Authority',
                        subtitle: 'Government Official',
                        description: 'Authority dashboard, manage tourists, handle incidents and approvals',
                        themeColor: secondaryColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthorityLoginScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Secure & Verified Footer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.lock_person_rounded, color: Colors.green, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Secure & Verified',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: primaryColor,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'All communications are encrypted. Authority accounts require admin verification.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40), // Padding for bottom
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color themeColor;
  final VoidCallback onPressed;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.themeColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      splashColor: themeColor.withOpacity(0.1),
      highlightColor: themeColor.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: themeColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [themeColor, themeColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0E3A7E), // Always use dark blue for title to match theme
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: themeColor,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: themeColor.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}
