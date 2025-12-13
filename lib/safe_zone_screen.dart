// safe_zone_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart'; // We will define this next

class SafeZoneScreen extends StatefulWidget {
  const SafeZoneScreen({super.key});

  @override
  State<SafeZoneScreen> createState() => _SafeZoneScreenState();
}

class _SafeZoneScreenState extends State<SafeZoneScreen> {
  // --- PLACEHOLDER for Geo-Fence Data (Feature 2) ---
  // In the real app, this data would be fetched/stored from the 'safe_zones' table.
  String zoneName = 'Coimbatore Institute of Technology'; //
  String zoneLatitude = '10.9926° N'; 
  String zoneLongitude = '76.9800° E';
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0); // 9:00 AM
  TimeOfDay endTime = const TimeOfDay(hour: 16, minute: 0); // 4:00 PM

  void _completeSetupAndStartMonitoring() {
    // *** PLACEHOLDER for DB SAVING ***
    // Save the safe zone data here.

    print('--- Safe Zone Saved (SIMULATED) ---');
    print('Zone: $zoneName, Time: ${startTime.format(context)} - ${endTime.format(context)}');
    
    // Navigate to the main monitoring screen
    Navigator.pushReplacement( // Use pushReplacement so user can't go back to setup
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2. Safe Zone Setup (Time Rule)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Set a common location and the usual time you are there. The app will use this for Geo-Fencing.',
              style: TextStyle(fontSize: 16),
            ),
            const Divider(),
            
            // Display Placeholder Safe Zone Info
            _buildInfoTile('Location Name', zoneName),
            _buildInfoTile('Coordinates (Simulated)', '$zoneLatitude, $zoneLongitude'),
            
            // Time Rule Pickers (Interactive for simplicity)
            _buildTimePickerTile(
              'Start Time (e.g., when college starts)',
              startTime,
              (TimeOfDay? newTime) {
                if (newTime != null) setState(() => startTime = newTime);
              },
            ),
            _buildTimePickerTile(
              'End Time (e.g., when college ends)',
              endTime,
              (TimeOfDay? newTime) {
                if (newTime != null) setState(() => endTime = newTime);
              },
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: _completeSetupAndStartMonitoring,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Start Safety Monitoring', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildTimePickerTile(String title, TimeOfDay time, Function(TimeOfDay?) onTimePicked) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        time.format(context),
        style: const TextStyle(fontSize: 16, color: Colors.blue),
      ),
      onTap: () async {
        final TimeOfDay? newTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        onTimePicked(newTime);
      },
    );
  }
}