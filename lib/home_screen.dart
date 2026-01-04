// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'alert_logic.dart' as app_logic; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _accelSub;
  StreamSubscription? _geoSub;
  bool isMonitoring = true; 
  
  // Console Logs List
  List<String> logs = ["System Initialized...", "Monitoring Active."];
  ScrollController _logScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeApp();
    
    // Connect the Logic Log to this UI
    app_logic.onLogUpdate = (String message) {
      if (mounted) {
        setState(() {
          logs.add("${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second} > $message");
          // Auto-scroll to bottom
          Future.delayed(const Duration(milliseconds: 100), () {
             if (_logScrollController.hasClients) {
               _logScrollController.animateTo(
                 _logScrollController.position.maxScrollExtent, 
                 duration: const Duration(milliseconds: 300), 
                 curve: Curves.easeOut);
             }
          });
        });
      }
    };

    Timer.periodic(const Duration(seconds: 1), (timer) { if(mounted) setState((){}); });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _geoSub?.cancel();
    super.dispose();
  }

  void _launchFakeCall() {
    app_logic.triggerFakeCall(); 
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fake Call in 10s...")));
    Future.delayed(const Duration(seconds: 10), () {
      if(mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => const FakeCallScreen()));
    });
  }

  Future<void> _initializeApp() async {
    await app_logic.loadConfig();
    _startSensors();
    _startGeoFencing();
  }

  void _startSensors() {
    _accelSub = accelerometerEvents.listen((event) {
      if (!isMonitoring) return;
      double magnitude = (event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > 600.0 && app_logic.currentStatus == app_logic.AlertStatus.safe) { 
        app_logic.triggerAlert(reason: 'Panic Shake');
      }
    });
  }

  void _startGeoFencing() {
    _geoSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 50),
    ).listen((Position position) {
      if (!isMonitoring || app_logic.currentStatus != app_logic.AlertStatus.safe) return;
      
      // 1. Identify Active Zones (based on Time)
      int currentHour = DateTime.now().hour;
      List<app_logic.SafeZone> activeZones = app_logic.safeZones.where((z) {
        return currentHour >= z.startTimeHour && currentHour < z.endTimeHour;
      }).toList();

      // If no zones are active right now (e.g. it's night time and no restrictions), do nothing.
      if (activeZones.isEmpty) return;

      // 2. Check if inside ANY active zone
      bool isSafe = false;
      for (var zone in activeZones) {
        double dist = Geolocator.distanceBetween(position.latitude, position.longitude, zone.latitude, zone.longitude);
        if (dist <= zone.radiusMeters) { 
          isSafe = true; 
          break; // Found one safe zone we are in
        }
      }

      // 3. Trigger Alert if NOT in any active zone
      if (!isSafe) {
        app_logic.triggerAlert(reason: 'Geo-Fence Exit (${activeZones.length} active zones)');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAlert = app_logic.currentStatus != app_logic.AlertStatus.safe;
    Color statusColor = isAlert ? const Color(0xFFFF3B30) : const Color(0xFF34C759); // iOS Red/Green

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(title: const Text('Dashboard', style: TextStyle(color: Colors.black))),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              
              // 1. Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isAlert ? Icons.warning_amber_rounded : Icons.shield_rounded, color: statusColor),
                    const SizedBox(width: 8),
                    Text(
                      isAlert ? "SYSTEM ALERT" : "SYSTEM SECURE",
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 2. SOS Button (Pulsing)
              GestureDetector(
                onTap: () {
                   setState(() {
                     if (isAlert) app_logic.confirmSafety();
                     else app_logic.triggerAlert(reason: "Manual SOS Button");
                   });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.4), 
                        blurRadius: isAlert ? 50 : 30, // Glow effect
                        spreadRadius: isAlert ? 10 : 0
                      ),
                      BoxShadow(color: Colors.white.withOpacity(0.8), offset: const Offset(-5, -5), blurRadius: 20), // Top lighting
                    ],
                    gradient: LinearGradient(
                      colors: isAlert 
                        ? [const Color(0xFFFF453A), const Color(0xFFFF3B30)]
                        : [const Color(0xFF34C759), const Color(0xFF30B34D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isAlert ? "I'M SAFE" : "SOS",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 40, 
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)]
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              Text(isAlert ? "Tap to cancel alert" : "Top to trigger emergency", style: const TextStyle(color: Colors.grey)),

              const Spacer(),

              // 3. Grid Controls
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(Icons.phone_in_talk, "Fake Call", _launchFakeCall),
                    const SizedBox(width: 20),
                    _buildControlButton(Icons.map, "Map View", () {}), // Placeholder
                  ],
                ),
              ),
              
              const SizedBox(height: 120), // Space for Console
            ],
          ),

          // 4. HUD Console (Bottom Sheet style)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 110,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 5))],
                border: Border.all(color: Colors.white12),
              ),
              child: ListView.builder(
                controller: _logScrollController,
                itemCount: logs.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(logs[i], style: const TextStyle(color: Color(0xFF00FF00), fontSize: 11, fontFamily: 'Courier')),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Icon(icon, color: const Color(0xFF007AFF), size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// --- FAKE CALL SCREEN ---
class FakeCallScreen extends StatelessWidget {
  const FakeCallScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Icon(Icons.person, size: 80, color: Colors.white),
             const SizedBox(height: 20),
             const Text("Mom", style: TextStyle(color: Colors.white, fontSize: 32)),
             const Text("Mobile", style: TextStyle(color: Colors.white54)),
             const SizedBox(height: 100),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 FloatingActionButton(onPressed: () => Navigator.pop(context), backgroundColor: Colors.red, child: const Icon(Icons.call_end)),
                 FloatingActionButton(onPressed: () => Navigator.pop(context), backgroundColor: Colors.green, child: const Icon(Icons.call)),
               ],
             )
          ],
        ),
      ),
    );
  }
}