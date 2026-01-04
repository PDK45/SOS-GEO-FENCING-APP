# 🛡️ SafeSoul: Autonomous AI Safety Sentinel

> **🏆 Team Innocreators | SRCAS Hackathon 2.0**
> *Re-engineering personal safety with Sensor Fusion & Offline Intelligence.*

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white) ![Platform](https://img.shields.io/badge/Platform-iOS%20|%20Android%20|%20Windows-lightgrey?style=for-the-badge) ![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---

## 🦅 The Vision
SafeSoul is not just a panic button—it's **SafeSoul**. In a world where every second counts, reliance on active user intervention or stable internet connectivity is a fatal flaw. SafeSoul bridges this gap using **Passive Anomaly Detection Systems (P.A.D.S.)** and **Local-First Architecture**, ensuring protection helps you *before* you even ask for it.

We have moved beyond "reactive safety" to "predictive protection".

---

## ⚡ Core Innovations

### 🧠 1. Passive Anomaly Detection System (P.A.D.S.)
Unlike traditional apps that sleep until opened, SafeSoul's background engine monitors micro-changes in device kinematics.
- **Panic Shake Algorithm**: Uses 3-axis accelerometer data to detect violent shaking consistent with a struggle.
- **Crash/Fall Recognition**: Identifies sudden G-force spikes followed by immobility.
- **Zero-Latency Trigger**: Bypasses UI layers to execute emergency protocols immediately.

### 🌐 2. Temporal-Spatial Geo-Fencing
We don't just track *where* you are, but *when* you are there.
- **Dynamic Safe Zones**: Define multiple safe havens (Home, Campus, Work) with specific active time windows.
- **Breach Logic**: If you leave a safe zone during restricted hours (e.g., leaving a hostel at 2 AM), the app enters **Pre-Alert State**.

### 📡 3. Zero-Connectivity Protocol (Z.C.P.)
Internet down? Server crash? **No Problem.**
SafeSoul operates on a hybrid communication layer. If HTTP requests fail, the app seamlessly switches to **Direct-SMS Injection**, sending encrypted location payloads directly to trusted contacts and authorities.

### 🎨 4. "Glass & Air" UI Design
Security shouldn't look scary. We've implemented a **Hyper-Modern iOS-Style Interface**:
- **Haptic Control Center**: Large, touch-optimized controls for stressful situations.
- **HUD Console**: Real-time translucent terminal displaying system logic and sensor states.
- **Adaptive Theming**: Context-aware UI that shifts from "Secure Green" to "Alert Red" based on threat levels.

---

## 🛠️ Technological Architecture

| Component | Technology | Description |
|-----------|------------|-------------|
| **Core Framework** | Flutter 3.x | Compiled to native ARM code for 60fps performance on low-end devices. |
| **Sensor Fusion** | `sensors_plus` | Raw stream processing of Accelerometer & Gyroscope data. |
| **Spatial Engine** | `geolocator` | High-accuracy GPS with Kalman Filter fallback. |
| **Persistence** | `SharedPreferences` | Local-encrypted storage for contacts and user protocols. |
| **Comms Layer** | `telephony` | Direct hardware access for background SMS dispatch. |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `3.0+`
- Android/iOS Device (Simulators supported for UI testing)

### Installation
```bash
# 1. Clone the repository
git clone https://github.com/TeamInnocreators/SafeSoul.git

# 2. Install dependencies
flutter pub get

# 3. Launch the Safety Sentinel
flutter run
```

---

## 🔮 Roadmap: The Future of SafeSoul
- [ ] **Acoustic Threat Analysis**: TensorFlow Lite model to detect high-decibel screams or keywords ("Help!").
- [ ] **Biometric Link**: Integration with Smart Watches to trigger alerts on elevated heart rate (Tachycardia).
- [ ] **Community Grid**: A decentralized mesh network of SafeSoul users acting as first responders.

---

> *Built with ❤️ and ☕ by Team Innocreators.*
