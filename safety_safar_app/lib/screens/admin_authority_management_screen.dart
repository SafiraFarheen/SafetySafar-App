import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_config.dart';

class AdminAuthorityManagementScreen extends StatefulWidget {
  final String authToken;

  const AdminAuthorityManagementScreen({
    super.key,
    required this.authToken,
  });

  @override
  State<AdminAuthorityManagementScreen> createState() =>
      _AdminAuthorityManagementScreenState();
}

class _AdminAuthorityManagementScreenState
    extends State<AdminAuthorityManagementScreen> {
  List<Map<String, dynamic>> _pendingAuthorities = [];
  bool _isLoading = true;
  Map<String, dynamic>? _expandedAuthority;
  final Map<String, TextEditingController> _departmentControllers = {};
  final Map<String, String> _selectedRoles = {};
  
  static const Color _primaryColor = Color(0xFF0E3A7E);
  static const Color _secondaryColor = Color(0xFFFF7A00);
  static const Color _backgroundColor = Color(0xFFF4F7F9);

  @override
  void initState() {
    super.initState();
    _loadPendingAuthorities();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _departmentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPendingAuthorities() async {
    try {
      setState(() => _isLoading = true);
      final response = await http.get(
        Uri.parse(ApiConfig.pendingAuthorities),
        headers: {'Authorization': 'Bearer ${widget.authToken}'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _pendingAuthorities = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        if (mounted) {
          _showError('Failed to load pending authorities');
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveAuthority(String userId) async {
    String department = _departmentControllers[userId]?.text.trim() ?? '';
    final role = _selectedRoles[userId] ?? 'authority';

    // Log current controller text for debugging
    final controllerText = _departmentControllers[userId]?.text;
    debugPrint('Approve attempt for user=$userId controllerText="$controllerText"');

    // If controller is empty, fallback to server-provided department value
    String fallbackDept = '';
    try {
      final fallback = _pendingAuthorities.firstWhere(
        (a) => (a['id'] as String) == userId,
        orElse: () => {},
      );
      if (fallback is Map && fallback['department'] != null) {
        fallbackDept = (fallback['department'] as String).trim();
      }
    } catch (_) {}

    debugPrint('Fallback department for user=$userId is "$fallbackDept"');

    if (department.isEmpty && fallbackDept.isNotEmpty) {
      department = fallbackDept;
    }

    if (department.isEmpty) {
      _showError('Department is required - please enter a department name');
      return;
    }

    debugPrint('Approving user=$userId department="$department" role="$role"');

    try {
      setState(() => _isLoading = true);
      final response = await http.post(
        Uri.parse(ApiConfig.authorityApprove(userId)),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'department': department,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess('Authority approved successfully');
        // Clean up controllers
        _departmentControllers[userId]?.dispose();
        _departmentControllers.remove(userId);
        _selectedRoles.remove(userId);
        _loadPendingAuthorities();
        setState(() => _expandedAuthority = null);
      } else {
        final data = jsonDecode(response.body);
        String errorMessage = 'Failed to approve authority';
        
        if (data['detail'] != null) {
          final detail = data['detail'];
          if (detail is String) {
            errorMessage = detail;
          } else if (detail is List) {
            // Handle validation errors as list
            errorMessage = (detail as List)
                .map((e) => e is Map ? e['msg'] ?? 'Error' : e.toString())
                .join(', ');
          }
        }
        
        _showError(errorMessage);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        title: const Text(
          'Manage Authorities',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            )
          : _pendingAuthorities.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _primaryColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _primaryColor.withAlpha(60),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _primaryColor.withAlpha(40),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                size: 20,
                                color: _primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_pendingAuthorities.length} pending approval${_pendingAuthorities.length != 1 ? 's' : ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: _primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Outfit',
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._pendingAuthorities.map(
                        (authority) => _buildAuthorityCard(authority),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _primaryColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 40,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'All Caught Up!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _primaryColor,
              fontWeight: FontWeight.w700,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending authority approvals',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorityCard(Map<String, dynamic> authority) {
    final userId = authority['id'] as String;
    final isExpanded = _expandedAuthority?['id'] == userId;
    
    // Ensure controller exists
    if (!_departmentControllers.containsKey(userId)) {
      final ctrl = TextEditingController();
      // Add listener so UI updates with current text for debugging
      ctrl.addListener(() {
        if (mounted) setState(() {});
      });
      _departmentControllers[userId] = ctrl;
    }
    if (!_selectedRoles.containsKey(userId)) {
      _selectedRoles[userId] = 'authority';
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _expandedAuthority = isExpanded ? null : authority;
              // When expanding, prefill department and role from server data
              if (!isExpanded) {
                final dept = authority['department'] as String? ?? '';
                _departmentControllers[userId]?.text = dept;
                _selectedRoles[userId] = authority['role'] as String? ?? 'authority';
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpanded ? _secondaryColor : Colors.grey[300]!,
                width: isExpanded ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isExpanded
                      ? _secondaryColor.withAlpha(30)
                      : Colors.black.withAlpha(8),
                  blurRadius: isExpanded ? 12 : 4,
                  offset: isExpanded ? const Offset(0, 6) : const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_primaryColor, Color(0xFF1B5BA8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (authority['first_name'] ?? '')[0]
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${authority['first_name']} ${authority['last_name']}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _primaryColor,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authority['email'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            authority['phone'] as String? ?? 'N/A',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: _primaryColor,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _secondaryColor.withAlpha(100),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Department Field
                Row(
                  children: [
                    Text(
                      'Department',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '*',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _departmentControllers[userId],
                  style: const TextStyle(fontFamily: 'Outfit'),
                  decoration: InputDecoration(
                    hintText: 'Enter department (e.g., Police, Tourism, Health)',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'Outfit',
                    ),
                    prefixIcon:
                        const Icon(Icons.business, color: _primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // DEBUG: show current controller text and server fallback
                Builder(builder: (_) {
                  final current = _departmentControllers[userId]?.text ?? '';
                  final server = authority['department'] as String? ?? '';
                  return Text(
                    'DEBUG: field="$current" server="$server"',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[500], fontFamily: 'Outfit'),
                  );
                }),
                const SizedBox(height: 16),

                // Role Dropdown
                Row(
                  children: [
                    Text(
                      'Role',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '*',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRoles[userId] ?? 'authority',
                  items: const [
                    DropdownMenuItem(
                      value: 'authority',
                      child: Text('Authority (Regular)'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Admin (Full Access)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _selectedRoles[userId] = value;
                      setState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.shield, color: _primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Approve Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_primaryColor, Color(0xFF1B5BA8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _approveAuthority(userId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                    Colors.white),
                              ),
                            )
                          : const Text(
                              'Approve Authority',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Outfit',
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}
