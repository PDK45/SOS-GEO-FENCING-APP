// lib/alert_logic.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Import for Platform check
import 'package:telephony/telephony.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

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

  // Serialization for SharedPreferences
  Map<String, dynamic> toJson() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'radiusKm': radiusKm,
    'startTimeHour': startTimeHour,
    'endTimeHour': endTimeHour,
  };

  factory SafeZone.fromJson(Map<String, dynamic> json) => SafeZone(
    name: json['name'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    radiusKm: json['radiusKm'],
    startTimeHour: json['startTimeHour'],
    endTimeHour: json['endTimeHour'],
  );
}

// Global Variables (Dynamic)
String userName = 'User';
String userBloodGroup = 'Unknown';
String contact1 = ''; 
String contact2 = '';
String authorityContact = '100';

List<SafeZone> safeZones = [];

enum AlertStatus { safe, tier1, tier2, tier3, fakeCall }
AlertStatus currentStatus = AlertStatus.safe;
Timer? alertTimer;

// *** Callback to send logs to the UI ***
Function(String)? onLogUpdate; 

void log(String message) {
  print(message); // Print to debug console
  if (onLogUpdate != null) {
    onLogUpdate!(message); // Send to UI Console
  }
}

// --- Data Persistence ---
Future<void> loadConfig() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Load Profile
  userName = prefs.getString('userName') ?? 'User';
  userBloodGroup = prefs.getString('userBloodGroup') ?? 'Unknown';
  contact1 = prefs.getString('contact1') ?? '';
  contact2 = prefs.getString('contact2') ?? '';
  
  // Load Safe Zones
  List<String>? zoneList = prefs.getStringList('safeZones');
  if (zoneList != null) {
    safeZones = zoneList.map((z) => SafeZone.fromJson(jsonDecode(z))).toList();
  }
  
  log("💾 Configuration Loaded. User: $userName, Zones: ${safeZones.length}");
}

Future<void> updateUser(String name, String phone, String blood) async {
  final prefs = await SharedPreferences.getInstance();
  userName = name;
  userBloodGroup = blood;
  await prefs.setString('userName', name);
  await prefs.setString('userPhone', phone);
  await prefs.setString('userBloodGroup', blood);
  log("👤 User Profile Updated: $name");
}

Future<void> updateContacts(String c1, String c2) async {
  final prefs = await SharedPreferences.getInstance();
  contact1 = c1;
  contact2 = c2;
  await prefs.setString('contact1', c1);
  await prefs.setString('contact2', c2);
  log("📞 Contacts Updated.");
}

Future<void> addSafeZone(SafeZone zone) async {
  final prefs = await SharedPreferences.getInstance();
  safeZones.add(zone);
  
  List<String> zoneList = safeZones.map((z) => jsonEncode(z.toJson())).toList();
  await prefs.setStringList('safeZones', zoneList);
  
  log("📍 Safe Zone Added: ${zone.name}");
}

Future<void> clearSafeZones() async {
  final prefs = await SharedPreferences.getInstance();
  safeZones.clear();
  await prefs.remove('safeZones');
  log("🗑️ Safe Zones Cleared.");
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

  // 3. SEND SMS (Platform Safe)
  if (Platform.isAndroid) {
    final telephony = Telephony.instance;
    
    if (contact1.isNotEmpty) {
      log("📨 Sending SMS to Contact 1 ($contact1)...");
      telephony.sendSms(to: contact1, message: message);
    } else {
      log("⚠️ Contact 1 not set!");
    }
    
    if (contact2.isNotEmpty) {
      log("📨 Sending SMS to Contact 2 ($contact2)...");
      telephony.sendSms(to: contact2, message: message);
    }
    log("✅ SMS Process Completed.");
  } else {
    log("💻 PLATFORM: SMS Simulation Mode (Not Android)");
    log("📝 WOULD SEND: $message");
  }

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
  
  if (Platform.isAndroid) {
     Telephony.instance.sendSms(to: authorityContact, message: message);
     log("🚓 Authority SMS Sent.");
  } else {
     log("💻 PLATFORM: Simulated Authority SMS: $message");
  }
}

void confirmSafety() {
  alertTimer?.cancel();
  currentStatus = AlertStatus.safe;
  log("💚 Safety Confirmed by User. All alerts cancelled.");
}
