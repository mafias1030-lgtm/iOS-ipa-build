import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activities_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_card.dart';
import '../widgets/liquid_glass.dart';
import 'create_activity_screen.dart';
import 'activity_detail_screen.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassMeshBackground(
      primary: const Color(0xFF27AE60),
      secondary: const Color(0xFF2980B9),
      tertiary: const Color(0xFF1ABC9C),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _GlassAppBar(),
        body: Consumer<ActivitiesProvider>(
          builder: (context, provider, _) {
            final activities = provider.activities;
            if (activities.isEmpty) {
              return const _EmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 110, 16, 120),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ActivityCard(
                  activity: activity,
                  onTap: () => Navigator.push(
                    context,
                    _fadeRoute(
                      ActivityDetailScreen(activityId: activity.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: _GlassFAB(
          onTap: () => Navigator.push(
            context,
            _fadeRoute(const CreateActivityScreen()),
          ),
        ),
      ),
    );
  }

  Route _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 280),
      );
}

class _GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.02),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.72),
                      Colors.white.withValues(alpha: 0.30),
                    ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.60),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ACTIVITÉS',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                  ),
                  Consumer<ProfileProvider>(
                    builder: (context, prov, _) {
                      final profile = prov.profile;
                      return LiquidGlass(
                        borderRadius: BorderRadius.circular(50),
                        blurSigma: 10,
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.transparent,
                          backgroundImage: profile.photoPath != null &&
                                  File(profile.photoPath!).existsSync()
                              ? FileImage(File(profile.photoPath!))
                              : null,
                          child: profile.photoPath == null
                              ? Text(
                                  profile.initials,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _GlassFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: GestureDetector(
        onTap: onTap,
        child: LiquidGlass(
          borderRadius: BorderRadius.circular(50),
          blurSigma: 20,
          tint: scheme.primary,
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: scheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Nouvelle activité',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LiquidGlass(
              borderRadius: BorderRadius.circular(40),
              blurSigma: 20,
              padding: const EdgeInsets.all(28),
              child: Icon(
                Icons.sports_rounded,
                size: 52,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Aucune activité proposée',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'pour le moment...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Appuie sur + pour créer\nla première activité !',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
