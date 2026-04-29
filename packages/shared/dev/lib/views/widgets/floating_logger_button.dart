import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:services/settings_service.dart';
import 'package:dev/routes/dev_routes.dart';

class FloatingLoggerButton extends StatefulWidget {
  const FloatingLoggerButton({super.key});

  @override
  State<FloatingLoggerButton> createState() => _FloatingLoggerButtonState();
}

class _FloatingLoggerButtonState extends State<FloatingLoggerButton> {
  OverlayEntry? _overlayEntry;
  Offset _offset = const Offset(0, 100);
  final settings = Get.find<SettingsService>();

  @override
  void initState() {
    super.initState();
    ever(settings.showLogger, (bool show) {
      if (show) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });

    // Show initially if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (settings.showLogger.value) {
        _showOverlay();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: _offset.dy,
        right: _offset.dx,
        child: Draggable(
          feedback: _buildButton(context, isFeedback: true),
          childWhenDragging: const SizedBox.shrink(),
          onDragEnd: (details) {
            setState(() {
              // Update position based on screen size to keep it on the right edge
              final size = MediaQuery.of(context).size;
              _offset = Offset(0, size.height - details.offset.dy - 50);
              _overlayEntry?.markNeedsBuild();
            });
          },
          child: _buildButton(context),
        ),
      ),
    );

    Overlay.of(Get.overlayContext!).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // This widget doesn't render anything itself
  }

  Widget _buildButton(BuildContext context, {bool isFeedback = false}) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Get.toNamed(DevRoutes.logViewer),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: isFeedback ? 0.4 : 0.7),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomLeft: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.bug_report_rounded,
            color: Colors.greenAccent,
            size: 28,
          ),
        ),
      ),
    );
  }
}
