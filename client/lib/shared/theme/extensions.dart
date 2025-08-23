library;

import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble; // for double lerp

/// ThemeExtension for spacing scale used across components
@immutable
class AppSpacingTheme extends ThemeExtension<AppSpacingTheme> {
  const AppSpacingTheme({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
    required this.section,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
  final double section;

  @override
  AppSpacingTheme copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
    double? section,
  }) => AppSpacingTheme(
        xs: xs ?? this.xs,
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        xl: xl ?? this.xl,
        xxl: xxl ?? this.xxl,
        xxxl: xxxl ?? this.xxxl,
        section: section ?? this.section,
      );

  @override
  AppSpacingTheme lerp(ThemeExtension<AppSpacingTheme>? other, double t) {
    if (other is! AppSpacingTheme) return this;
    return AppSpacingTheme(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      xxxl: lerpDouble(xxxl, other.xxxl, t)!,
      section: lerpDouble(section, other.section, t)!,
    );
  }

  static AppSpacingTheme defaults() => const AppSpacingTheme(
        xs: 4,
        sm: 8,
        md: 16,
        lg: 24,
        xl: 32,
        xxl: 48,
        xxxl: 64,
        section: 96,
      );
}

/// ThemeExtension for border radius scale
@immutable
class AppRadiusTheme extends ThemeExtension<AppRadiusTheme> {
  const AppRadiusTheme({
    required this.none,
    required this.small,
    required this.medium,
    required this.large,
    required this.xl,
    required this.full,
  });

  final double none;
  final double small;
  final double medium;
  final double large;
  final double xl;
  final double full;

  BorderRadius get radiusNone => BorderRadius.circular(none);
  BorderRadius get radiusSmall => BorderRadius.circular(small);
  BorderRadius get radiusMedium => BorderRadius.circular(medium);
  BorderRadius get radiusLarge => BorderRadius.circular(large);
  BorderRadius get radiusXl => BorderRadius.circular(xl);
  BorderRadius get radiusFull => BorderRadius.circular(full);

  @override
  AppRadiusTheme copyWith({
    double? none,
    double? small,
    double? medium,
    double? large,
    double? xl,
    double? full,
  }) => AppRadiusTheme(
        none: none ?? this.none,
        small: small ?? this.small,
        medium: medium ?? this.medium,
        large: large ?? this.large,
        xl: xl ?? this.xl,
        full: full ?? this.full,
      );

  @override
  AppRadiusTheme lerp(ThemeExtension<AppRadiusTheme>? other, double t) {
    if (other is! AppRadiusTheme) return this;
    return AppRadiusTheme(
      none: lerpDouble(none, other.none, t)!,
      small: lerpDouble(small, other.small, t)!,
      medium: lerpDouble(medium, other.medium, t)!,
      large: lerpDouble(large, other.large, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      full: lerpDouble(full, other.full, t)!,
    );
  }

  static AppRadiusTheme defaults() => const AppRadiusTheme(
        none: 0,
        small: 6,
        medium: 12,
        large: 16,
        xl: 24,
        full: 9999,
      );
}

/// ThemeExtension for effects (animations, shadows, scales)
@immutable
class AppEffectsTheme extends ThemeExtension<AppEffectsTheme> {
  const AppEffectsTheme({
    required this.durationFast,
    required this.durationNormal,
    required this.durationSlow,
    required this.scaleHover,
    required this.tooltipShadow,
  });

  final Duration durationFast;
  final Duration durationNormal;
  final Duration durationSlow;
  final double scaleHover;
  final BoxShadow tooltipShadow;

  @override
  AppEffectsTheme copyWith({
    Duration? durationFast,
    Duration? durationNormal,
    Duration? durationSlow,
    double? scaleHover,
    BoxShadow? tooltipShadow,
  }) => AppEffectsTheme(
        durationFast: durationFast ?? this.durationFast,
        durationNormal: durationNormal ?? this.durationNormal,
        durationSlow: durationSlow ?? this.durationSlow,
        scaleHover: scaleHover ?? this.scaleHover,
        tooltipShadow: tooltipShadow ?? this.tooltipShadow,
      );

  @override
  AppEffectsTheme lerp(ThemeExtension<AppEffectsTheme>? other, double t) {
    if (other is! AppEffectsTheme) return this;
    return AppEffectsTheme(
      durationFast: _lerpDuration(durationFast, other.durationFast, t),
      durationNormal: _lerpDuration(durationNormal, other.durationNormal, t),
      durationSlow: _lerpDuration(durationSlow, other.durationSlow, t),
      scaleHover: lerpDouble(scaleHover, other.scaleHover, t)!,
      tooltipShadow: BoxShadow(
        color: Color.lerp(tooltipShadow.color, other.tooltipShadow.color, t) ?? tooltipShadow.color,
        offset: Offset.lerp(tooltipShadow.offset, other.tooltipShadow.offset, t) ?? tooltipShadow.offset,
        blurRadius: lerpDouble(tooltipShadow.blurRadius, other.tooltipShadow.blurRadius, t) ?? tooltipShadow.blurRadius,
        spreadRadius: lerpDouble(tooltipShadow.spreadRadius, other.tooltipShadow.spreadRadius, t) ?? tooltipShadow.spreadRadius,
      ),
    );
  }

  static Duration _lerpDuration(Duration a, Duration b, double t) {
    return Duration(milliseconds: (a.inMilliseconds + (b.inMilliseconds - a.inMilliseconds) * t).round());
  }

  static AppEffectsTheme defaults() => AppEffectsTheme(
        durationFast: const Duration(milliseconds: 150),
        durationNormal: const Duration(milliseconds: 300),
        durationSlow: const Duration(milliseconds: 500),
        scaleHover: 1.05,
        tooltipShadow: BoxShadow(color: Colors.black.withValues(alpha: 0.25), offset: const Offset(0, 2), blurRadius: 8),
      );
}


