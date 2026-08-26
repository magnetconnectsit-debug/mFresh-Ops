import 'package:flutter/foundation.dart';
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

  bool _show = false;

  @override
  void initState() {
    super.initState();
    _checkVisibility();
    everAll([settings.showLogger, settings.isDevMode], (_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    final shouldShow = settings.showLogger.value || settings.isDevMode.value || kDebugMode;
    if (_show != shouldShow) {
      if (mounted) setState(() => _show = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();

    return Positioned(
      bottom: _offset.dy,
      right: _offset.dx,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset = Offset(
              _offset.dx - details.delta.dx,
              _offset.dy - details.delta.dy,
            );
          });
        },
        child: _buildButton(context),
      ),
    );
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
