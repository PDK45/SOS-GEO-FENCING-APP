// lib/alert_logic.dart

import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:geolocator/geolocator.dart';

// --- Shared Data Structure (Simulated Database) ---
// This data will be set from the Login and Safe Zone screens
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
    required this.radiusKm,
    required this.startTimeHour,
    required this.endTimeHour,
  });
  
  double get radiusMeters => radiusKm * 1000;
}

// Global Variables to hold app state and user data
String userName = 'User Name Placeholder'; 
String userBloodGroup = 'A+'; 
String contact1 = '9876543210'; 
String contact2 = '9988776655'; // The authority/second contact
String authorityContact = '100'; // Placeholder for Police Line

List<SafeZone> safeZones = [
  // Default Safe Zone Example: College/Workplace
  SafeZone(
    name: 'College/Workplace',
    latitude: 10.9926, 
    longitude: 76.9800,
    radiusKm: 4.0, 
    startTimeHour: 9, 
    endTimeHour: 16, 
  ),
];


enum AlertStatus { safe, tier1, tier2, tier3 }
AlertStatus currentStatus = AlertStatus.safe;
Timer? alertTimer;

// --- Feature 1 & 6: Location and SMS Logic (FIXED) ---

Future<String> getLocationLink() async {
  try {
    // 1. Check and request location permission
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return "Location permission denied. Cannot share location.";
    }

    // 2. Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    
    // ** FIX: Explicitly define latitude and longitude from the position object **
    double latitude = position.latitude;
    double longitude = position.longitude;

    // 3. Format into a GENERIC Geo URI (API-Free Location Link)
    String mapsLink = 'geo:$latitude,$longitude'; 
    
    return mapsLink;

  } catch (e) {
    print("Error getting location: $e");
    return "Location unavailable due to error.";
  }
}

// --- Feature 4: Tier 2 Escalation (Contacts Alert) ---
void escalateToTier2() async {
  alertTimer?.cancel(); 
  currentStatus = AlertStatus.tier2;
  print('ALERT ESCALATION: Tier 2 - Contacts Alert.');
  
  String locationLink = await getLocationLink(); 

  // Format the comprehensive SMS message payload (Feature 6: Blood Group)
  String message = 
      '🚨 EMERGENCY ALERT from $userName! I may be in danger and have not responded to a safety check.\n'
      '🩸 Blood Group: $userBloodGroup\n'
      '📍 Live Location (Click Link): $locationLink\n' // Feature 1
      'Please check on me immediately.';

  final telephony = Telephony.instance;
  telephony.sendSms(to: contact1, message: message);
  telephony.sendSms(to: contact2, message: message); 

  print('SMS alerts sent to contacts with location.');

  // Start the 10-minute timer for the final escalation (Tier 3)
  alertTimer = Timer(Duration(minutes: 10), () {
    if (currentStatus == AlertStatus.tier2) {
      escalateToTier3();
    }
  });
}

// --- Feature 4: Tier 3 Escalation (Authority Alert) ---
void escalateToTier3() async {
  alertTimer?.cancel();
  currentStatus = AlertStatus.tier3;
  print('FINAL ESCALATION: Tier 3 - Authority Alert.');
  
  String locationLink = await getLocationLink(); 

  String message = 
      'POLICE ALERT: High-priority emergency for $userName. Safety confirmation failed. '
      'Location: $locationLink. Dispatch nearest unit.';

  final telephony = Telephony.instance;
  telephony.sendSms(to: authorityContact, message: message);

  print('Final alert SMS sent to authority.');
}

// --- Trigger and Confirmation Functions ---

void triggerAlert({required String reason}) {
  if (currentStatus != AlertStatus.safe) return; 

  currentStatus = AlertStatus.tier1;
  print('ALERT TRIGGERED: Tier 1 - User Confirmation. Reason: $reason');
  
  // Start the 5-minute timer for user confirmation
  alertTimer = Timer(Duration(minutes: 5), () {
    if (currentStatus == AlertStatus.tier1) {
      escalateToTier2();
    }
  });
}

void confirmSafety() {
  alertTimer?.cancel();
  currentStatus = AlertStatus.safe;
  print('Safety Confirmed. Alert Canceled.');
}