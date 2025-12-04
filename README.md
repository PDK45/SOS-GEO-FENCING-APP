# 🛡️ SafeSoul (GeoFence.AI)

> **Team Innocreators** | SRCAS Hackathon 2.0
> *Problem Statement: PS03 - SOS & Geo-Fencing App for Women & Elderly*

SafeSoul is an AI-assisted safety application designed to provide proactive protection for women and the elderly. Unlike traditional safety apps that require manual activation, SafeSoul uses **Smart Geo-Fencing** and **Offline Sensor Fusion** to detect threats automatically and trigger alerts even without an internet connection.

---

## 🚀 Key Features

### 1. 📍 Smart Geo-Fencing
- Users can define a "Safe Zone" (e.g., home or college campus).
- **Auto-Alert:** If the user crosses the safe zone boundary intentionally or forcefully, the app switches to "High Alert" mode.
- **Visual Status:** Real-time dashboard showing "Safe" or "Breached" status.

### 2. 🆘 Hybrid Multi-Channel Alert System
- **Offline First:** If the internet is down, the app automatically switches to **SMS Fallback** mode.
- **Panic Protocols:**
  - **Manual:** Big red SOS button for immediate help.
  - **Automatic:** Fall/Shake detection triggers an alert if the user is attacked or collapses.
- **Payload:** Sends a Google Maps link with exact coordinates to trusted contacts.

### 3. 🧠 Passive Anomaly Detection (P.A.D.S.)
- Uses device accelerometers (G-sensor) to detect violent shaking or sudden falls.
- Operates in the background with battery-optimized polling.

---

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **Sensors:** Accelerometer (UserAccelerometer), Gyroscope, GPS (Geolocator)
* **Offline Comms:** SMS Manager (flutter_sms)
* **Hardware Access:** Haptic Feedback (Vibration API)
* **Logic:** Custom "Sensor Fusion" algorithm for fall detection thresholds.

---

## 📸 Screenshots

| Safe Zone Active | SOS Triggered | SMS Alert |
|:---:|:---:|:---:|
| *(Add Screenshot Here)* | *(Add Screenshot Here)* | *(Add Screenshot Here)* |

---

## ⚙️ How to Run

### Prerequisites
* Flutter SDK installed ([Guide](https://docs.flutter.dev/get-started/install))
* Android device or Emulator connected

### Installation
1.  **Clone the Repo**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/SafeSoul-Prototype.git](https://github.com/YOUR_USERNAME/SafeSoul-Prototype.git)
    cd SafeSoul-Prototype
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the App**
    ```bash
    flutter run
    ```

*Note: For the SMS and GPS features to work, you must accept the Android permission prompts upon first launch.*

---

## 🔮 Future Roadmap (Post-Hackathon)
- [ ] **Audio Analytics:** Integrate microphone input to detect screams (>90dB) using TensorFlow Lite.
- [ ] **Community Layer:** Notify volunteers within a 300m radius of the distress signal.
- [ ] **Backend Integration:** Connect to Firebase for cloud-based incident logging.

---

