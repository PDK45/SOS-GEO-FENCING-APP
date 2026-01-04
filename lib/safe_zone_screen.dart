// safe_zone_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'home_screen.dart'; 
import 'alert_logic.dart' as app_logic;

class SafeZoneScreen extends StatefulWidget {
  const SafeZoneScreen({super.key});

  @override
  State<SafeZoneScreen> createState() => _SafeZoneScreenState();
}

class _SafeZoneScreenState extends State<SafeZoneScreen> {
  // Real Data
  final TextEditingController _zoneNameController = TextEditingController(text: 'College');
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 16, minute: 0); 

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Location Secured!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _completeSetupAndStartMonitoring() async {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Please fetch location first!")));
      return;
    }

    // Save to Logic
    final newZone = app_logic.SafeZone(
      name: _zoneNameController.text.isEmpty ? 'Safe Zone' : _zoneNameController.text,
      latitude: _latitude!,
      longitude: _longitude!,
      radiusKm: 2.0, // Default 2km radius
      startTimeHour: startTime.hour,
      endTimeHour: endTime.hour,
    );

    await app_logic.addSafeZone(newZone);

    print('--- Safe Zone Saved (REAL) ---');
    print('Zone: ${newZone.name}, Coords: ${_latitude}, ${_longitude}');
    
    if(!mounted) return;

    // Navigate to the main monitoring screen
    Navigator.pushReplacement( 
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Safe Zone')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
               const Padding(
                 padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                 child: Text(
                   "Location & Time Data",
                   style: TextStyle(fontSize: 13, color: Color(0xFF6E6E73)),
                 ),
               ),
               
               // Location Group
               Container(
                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                 child: Column(
                   children: [
                     TextField(
                       controller: _zoneNameController,
                       decoration: const InputDecoration(
                         labelText: 'Zone Name (e.g. Home)',
                         border: InputBorder.none,
                         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                       ),
                     ),
                     const Divider(height: 1, indent: 16),
                     ListTile(
                       title: Text(_latitude != null ? "Location Set" : "Set Location"),
                       subtitle: Text(_latitude != null ? "$_latitude, $_longitude" : "Required"),
                       trailing: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.location_on, color: _latitude != null ? Colors.green : Colors.grey),
                       onTap: _isLoading ? null : _fetchCurrentLocation,
                     ),
                   ],
                 ),
               ),
               
               const SizedBox(height: 25),
               const Padding(
                 padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                 child: Text("Active Hours", style: TextStyle(fontSize: 13, color: Color(0xFF6E6E73))),
               ),

               // Time Group
               Container(
                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                 child: Column(
                   children: [
                     _buildTimeRow('Start Time', startTime, (t) => setState(() => startTime = t!)),
                     const Divider(height: 1, indent: 16),
                     _buildTimeRow('End Time', endTime, (t) => setState(() => endTime = t!)),
                   ],
                 ),
               ),

               const SizedBox(height: 40),
               
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: _completeSetupAndStartMonitoring,
                   style: ElevatedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     backgroundColor: const Color(0xFF34C759), // iOS Green
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                   ),
                   child: const Text('Start Monitoring', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(String title, TimeOfDay time, Function(TimeOfDay?) onPicked) {
    return ListTile(
      title: Text(title),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(time.format(context), style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) onPicked(t);
      },
    );
  }
}
