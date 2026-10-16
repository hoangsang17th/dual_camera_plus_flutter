# dual_camera_plus_flutter

[![pub package](https://img.shields.io/pub/v/dual_camera_plus_flutter.svg)](https://pub.dev/packages/dual_camera_plus_flutter)
[![likes](https://img.shields.io/pub/likes/dual_camera_plus_flutter)](https://pub.dev/packages/dual_camera_plus_flutter/score)
[![popularity](https://img.shields.io/pub/popularity/dual_camera_plus_flutter)](https://pub.dev/packages/dual_camera_plus_flutter/score)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/hoangsang17th/dual_camera_plus_flutter/blob/main/LICENSE)

A high-performance Flutter plugin for **simultaneous front and back dual-camera recording and photography**, featuring **hardware-accelerated GPU compositing** (Metal on iOS, OpenGL ES on Android) and **independent hardware focus & exposure control** on both lenses.

---

## ⚡ What makes `dual_camera_plus_flutter` different?

Traditional dual camera solutions either only display a split preview or require post-processing to stitch videos together. `dual_camera_plus_flutter` composites frames directly on the GPU in real time, delivering a single output stream directly into `MediaCodec` / `AVAssetWriter`.

In addition to simultaneous dual-camera capture, **this plugin provides direct hardware-level controls**:

* 🎯 **Independent Touch-to-Focus (`setFocusPoint`)**: Set focus point of interest on front or back camera independently.
* ☀️ **Hardware Exposure Compensation (`setExposureOffset`)**: Dynamically adjust EV bias to prevent overexposure or underexposure in challenging lighting.
* 📊 **Exposure Range Querying (`getExposureRange`)**: Query device sensor capabilities (min/max/step) to construct precise UI exposure sliders.
* 📦 **Single, Unified Plugin**: No multi-package federated confusion. Drop one dependency into your app and start recording.
* 🪞 **Dynamic Selfie Mirroring (`setMirrorFront`)**: Real-time mirror toggle without restarting the camera pipeline.

---

## 📱 Hardware & Platform Support

Simultaneous multi-camera capture requires hardware and operating system support for concurrent camera streaming:

* **iOS**: iOS 13.0 or higher. Requires devices with `AVCaptureMultiCamSession` support (iPhone XS / XR / A12 Bionic and newer).
* **Android**: Android 7.0 (API level 24) or higher. Requires devices with concurrent camera stream support in hardware / CameraX (e.g. Pixel 6+, Samsung Galaxy S21+, etc.). Resolution is capped per hardware limits (typically 720p concurrent).

> **Pro Tip:** Always check `DualCameraController.isSupported()` before initializing, and provide a single-camera fallback when concurrent capture is unavailable.

---

## 📦 Installation

Add `dual_camera_plus_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  dual_camera_plus_flutter: ^1.0.0
```

Or via Flutter CLI:

```bash
flutter pub add dual_camera_plus_flutter
```

---

## ⚙️ Platform Setup

### iOS Setup

In `ios/Runner/Info.plist`, declare camera and microphone usage descriptions:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to the camera to record dual-camera videos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to the microphone to record audio with your videos.</string>
```

### Android Setup

In `android/app/src/main/AndroidManifest.xml`, request permissions inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

Ensure your `android/app/build.gradle` has a `minSdkVersion` of at least `24`:

```groovy
android {
    defaultConfig {
        minSdkVersion 24
    }
}
```

*Note: Request camera and microphone permissions at runtime (e.g., using `permission_handler`) before initializing `DualCameraController`.*

---

## 🚀 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:dual_camera_plus_flutter/dual_camera_plus_flutter.dart';

class DualCameraScreen extends StatefulWidget {
  const DualCameraScreen({super.key});

  @override
  State<DualCameraScreen> createState() => _DualCameraScreenState();
}

class _DualCameraScreenState extends State<DualCameraScreen> {
  final DualCameraController _controller = DualCameraController();
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    // 1. Check if the device hardware supports simultaneous capture
    final supported = await DualCameraController.isSupported();
    if (!supported) {
      debugPrint('Device does not support concurrent dual cameras');
      return;
    }

    // 2. Initialize with your preferred layout and resolution
    await _controller.initialize(
      layout: DualLayout.pictureInPicture(
        primary: CameraLens.back,
        insetCorner: InsetCorner.bottomRight,
        insetScale: 0.28,
        cornerRadius: 18,
      ),
      resolution: DualResolution.hd720,
      recordAudio: true,
    );

    if (mounted) setState(() => _isReady = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Live composited camera preview
          DualCameraPreview(_controller),

          // Controls
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flip which camera is full-frame
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  onPressed: () => _controller.swapPrimary(),
                ),

                // Record Button
                ValueListenableBuilder<DualCameraValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    return ElevatedButton(
                      onPressed: () async {
                        if (value.isRecording) {
                          final videoPath = await _controller.stopRecording();
                          debugPrint('Saved dual-camera video to: $videoPath');
                        } else {
                          await _controller.startRecording();
                        }
                      },
                      child: Text(value.isRecording ? 'Stop' : 'Record'),
                    );
                  },
                ),

                // Take Photo Button
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () async {
                    final photoPath = await _controller.takePhoto();
                    debugPrint('Saved composite photo to: $photoPath');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎯 Advanced Features

### 1. Touch-to-Focus (`setFocusPoint`)

You can set the focus point of interest on either camera using normalized coordinates (`0.0` to `1.0`):

```dart
// Tap on screen to focus on rear camera:
await controller.setFocusPoint(
  Offset(0.5, 0.5), // Center of the frame
  isFront: false,   // false = back camera, true = front camera
);
```

### 2. Exposure Compensation (`setExposureOffset` & `getExposureRange`)

Query device limits and adjust brightness offset dynamically:

```dart
// Get supported exposure bounds
final range = await controller.getExposureRange(isFront: false);
final double minEv = range['min'] ?? -2.0;
final double maxEv = range['max'] ?? 2.0;

// Set exposure offset
await controller.setExposureOffset(0.5, isFront: false);
```

### 3. Layout Options

Switch layouts dynamically with `controller.setLayout(...)`:

```dart
// 1. Picture in Picture (PiP)
DualLayout.pictureInPicture(
  primary: CameraLens.back,
  insetCorner: InsetCorner.topRight,
  insetScale: 0.30,
  cornerRadius: 16.0,
  circleInset: false, // Set true for a round selfie bubble
);

// 2. Split Vertical (Top & Bottom)
DualLayout.splitVertical(primary: CameraLens.back);

// 3. Split Horizontal (Left & Right)
DualLayout.splitHorizontal(primary: CameraLens.back);
```

### 4. Performance & Telemetry Overlay

Add `DualCameraStatsOverlay` to inspect real-time metrics (FPS, GPU compositing latency in ms, dropped frames, thermal state):

```dart
Stack(
  children: [
    DualCameraPreview(controller),
    DualCameraStatsOverlay(controller),
  ],
)
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
