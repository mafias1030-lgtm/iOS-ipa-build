import 'dart:ui';
import 'package:flutter/material.dart';

/// Frosted glass widget inspired by iOS 26 Liquid Glass.
/// Requires a colorful background behind it (use [GlassMeshBackground]).
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double blurSigma;
  final Color? tint;

  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.padding = EdgeInsets.zero,
    this.blurSigma = 24,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = tint;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: t != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      t.withValues(alpha: isDark ? 0.22 : 0.30),
                      t.withValues(alpha: isDark ? 0.09 : 0.14),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.55, 1.0],
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.07),
                            Colors.white.withValues(alpha: 0.03),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.82),
                            Colors.white.withValues(alpha: 0.64),
                            Colors.white.withValues(alpha: 0.50),
                          ],
                  ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.88),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.07),
                blurRadius: 28,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              child,
              // Specular highlight — thin bright line at the top edge
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: isDark ? 0.55 : 0.95),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colorful radial-gradient mesh background.
/// Gives LiquidGlass widgets something to blur and tint against.
class GlassMeshBackground extends StatelessWidget {
  final Widget child;
  final Color primary;
  final Color? secondary;
  final Color? tertiary;

  const GlassMeshBackground({
    super.key,
    required this.child,
    required this.primary,
    this.secondary,
    this.tertiary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c2 = secondary ?? Color.lerp(primary, Colors.blue, 0.6)!;
    final c3 = tertiary ?? Color.lerp(primary, Colors.teal, 0.5)!;

    return Container(
      color: isDark ? const Color(0xFF05050F) : const Color(0xFFEEF2FF),
      child: Stack(
        children: [
          _Blob(top: -110, left: -90, color: primary, size: 360,
              opacity: isDark ? 0.42 : 0.26),
          _Blob(top: 160, right: -110, color: c2, size: 300,
              opacity: isDark ? 0.36 : 0.20),
          _Blob(bottom: 180, left: 30, color: c3, size: 240,
              opacity: isDark ? 0.30 : 0.16),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double? top, left, right, bottom;
  final Color color;
  final double size;
  final double opacity;

  const _Blob({
    this.top, this.left, this.right, this.bottom,
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
