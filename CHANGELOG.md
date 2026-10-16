# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-16

### Added
- **Hardware Focus Control (`setFocusPoint`)**:
  - Independent touch-to-focus for front and back cameras.
  - Native integration with CameraX `FocusMeteringAction` on Android.
  - Native integration with `AVCaptureDevice.focusPointOfInterest` and auto-focus on iOS.
- **Hardware Exposure Compensation (`setExposureOffset`, `getExposureRange`)**:
  - Dynamic EV adjustment in real time for both lenses.
  - Sensor-driven exposure bounds (`min`, `max`, `step`) queryable via Dart.
- **Unified Single-Package Architecture**:
  - Eliminated multi-package fragmentation from federated setups.
  - Simple, single-dependency import: `dual_camera_plus_flutter`.
- **Live GPU Compositing**:
  - Real-time frame merging on GPU (Metal on iOS, OpenGL ES on Android).
  - Built-in Picture-in-Picture (PiP), Split-Vertical, and Split-Horizontal layouts.
  - Dynamic swapping of primary camera during live preview and recording (`swapPrimary`).
- **Synchronized Video Recording & Photo Capture**:
  - Single composite `.mp4` video output with unified audio/video clock.
  - High-resolution composite photo capture.
- **Display & Orientation Enhancements**:
  - Dynamic selfie mirror toggling (`setMirrorFront`).
  - Configurable aspect ratio override (`setAspectOverride`) and rotation correction (`setRotationOffset`).
- **Performance Telemetry HUD**:
  - `DualCameraStatsOverlay` widget showing live FPS, composite render time, dropped frames, and thermal status.
