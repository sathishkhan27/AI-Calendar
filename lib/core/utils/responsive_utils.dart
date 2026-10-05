import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1100.0;

  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletBreakpoint;
  }

  static bool isWide(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= mobileBreakpoint;
  }
}
