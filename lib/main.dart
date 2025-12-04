import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GeoFenceAIHome(),
  ));
}

class GeoFenceAIHome extends StatefulWidget {
  const GeoFenceAIHome({super.key});

  @override
  State<GeoFenceAIHome> createState() => _GeoFenceAIHomeState();
}

class _GeoFenceAIHomeState extends State<GeoFenceAIHome> {
  // --- CONFIGURATION (The "Settings" of your prototype) ---
  
  // 1. TARGET SAFE ZONE (Coordinates for Demo)
  // Tip: Change this to your current location right before the demo!
  final double safeLat = 11.0168; // Example: Coimbatore
  final double safeLng = 76.9558;
  final double safeRadiusMeters = 50.0; // Small radius for easy demo breach
  
  // 2. EMERGENCY CONTACT (For SMS Fallback)
  // REPLACE THIS with your own phone number for the demo to show the SMS arriving.
  final List<String> emergencyContacts = ["+919876543210"]; 

  // --- SYSTEM STATE ---
  String systemLog = "System Initializing...";
  String liveLocationInfo = "Waiting for GPS...";
  bool isArmed = false; // Is the system currently protecting?
  
  StreamSubscription? _accelerometerSub;
  StreamSubscription? _gpsSub;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  // --- TECH STACK COMPONENT 1: PERMISSIONS ---
  Future<void> _checkPermissions() async {
    // We need Location (for GeoFence) and SMS (for Offline Alert)
    await [
      Permission.location,
      Permission.sms,
      Permission.notification
    ].request();
    setState(() => systemLog = "Permissions Ready. System Idle.");
  }

  // --- TECH STACK COMPONENT 2: THE LOGIC CONTROLLER ---
  void _toggleProtection() {
    if (isArmed) {
      // STOP MONITORING
      _accelerometerSub?.cancel();
      _gpsSub?.cancel();
      setState(() {
        isArmed = false;
        systemLog = "System Disarmed.";
        liveLocationInfo = "Tracking Paused";
      });
    } else {
      // START MONITORING
      setState(() {
        isArmed = true;
        systemLog = "ARMED: Monitoring Sensors & Location...";
      });
      _startSensorFusion();
    }
  }

  void _startSensorFusion() {
    _startShakeDetection(); // Start Accelerometer
    _startGeoFencing();     // Start GPS
  }

  // --- TECH STACK COMPONENT 3: ANOMALY DETECTION (ACCELEROMETER) ---
  // Implements: "Sudden acceleration / fall detection" logic
  void _startShakeDetection() {
    _accelerometerSub = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      // Calculate total force (G-force vector)
      double force = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      // THRESHOLD: If force > 15 (hard shake/fall), trigger SOS
      if (force > 15) { 
        _triggerEmergencyProtocol("CRITICAL: Fall/Impact Detected!");
      }
    });
  }

  // --- TECH STACK COMPONENT 4: SMART GEO-FENCING (GPS) ---
  // Implements: "Geo-fencing lets users set a safe zone" logic
  void _startGeoFencing() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
    );

    _gpsSub = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      
      // Math: Calculate distance between User and Safe Zone Center
      double distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, safeLat, safeLng);

      setState(() {
        liveLocationInfo = "Dist from Safe Zone: ${distance.toStringAsFixed(1)}m";
      });

      // LOGIC: If Distance > Radius, BREACH DETECTED
      if (distance > safeRadiusMeters) {
        _triggerEmergencyProtocol("ALERT: Safe Zone Breached!");
      }
    });
  }

  // --- TECH STACK COMPONENT 5: OFFLINE ALERT SYSTEM (SMS) ---
  // Implements: "SMS fallback... ensures high reliability"
  void _triggerEmergencyProtocol(String reason) async {
    // Debounce: If already disarmed, don't spam
    if (!isArmed) return; 

    // 1. Local Haptic Alert (Vibrate phone)
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }
    
    // 2. Update UI
    setState(() => systemLog = "TRIGGERING SOS: $reason");

    // 3. Construct Payload
    // In a real app, this link would be your specific map dashboard
    String payload = "SOS ALERT! $reason. \n"
        "User needs help immediately. \n"
        "Approx Location: https://maps.google.com/?q=$safeLat,$safeLng";
    
    // 4. Send SMS (The Offline Fallback)
    _sendOfflineSMS(payload);
    
    // 5. Safety Shutdown (Stop loop)
    _toggleProtection(); 
  }

  void _sendOfflineSMS(String msg) async {
    try {
      String result = await sendSMS(
          message: msg, 
          recipients: emergencyContacts, 
          sendDirect: true // Tries to send in background without opening app
      );
      setState(() => systemLog += "\n✅ SMS Sent Successfully: $result");
    } catch (error) {
      setState(() => systemLog += "\n❌ SMS Failed: $error");
    }
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    _gpsSub?.cancel();
    super.dispose();
  }

  // --- UI: VISUAL INTERFACE ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isArmed ? Colors.green.shade50 : Colors.white,
      appBar: AppBar(
        title: const Text("GeoFence.AI Prototype"),
        backgroundColor: isArmed ? Colors.green : Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. VISUAL STATUS
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isArmed ? Icons.shield_outlined : Icons.gpp_bad_outlined,
                    size: 60,
                    color: isArmed ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isArmed ? "SYSTEM ARMED" : "SYSTEM OFFLINE",
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      color: isArmed ? Colors.green[800] : Colors.grey[600]
                    ),
                  ),
                  const Divider(),
                  Text(
                    liveLocationInfo,
                    style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. SYSTEM LOGS (Console output on screen for Judges)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.black87,
                child: SingleChildScrollView(
                  child: Text(
                    systemLog,
                    style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. CONTROLS
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _toggleProtection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isArmed ? Colors.red : Colors.blueAccent,
                ),
                icon: Icon(isArmed ? Icons.stop_circle : Icons.play_circle_fill),
                label: Text(
                  isArmed ? "STOP MONITORING" : "ACTIVATE SAFETY PROTOCOLS",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}