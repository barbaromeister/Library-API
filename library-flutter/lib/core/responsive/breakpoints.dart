import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static double widthOf(BuildContext c) => MediaQuery.sizeOf(c).width;

  static bool isMobile(BuildContext c) => widthOf(c) < mobile;
  static bool isTablet(BuildContext c) {
    final w = widthOf(c);
    return w >= mobile && w < desktop;
  }

  static bool isDesktop(BuildContext c) => widthOf(c) >= desktop;

  /// Recommended cross-axis count for a responsive grid.
  static int gridColumns(BuildContext c) {
    final w = widthOf(c);
    if (w < mobile) return 2;
    if (w < tablet) return 3;
    if (w < desktop) return 4;
    return 6;
  }
}
