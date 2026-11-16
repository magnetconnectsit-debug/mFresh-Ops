// region Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core/utils/app_common_toast_message.dart';
// endregion

// region AppDoubleBackToClose Widget
/// A standardized wrapper for root and primary screens that intercepts system
/// back gestures / navigation buttons to prevent accidental app termination.
///
/// Workflow:
/// 1. Closes the drawer if [scaffoldKey] is provided and the drawer is open.
/// 2. Gracefully pops the route if there are previous routes in the navigator stack ([checkCanPop]).
/// 3. Prompts the user with [message] ("Please press back again to close") on the first press.
/// 4. Exits the application via [SystemNavigator.pop] if pressed a second time within [timeout].
class AppDoubleBackToClose extends StatefulWidget {
  // region Properties
  final Widget child;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String message;
  final Duration timeout;
  final bool checkCanPop;
  // endregion

  // region Constructor
  const AppDoubleBackToClose({
    super.key,
    required this.child,
    this.scaffoldKey,
    this.message = 'Please press back again to close',
    this.timeout = const Duration(seconds: 2),
    this.checkCanPop = true,
  });
  // endregion

  @override
  State<AppDoubleBackToClose> createState() => _AppDoubleBackToCloseState();
}
// endregion

// region _AppDoubleBackToCloseState
class _AppDoubleBackToCloseState extends State<AppDoubleBackToClose> {
  // region State & Properties
  DateTime? _lastPressed;
  // endregion

  // region Navigation Handler
  Future<void> _handlePop(bool didPop, dynamic result) async {
    if (didPop) return;

    // 1. Close drawer if open
    if (widget.scaffoldKey?.currentState?.isDrawerOpen ?? false) {
      widget.scaffoldKey?.currentState?.closeDrawer();
      return;
    }

    // 2. Pop previous route if present
    if (widget.checkCanPop && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    // 3. Double-back exit prompt
    final now = DateTime.now();
    if (_lastPressed == null || now.difference(_lastPressed!) > widget.timeout) {
      _lastPressed = now;
      AppCommonToastMessage.show(
        message: widget.message,
        type: ToastType.info,
      );
      return;
    }

    // 4. Close app
    SystemNavigator.pop();
  }
  // endregion

  // region Main Build
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePop,
      child: widget.child,
    );
  }
  // endregion
}
// endregion

