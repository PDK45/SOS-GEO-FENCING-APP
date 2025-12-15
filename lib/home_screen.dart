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
    _startSensors();
    _startGeoFencing();
    
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
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    ).listen((Position position) {
      if (!isMonitoring || app_logic.currentStatus != app_logic.AlertStatus.safe) return;
      
      bool isInside = false;
      for (var zone in app_logic.safeZones) {
        double dist = Geolocator.distanceBetween(position.latitude, position.longitude, zone.latitude, zone.longitude);
        if (dist <= zone.radiusMeters) { isInside = true; break; }
      }

      if (!isInside && app_logic.safeZones.isNotEmpty) {
        app_logic.triggerAlert(reason: 'Geo-Fence Exit');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAlert = app_logic.currentStatus != app_logic.AlertStatus.safe;

    return Scaffold(
      appBar: AppBar(title: const Text('SafeSoul Live Dashboard')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          
          // 1. Status Card
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isAlert ? Colors.red.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isAlert ? Colors.red : Colors.green, width: 2),
            ),
            child: Text(
              isAlert ? "🚨 ALERT ACTIVE 🚨" : "🛡️ SYSTEM SECURE",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isAlert ? Colors.red : Colors.green.shade800),
            ),
          ),

          const SizedBox(height: 20),

          // 2. SOS Button
          GestureDetector(
            onTap: () => setState(() {
              if (isAlert) app_logic.confirmSafety();
              else app_logic.triggerAlert(reason: "Manual SOS Button");
            }),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: isAlert ? Colors.green : Colors.red,
              child: Text(isAlert ? "I AM\nSAFE" : "SOS", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          
          const SizedBox(height: 20),

          // 3. Fake Call Button
          ElevatedButton.icon(
            onPressed: _launchFakeCall,
            icon: const Icon(Icons.call),
            label: const Text("Fake Call"),
          ),

          const Spacer(),

          // 4. HACKATHON CONSOLE (Visual Log)
          Container(
            height: 150,
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.greenAccent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(">> SYSTEM LOGS", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                const Divider(color: Colors.greenAccent, height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: _logScrollController,
                    itemCount: logs.length,
                    itemBuilder: (ctx, i) => Text(
                      logs[i], 
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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