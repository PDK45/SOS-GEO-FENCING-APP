import 'package:flutter/material.dart';
import 'safe_zone_screen.dart'; // Ensure this line is present and correct
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

  void _saveProfileAndNavigate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // *** PLACEHOLDER for DB SAVING ***
      // In the final app, this is where you insert data into the 'user_profile' and 
      // 'emergency_contacts' tables in SQLite/Firestore.

      print('--- User Profile Saved (SIMULATED) ---');
      print('Name: $_name, Phone: $_phoneNumber, Blood Group: $_bloodGroup');
      print('Contact 1: $_contact1Name, Number: $_contact1Number');
      
      // Navigate to the next screen (Safe Zone Configuration)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SafeZoneScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1. Setup Profile & Contacts')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // User Details Section
              _buildSectionTitle('Personal & Medical Details (Feature 6)'),
              _buildTextFormField(
                label: 'Full Name',
                onSaved: (value) => _name = value,
              ),
              _buildTextFormField(
                label: 'Phone Number (Your Mobile)',
                keyboardType: TextInputType.phone,
                onSaved: (value) => _phoneNumber = value,
              ),
              _buildTextFormField(
                label: 'Blood Group (e.g., A+, O-)',
                onSaved: (value) => _bloodGroup = value,
                validator: (value) => value!.isEmpty ? 'Required for emergency response' : null,
              ),
              const SizedBox(height: 20),

              // Emergency Contacts Section (Feature 4)
              _buildSectionTitle('Emergency Contacts (Tier 2/3 Alerts)'),
              _buildTextFormField(
                label: 'Contact 1 Name',
                onSaved: (value) => _contact1Name = value,
              ),
              _buildTextFormField(
                label: 'Contact 1 Number',
                keyboardType: TextInputType.phone,
                onSaved: (value) => _contact1Number = value,
              ),
              _buildTextFormField(
                label: 'Contact 2 Name',
                onSaved: (value) => _contact2Name = value,
              ),
              _buildTextFormField(
                label: 'Contact 2 Number (Authority/Family)',
                keyboardType: TextInputType.phone,
                onSaved: (value) => _contact2Number = value,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveProfileAndNavigate,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Save Profile & Setup Safe Zone', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required String label,
    Function(String?)? onSaved,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      keyboardType: keyboardType,
      validator: validator ?? (value) => value!.isEmpty ? 'This field is required' : null,
      onSaved: onSaved,
    );
  }
}