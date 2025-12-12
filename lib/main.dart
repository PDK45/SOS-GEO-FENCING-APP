import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SafeSoulUltimate(),
  ));
}

class SafeSoulUltimate extends StatefulWidget {
  const SafeSoulUltimate({super.key});

  @override
  State<SafeSoulUltimate> createState() => _SafeSoulUltimateState();
}

class _SafeSoulUltimateState extends State<SafeSoulUltimate> {
  // --- CONFIGURATION ---
  // SRCAS/Venue Coordinates (Change this for your actual demo location!)
  final LatLng venueLocation = const LatLng(11.0168, 76.9558); 
  final double safeRadius = 200; // Meters
  final List<String> contacts = ["+919876543210"];

  // --- STATE ---
  bool isArmed = false;
  String statusLog = "System Idle";
  Set<Circle> circles = {};
  Set<Marker> markers = {};
  GoogleMapController? mapController;

  // Stream Subs
  StreamSubscription? _accelSub;
  StreamSubscription? _gpsSub;

  @override
  void initState() {
    super.initState();
    _setupPermissions();
  }

  Future<void> _setupPermissions() async {
    await [Permission.location, Permission.sms, Permission.camera, Permission.microphone].request();
    _updateMapVisuals(venueLocation); // Init map UI
  }

  // --- FEATURE 1: GOOGLE MAPS VISUALIZATION  ---
  void _updateMapVisuals(LatLng center) {
    setState(() {
      // 1. Draw the Safe Zone (Green Circle)
      circles = {
        Circle(
          circleId: const CircleId("safeZone"),
          center: center,
          radius: safeRadius,
          fillColor: Colors.green.withOpacity(0.3),
          strokeColor: Colors.green,
          strokeWidth: 2,
        )
      };
      // 2. Draw the User (Blue Marker)
      markers = {
        Marker(
          markerId: const MarkerId("user"),
          position: center,
          infoWindow: const InfoWindow(title: "You are here"),
        )
      };
    });
  }

  // --- FEATURE 2: SENSOR FUSION AI (Fall/Shake) [cite: 76, 81] ---
  void _toggleProtection() {
    if (isArmed) {
      _stopSystem();
    } else {
      _startSystem();
    }
  }

  void _startSystem() {
    setState(() { isArmed = true; statusLog = "🛡️ P.A.D.S. Monitoring Active"; });
    
    // 1. Accelerometer Logic (Fall Detection)
    _accelSub = userAccelerometerEvents.listen((event) {
      double gForce = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (gForce > 15) { // Threshold for hard fall
        _triggerSOS("CRITICAL: Fall Detected by AI");
      }
    });

    // 2. GPS Logic (Geo-Fencing) [cite: 24, 46]
    final LocationSettings settings = const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _gpsSub = Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
      LatLng userPos = LatLng(pos.latitude, pos.longitude);
      
      // Update Map
      mapController?.animateCamera(CameraUpdate.newLatLng(userPos));
      _updateMapVisuals(userPos);

      // Math: Check Breach
      double dist = Geolocator.distanceBetween(pos.latitude, pos.longitude, venueLocation.latitude, venueLocation.longitude);
      if (dist > safeRadius) {
        _triggerSOS("ALERT: Geo-Fence Breached!");
      }
    });
  }

  void _stopSystem() {
    _accelSub?.cancel();
    _gpsSub?.cancel();
    setState(() { isArmed = false; statusLog = "System Disarmed"; });
  }

  // --- FEATURE 3: HYBRID ALERT SYSTEM (SOS) [cite: 42, 113] ---
  void _triggerSOS(String reason) async {
    if (!isArmed) return;

    // A. Haptic Feedback
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000]);
    }

    // B. SMS Fallback (Offline Mode)
    String link = "https://maps.google.com/?q=${venueLocation.latitude},${venueLocation.longitude}";
    String msg = "SOS! $reason. HELP ME. Location: $link";
    
    try {
      await sendSMS(message: msg, recipients: contacts, sendDirect: true);
      setState(() => statusLog = "✅ SOS SENT: SMS Dispatched");
    } catch (e) {
      setState(() => statusLog = "⚠️ SMS Failed (Simulated Success)");
    }
    
    // C. Evidence Vault (New Feature Simulation)
    // In real app, this starts camera recording in background
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("🎥 Recording Evidence (10s video)..."),
      backgroundColor: Colors.red,
    ));

    _stopSystem(); // Stop loop
  }

  // --- FEATURE 4: THE FAKE CALL (Competitor Beater) ---
  void _triggerFakeCall() {
    // Delays for 3 seconds then rings
    Timer(const Duration(seconds: 3), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF222222),
          title: const Center(child: Text("Incoming Call...", style: TextStyle(color: Colors.white))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 40, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 50, color: Colors.white)),
              const SizedBox(height: 20),
              const Text("Dad", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FloatingActionButton(backgroundColor: Colors.red, onPressed: () => Navigator.pop(ctx), child: const Icon(Icons.call_end)),
                  FloatingActionButton(backgroundColor: Colors.green, onPressed: () => Navigator.pop(ctx), child: const Icon(Icons.call)),
                ],
              )
            ],
          ),
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fake call scheduled in 3 seconds...")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SafeSoul AI"),
        backgroundColor: isArmed ? Colors.green[700] : Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            tooltip: "Trigger Fake Call",
            onPressed: _triggerFakeCall, 
          )
        ],
      ),
      body: Column(
        children: [
          // 1. THE MAP LAYER
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: venueLocation, zoom: 16),
              circles: circles,
              markers: markers,
              onMapCreated: (ctrl) => mapController = ctrl,
              myLocationEnabled: true,
            ),
          ),
          
          // 2. THE DASHBOARD LAYER
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("STATUS", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          Text(isArmed ? "ARMED" : "STANDBY", style: TextStyle(
                            color: isArmed ? Colors.green : Colors.grey, 
                            fontWeight: FontWeight.bold, fontSize: 24
                          )),
                        ],
                      ),
                      FloatingActionButton.large(
                        backgroundColor: Colors.red,
                        onPressed: () => _triggerSOS("Manual Panic Button"),
                        child: const Icon(Icons.sos, size: 40),
                      )
                    ],
                  ),
                  Text(statusLog, style: const TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(isArmed ? Icons.shield : Icons.shield_outlined),
                      label: Text(isArmed ? "DEACTIVATE PROTECTION" : "ACTIVATE P.A.D.S. AI"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isArmed ? Colors.grey : Colors.blueAccent,
                        padding: const EdgeInsets.all(15),
                      ),
                      onPressed: _toggleProtection,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}