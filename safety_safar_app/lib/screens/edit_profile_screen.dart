import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_config.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;
  final String authToken;

  const EditProfileScreen({
    super.key,
    required this.currentData,
    required this.authToken,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _genderCtrl;
  late TextEditingController _arrivalCtrl;
  late TextEditingController _departureCtrl;
  late TextEditingController _accommodationCtrl;
  late TextEditingController _emerNameCtrl;
  late TextEditingController _emerPhoneCtrl;
  late TextEditingController _emerRelationCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.currentData;
    _phoneCtrl = TextEditingController(text: d['phone'] ?? '');
    _dobCtrl = TextEditingController(text: d['dob'] ?? '');
    _genderCtrl = TextEditingController(text: d['gender'] ?? '');
    _arrivalCtrl = TextEditingController(text: d['arrival_date'] ?? '');
    _departureCtrl = TextEditingController(text: d['departure_date'] ?? '');
    _accommodationCtrl = TextEditingController(text: d['accommodation'] ?? '');
    _emerNameCtrl = TextEditingController(text: d['emergency_name'] ?? '');
    _emerPhoneCtrl = TextEditingController(text: d['emergency_phone'] ?? '');
    _emerRelationCtrl = TextEditingController(text: d['emergency_relation'] ?? '');
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _genderCtrl.dispose();
    _arrivalCtrl.dispose();
    _departureCtrl.dispose();
    _accommodationCtrl.dispose();
    _emerNameCtrl.dispose();
    _emerPhoneCtrl.dispose();
    _emerRelationCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final body = {
        'phone': _phoneCtrl.text,
        'dob': _dobCtrl.text,
        'gender': _genderCtrl.text,
        'arrival_date': _arrivalCtrl.text,
        'departure_date': _departureCtrl.text,
        'accommodation': _accommodationCtrl.text,
        'emergency_name': _emerNameCtrl.text,
        'emergency_phone': _emerPhoneCtrl.text,
        'emergency_relation': _emerRelationCtrl.text,
      };

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/me'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context, true); // true indicates success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0E3A7E);
    const Color secondaryColor = Color(0xFFFF7A00);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9), // Light background like role selector
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontFamily: 'Outfit')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, Color(0xFF1B5BA8)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Update Information',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryColor,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep your safety profile up to date.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSectionCard(
              title: 'Personal Details',
              icon: Icons.badge_outlined,
              primaryColor: primaryColor,
              children: [
                _buildTextField('Phone Number', _phoneCtrl, TextInputType.phone, Icons.phone_outlined, primaryColor),
                _buildTextField('Date of Birth', _dobCtrl, TextInputType.datetime, Icons.cake_outlined, primaryColor, hint: 'YYYY-MM-DD'),
                _buildTextField('Gender', _genderCtrl, TextInputType.text, Icons.person_outline, primaryColor),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _buildSectionCard(
              title: 'Travel Information',
              icon: Icons.flight_takeoff_outlined,
              primaryColor: primaryColor,
              children: [
                _buildTextField('Arrival Date', _arrivalCtrl, TextInputType.datetime, Icons.flight_land_outlined, primaryColor, hint: 'YYYY-MM-DD'),
                _buildTextField('Departure Date', _departureCtrl, TextInputType.datetime, Icons.flight_takeoff_outlined, primaryColor, hint: 'YYYY-MM-DD'),
                _buildTextField('Accommodation Details', _accommodationCtrl, TextInputType.text, Icons.hotel_outlined, primaryColor),
              ],
            ),
            
            const SizedBox(height: 20),
            
            _buildSectionCard(
              title: 'Emergency Contact',
              icon: Icons.health_and_safety_outlined,
              primaryColor: secondaryColor, // Use secondary color for emergency
              children: [
                _buildTextField('Emergency Name', _emerNameCtrl, TextInputType.name, Icons.contact_emergency_outlined, secondaryColor),
                _buildTextField('Emergency Phone', _emerPhoneCtrl, TextInputType.phone, Icons.phone_in_talk_outlined, secondaryColor),
                _buildTextField('Relation (e.g. Brother)', _emerRelationCtrl, TextInputType.text, Icons.family_restroom_outlined, secondaryColor),
              ],
            ),

            const SizedBox(height: 40),
            
            GestureDetector(
              onTap: _isSaving ? null : _saveProfile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [secondaryColor, Color(0xFFE66E00)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: secondaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _isSaving 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Save Changes', 
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 18, 
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Outfit'
                        )
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Color primaryColor, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: primaryColor,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type, IconData icon, Color themeColor, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, fontFamily: 'Outfit'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontFamily: 'Outfit'),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: themeColor.withOpacity(0.7), size: 22),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
