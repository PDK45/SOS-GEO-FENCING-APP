// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

import 'alert_logic.dart'; // Import the core alert logic

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _accelerometerSubscription;
  bool isMonitoring = true; // Use this to toggle monitoring

  @override
  void initState() {
    super.initState();
    _startBackgroundMonitoring();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  // --- Feature 3: Shake Detection Logic ---
  void _startBackgroundMonitoring() {
    // Listen to accelerometer events for shake detection (Feature 3)
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (!isMonitoring) return;

      double x = event.x;
      double y = event.y;
      double z = event.z;
      
      // Simple shake detection logic: rapid change in total acceleration
      // A more robust shake detection tracks peaks and valleys.
      if ((x.abs() > 25.0 || y.abs() > 25.0 || z.abs() > 25.0) && currentStatus == AlertStatus.safe) {
        // Debounce: ensure only one alert is triggered per event
        setState(() {
            triggerAlert(reason: 'Panic Shake Gesture');
        });
      }
      
      // We will add the Basic Fall Detection (Feature 5) logic here later.
    });
  }

  // Helper to visually update the status
  void _updateStatus() {
    setState(() {}); // Rebuilds the UI to reflect the currentStatus change
  }

  @override
  Widget build(BuildContext context) {
    // Re-check status from external logic file
    if (currentStatus != AlertStatus.safe) {
      // Re-initialize timer if the app was backgrounded/reopened 
      // (Advanced: requires lifecycle management, simple solution for prototype: update status)
      if (currentStatus == AlertStatus.tier1 && alertTimer?.isActive == false) {
        // If the timer expired while the app was closed, force escalation (simple recovery)
        WidgetsBinding.instance.addPostFrameCallback((_) => escalateToTier2());
      }
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('3. Safety Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Current Safety Status
            _buildSafetyStatusIndicator(),
            
            const SizedBox(height: 50),

            // Large SOS Button (Manual Activation)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (currentStatus == AlertStatus.safe) {
                    triggerAlert(reason: 'Manual Button Press');
                  } else {
                    confirmSafety(); // Manual Tap cancels the alert if active
                  }
                });
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentStatus == AlertStatus.safe ? Colors.red : Colors.green,
                  boxShadow: [
                    BoxShadow(
                      color: (currentStatus != AlertStatus.safe ? Colors.green.shade900 : Colors.red.shade900).withOpacity(0.5),
                      spreadRadius: 8,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    currentStatus == AlertStatus.safe ? 'SOS\nTAP TO START' : 'SAFETY CONFIRMED\nTAP TO CANCEL',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Tier 1 Confirmation UI (Feature 4)
            if (currentStatus == AlertStatus.tier1) 
              _buildConfirmationBar(context),
              
            if (currentStatus == AlertStatus.tier2 || currentStatus == AlertStatus.tier3)
              const Text('ALERT SENT! Emergency contacts have been notified.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),

            // Geo-Fence Status Placeholder
            const SizedBox(height: 20),
            Text('Geo-Fence Monitoring: ${isMonitoring ? 'Active' : 'Inactive'}', style: TextStyle(color: isMonitoring ? Colors.green : Colors.grey)),
            Text('Current Status: ${currentStatus.name.toUpperCase()}', style: TextStyle(color: currentStatus != AlertStatus.safe ? Colors.red : Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyStatusIndicator() {
    String statusText;
    Color color;

    switch (currentStatus) {
      case AlertStatus.safe:
        statusText = 'You are SAFE. Monitoring Active.';
        color = Colors.green;
        break;
      case AlertStatus.tier1:
        statusText = 'SAFETY CHECK: Tap to confirm you are safe!';
        color = Colors.orange;
        break;
      case AlertStatus.tier2:
        statusText = 'TIER 2 ALERT: Contacts Notified. Police Alert in ${alertTimer?.tick ?? 0}s.';
        color = Colors.red.shade700;
        break;
      case AlertStatus.tier3:
        statusText = 'TIER 3 ALERT: Authorities Notified.';
        color = Colors.red.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(statusText, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildConfirmationBar(BuildContext context) {
    // Simple bar to visualize the 5-minute confirmation window
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.yellow.shade100,
      child: Column(
        children: [
          const Text('AUTOMATIC ALERT TRIGGERED', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const Text('Confirm safety within 5 minutes or contacts will be notified.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          // In a final app, this would be a real countdown bar.
          LinearProgressIndicator(
            value: 0.5, // Placeholder for demonstration
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ],
      ),
    );
  }
}