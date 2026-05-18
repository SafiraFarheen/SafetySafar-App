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
        'accommodation_details': _accommodationCtrl.text,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF0E3A7E),
        actions: [
          _isSaving
              ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))))
              : IconButton(icon: const Icon(Icons.check_rounded), onPressed: _saveProfile),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Personal Details'),
            _buildTextField('Phone Number', _phoneCtrl, TextInputType.phone),
            _buildTextField('Date of Birth (YYYY-MM-DD)', _dobCtrl, TextInputType.datetime),
            _buildTextField('Gender', _genderCtrl, TextInputType.text),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Travel Information'),
            _buildTextField('Arrival Date', _arrivalCtrl, TextInputType.datetime),
            _buildTextField('Departure Date', _departureCtrl, TextInputType.datetime),
            _buildTextField('Accommodation Details', _accommodationCtrl, TextInputType.text),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Emergency Contact'),
            _buildTextField('Emergency Name', _emerNameCtrl, TextInputType.name),
            _buildTextField('Emergency Phone', _emerPhoneCtrl, TextInputType.phone),
            _buildTextField('Relation (e.g. Brother)', _emerRelationCtrl, TextInputType.text),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E3A7E)),
                child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E3A7E)),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
