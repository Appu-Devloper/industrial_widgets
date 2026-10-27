import 'package:flutter/material.dart';

/// Dashboard spacing preset.
enum IndustrialDensity {
  /// Reduced padding for dense monitoring walls.
  compact,
  /// Standard spacing for touch-friendly dashboards.
  comfortable,
}

/// Dashboard design tokens. Install in ThemeData.extensions or override locally.
@immutable
class IndustrialTheme extends ThemeExtension<IndustrialTheme> {
  /// Creates a complete token set.
  const IndustrialTheme({
    required this.surface,
    required this.foreground,
    required this.muted,
    required this.border,
    required this.accent,
    this.warning = const Color(0xFFFFB547),
    this.critical = const Color(0xFFFF6575),
    this.radius = 18,
    this.borderWidth = 1,
    this.density = IndustrialDensity.comfortable,
    this.localize,
    this.spacing = 16,
    this.labelStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    this.valueStyle = const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  });

  /// Graphite palette.
  static const dark = IndustrialTheme(
    surface: Color(0xFF14232D),
    foreground: Color(0xFFEDF6F8),
    muted: Color(0xFFACC1CD),
    border: Color(0xFF344A57),
    accent: Color(0xFF4EDBC5),
  );

  /// High-contrast light palette.
  static const light = IndustrialTheme(
    surface: Color(0xFFFFFFFF),
    foreground: Color(0xFF152C38),
    muted: Color(0xFF536774),
    border: Color(0xFFBCCDD5),
    accent: Color(0xFF007E70),
    warning: Color(0xFF925500),
    critical: Color(0xFFBB243B),
  );

  /// Panel background.
  final Color surface;

  /// Primary text.
  final Color foreground;

  /// Secondary text and inactive geometry.
  final Color muted;

  /// Outlines and dividers.
  final Color border;

  /// Primary telemetry accent.
  final Color accent;

  /// Warning severity.
  final Color warning;

  /// Critical severity.
  final Color critical;

  /// Border thickness in logical pixels.
  final double borderWidth;
  /// Dashboard spacing preset.
  final IndustrialDensity density;
  /// Optional application translation of default English UI text.
  final String Function(String text)? localize;
  /// Resolves application-localized default text.
  String text(String value) => localize?.call(value) ?? value;
  /// Effective panel padding after applying density.
  double get padding => density == IndustrialDensity.compact ? spacing * .65 : spacing;

  /// Panel corner radius.
  final double radius;

  /// Panel padding and standard spacing.
  final double spacing;

  /// Label typography, colored by foreground unless overridden.
  final TextStyle labelStyle;

  /// Reading typography.
  final TextStyle valueStyle;

  /// Resolves the extension or a brightness-matched default.
  static IndustrialTheme of(BuildContext context) =>
      Theme.of(context).extension<IndustrialTheme>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);
  @override
  IndustrialTheme copyWith({
    Color? surface,
    Color? foreground,
    Color? muted,
    Color? border,
    Color? accent,
    Color? warning,
    Color? critical,
    double? radius,
    double? borderWidth,
    IndustrialDensity? density,
    String Function(String text)? localize,
    double? spacing,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) => IndustrialTheme(
    surface: surface ?? this.surface,
    foreground: foreground ?? this.foreground,
    muted: muted ?? this.muted,
    border: border ?? this.border,
    accent: accent ?? this.accent,
    warning: warning ?? this.warning,
    critical: critical ?? this.critical,
    radius: radius ?? this.radius,
    borderWidth: borderWidth ?? this.borderWidth,
    density: density ?? this.density,
    localize: localize ?? this.localize,
    spacing: spacing ?? this.spacing,
    labelStyle: labelStyle ?? this.labelStyle,
    valueStyle: valueStyle ?? this.valueStyle,
  );
  @override
  IndustrialTheme lerp(covariant IndustrialTheme? other, double t) {
    if (other == null) return this;
    return IndustrialTheme(
      surface: Color.lerp(surface, other.surface, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      critical: Color.lerp(critical, other.critical, t)!,
      borderWidth: borderWidth + (other.borderWidth - borderWidth) * t,
      density: t < .5 ? density : other.density,
      localize: t < .5 ? localize : other.localize,
      radius: radius + (other.radius - radius) * t,
      spacing: spacing + (other.spacing - spacing) * t,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
      valueStyle: TextStyle.lerp(valueStyle, other.valueStyle, t)!,
    );
  }
}
