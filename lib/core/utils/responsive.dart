import 'package:flutter/material.dart';

/// Simple breakpoint helper so the same widget tree can render either the
/// "Explorer | Editor | AI Assistant" desktop/tablet layout or the
/// bottom-nav + drawer mobile layout, per the UX requirement.
class Responsive {
  Responsive._();

  static const double desktopBreakpoint = 900;
  static const double tabletBreakpoint = 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= tabletBreakpoint && w < desktopBreakpoint;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletBreakpoint;
}
