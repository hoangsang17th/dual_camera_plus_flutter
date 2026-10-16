import 'package:flutter/material.dart';
import 'package:dual_camera_plus_flutter/dual_camera_plus_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Dual Camera Plus Demo',
      home: DualCameraDemoScreen(),
    );
  }
}

class DualCameraDemoScreen extends StatefulWidget {
  const DualCameraDemoScreen({super.key});

  @override
  State<DualCameraDemoScreen> createState() => _DualCameraDemoScreenState();
}

class _DualCameraDemoScreenState extends State<DualCameraDemoScreen> {
  final DualCameraController _controller = DualCameraController();
  bool _isSupported = false;
  bool _isReady = false;
  double _exposureOffset = 0.0;
  double _minExposure = -2.0;
  double _maxExposure = 2.0;

  @override
  void initState() {
    super.initState();
    _checkSupportAndInit();
  }

  Future<void> _checkSupportAndInit() async {
    final supported = await DualCameraController.isSupported();
    if (!mounted) return;

    setState(() {
      _isSupported = supported;
    });

    if (!supported) return;

    await _controller.initialize(
      layout: DualLayout.pictureInPicture(),
    );

    final range = await _controller.getExposureRange();
    if (!mounted) return;

    setState(() {
      _isReady = true;
      _minExposure = range['min'] ?? -2.0;
      _maxExposure = range['max'] ?? 2.0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapToFocus(TapDownDetails details, BoxConstraints constraints) {
    final x = details.localPosition.dx / constraints.maxWidth;
    final y = details.localPosition.dy / constraints.maxHeight;
    _controller.setFocusPoint(Offset(x, y));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSupported) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dual Camera Plus Demo')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Concurrent dual cameras are not supported on this device hardware.\n'
              'Requires iPhone XS/A12+ (iOS 13+) or supported Android devices (Pixel 6+, S22+).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    if (!_isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) => _onTapToFocus(details, constraints),
                child: DualCameraPreview(_controller),
              );
            },
          ),
          DualCameraStatsOverlay(_controller),
          Positioned(
            left: 20,
            right: 20,
            bottom: 110,
            child: Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.white70, size: 20),
                Expanded(
                  child: Slider(
                    value: _exposureOffset,
                    min: _minExposure,
                    max: _maxExposure,
                    onChanged: (val) {
                      setState(() => _exposureOffset = val);
                      _controller.setExposureOffset(val);
                    },
                  ),
                ),
                Text(
                  _exposureOffset.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                  onPressed: () => _controller.swapPrimary(),
                ),
                ValueListenableBuilder<DualCameraValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    return FloatingActionButton(
                      backgroundColor: value.isRecording ? Colors.red : Colors.white,
                      onPressed: () async {
                        if (value.isRecording) {
                          final path = await _controller.stopRecording();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Saved video: $path')),
                            );
                          }
                        } else {
                          await _controller.startRecording();
                        }
                      },
                      child: Icon(
                        value.isRecording ? Icons.stop : Icons.videocam,
                        color: value.isRecording ? Colors.white : Colors.black,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                  onPressed: () async {
                    final photoPath = await _controller.takePhoto();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved photo: $photoPath')),
                      );
                    }
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
