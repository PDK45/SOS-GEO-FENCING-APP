import 'package:flutter/material.dart';
import 'safe_zone_screen.dart'; 
import 'alert_logic.dart' as app_logic; // Import logic

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- 1. User Profile Data (Feature 6) ---
  String? _name;
  String? _phoneNumber;
  String? _bloodGroup;

  // --- 2. Emergency Contacts Data (Feature 4) ---
  String? _contact1Name;
  String? _contact1Number;
  String? _contact2Name;
  String? _contact2Number;

  void _saveProfileAndNavigate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Save Real Data to Logic & Persistence
      await app_logic.updateUser(_name!, _phoneNumber!, _bloodGroup!);
      await app_logic.updateContacts(_contact1Number!, _contact2Number!);

      print('--- User Profile Saved (REAL) ---');
      print('Name: $_name, Blood: $_bloodGroup');
      print('Contacts Updated: $_contact1Number, $_contact2Number');
      
      if (!mounted) return;

      // Navigate to the next screen (Safe Zone Configuration)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SafeZoneScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 10),
                const Text(
                  "Welcome to SafeSoul",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Configure your safety protocols",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 30),

                // User Details Section
                _buildSectionHeader('YOUR IDENTITY'),
                _buildIOSGroup([
                    _buildIOSTextField(label: 'Full Name', onSaved: (v) => _name = v),
                    const Divider(height: 1, indent: 16),
                    _buildIOSTextField(label: 'Phone Number', inputType: TextInputType.phone, onSaved: (v) => _phoneNumber = v),
                    const Divider(height: 1, indent: 16),
                    _buildIOSTextField(label: 'Blood Group', onSaved: (v) => _bloodGroup = v, isLast: true),
                ]),
                const SizedBox(height: 25),

                // Emergency Contacts Section
                _buildSectionHeader('EMERGENCY CONTACTS'),
                _buildIOSGroup([
                   _buildIOSTextField(label: 'Contact 1 Name', onSaved: (v) => _contact1Name = v),
                   const Divider(height: 1, indent: 16),
                   _buildIOSTextField(label: 'Contact 1 Number', inputType: TextInputType.phone, onSaved: (v) => _contact1Number = v),
                ]),
                const SizedBox(height: 15),
                _buildIOSGroup([
                   _buildIOSTextField(label: 'Contact 2 Name', onSaved: (v) => _contact2Name = v),
                   const Divider(height: 1, indent: 16),
                   _buildIOSTextField(label: 'Contact 2 Number', inputType: TextInputType.phone, onSaved: (v) => _contact2Number = v, isLast: true),
                ]),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _saveProfileAndNavigate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, color: Color(0xFF6E6E73), fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget _buildIOSGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildIOSTextField({
    required String label, 
    TextInputType inputType = TextInputType.text,
    required Function(String?) onSaved,
    bool isLast = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(color: Colors.black54),
      ),
      keyboardType: inputType,
      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      onSaved: onSaved,
    );
  }
}
