// lib/alert_logic.dart

import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Shared Data ---
class SafeZone {
  final String name;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final int startTimeHour;
  final int endTimeHour;

  SafeZone({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radiusKm = 4.0,
    this.startTimeHour = 0,
    this.endTimeHour = 24,
  });
  double get radiusMeters => radiusKm * 1000;
}

// Global Variables
String userName = 'User';
String userBloodGroup = 'A+';
String contact1 = '7448346783'; // Replace with real number for demo
String contact2 = '8072564784';
String authorityContact = '100';

List<SafeZone> safeZones = [
  SafeZone(name: 'College (Default)', latitude: 10.9926, longitude: 76.9800, radiusKm: 4.0),
];

enum AlertStatus { safe, tier1, tier2, tier3, fakeCall }
AlertStatus currentStatus = AlertStatus.safe;
Timer? alertTimer;

// *** NEW: Callback to send logs to the UI ***
Function(String)? onLogUpdate; 

void log(String message) {
  print(message); // Print to debug console
  if (onLogUpdate != null) {
    onLogUpdate!(message); // Send to UI Console
  }
}

// --- Feature 1: Location & Offline SMS ---
Future<String> getLocationLink() async {
  log("📍 Fetching precise GPS location...");
  try {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    double lat = position.latitude;
    double long = position.longitude;

    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_lat', lat);
    await prefs.setDouble('last_long', long);
    
    log("✅ Location Secured: $lat, $long");
    return 'geo:$lat,$long';
  } catch (e) {
    log("⚠️ GPS Failed. Retrieving Last Known Location...");
    final prefs = await SharedPreferences.getInstance();
    double? lastLat = prefs.getDouble('last_lat');
    double? lastLong = prefs.getDouble('last_long');
    if (lastLat != null) return 'geo:$lastLat,$lastLong (Last Known)';
    return "Location unavailable";
  }
}

// --- Feature: Fake Call ---
void triggerFakeCall() {
  currentStatus = AlertStatus.fakeCall;
  log("📞 Fake Call Sequence Initiated (10s delay)...");
}

// --- UPDATED: INSTANT SMS TRIGGER ---
void triggerAlert({required String reason}) async {
  if (currentStatus != AlertStatus.safe) return; 

  currentStatus = AlertStatus.tier1;
  log("🚨 ALERT TRIGGERED: $reason");
  log("⚡ INSTANT MODE: Preparing SMS for contacts...");

  // 1. Get Location
  String locationLink = await getLocationLink();

  // 2. Draft Message
  String message = 
      'SOS! $userName needs help!\n'
      'Reason: $reason\n'
      'Blood: $userBloodGroup\n'
      'Loc: $locationLink';

  // 3. SEND SMS IMMEDIATELY (No Timer)
  final telephony = Telephony.instance;
  log("📨 Sending SMS to Contact 1 ($contact1)...");
  telephony.sendSms(to: contact1, message: message);
  
  log("📨 Sending SMS to Contact 2 ($contact2)...");
  telephony.sendSms(to: contact2, message: message);
  
  log("✅ SMS Sent Successfully to all contacts.");
  log("⏳ Police Escalation Timer started (10 mins).");

  // 4. Start Timer ONLY for Police Escalation (Tier 3)
  alertTimer = Timer(const Duration(minutes: 10), () {
      escalateToTier3();
  });
}

void escalateToTier3() async {
  alertTimer?.cancel();
  currentStatus = AlertStatus.tier3;
  log("🚔 TIER 3 ESCALATION: Contacting Authorities...");
  
  String locationLink = await getLocationLink(); 
  String message = 'POLICE ALERT: $userName Critical. Loc: $locationLink. Dispatch immediately.';
  
  Telephony.instance.sendSms(to: authorityContact, message: message);
  log("🚓 Authority SMS Sent.");
}

void confirmSafety() {
  alertTimer?.cancel();
  currentStatus = AlertStatus.safe;
  log("💚 Safety Confirmed by User. All alerts cancelled.");
}