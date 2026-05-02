import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/activities_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import 'liquid_glass.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  String _formatDate(DateTime dt) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    final dayName = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$dayName ${dt.day} $month à ${h}h$m';
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.activityColor(activity.type);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<ProfileProvider, ActivitiesProvider>(
      builder: (context, profileProv, activitiesProv, _) {
        final userId = profileProv.profile.id;
        final isUserActive = activity.isUserActive(userId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: onTap,
            child: LiquidGlass(
              borderRadius: BorderRadius.circular(24),
              blurSigma: 18,
              tint: color,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Activity type badge
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withValues(
                              alpha: isDark ? 0.30 : 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: color.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          AppTheme.activityIcon(activity.type),
                          color: isDark ? Colors.white : color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          activity.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: activity.location,
                    isDark: isDark,
                    color: color,
                  ),
                  const SizedBox(height: 5),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: _formatDate(activity.dateTime),
                    isDark: isDark,
                    color: color,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Participant count chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: color.withValues(
                              alpha: isDark ? 0.22 : 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: color.withValues(alpha: 0.30),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 13,
                              color: isDark ? Colors.white70 : color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${activity.activeCount}/${activity.maxParticipants}',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : color,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _GlassStatusButton(
                        isActive: isUserActive,
                        color: color,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          activitiesProv.toggleParticipantStatus(
                            activity.id,
                            userId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.isDark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.60)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.55);

    return Row(
      children: [
        Icon(icon, size: 13, color: textColor),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _GlassStatusButton extends StatelessWidget {
  final bool isActive;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _GlassStatusButton({
    required this.isActive,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = isActive
        ? const Color(0xFF2ECC71)
        : const Color(0xFFE74C3C);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: btnColor.withValues(alpha: isDark ? 0.28 : 0.18),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: btnColor.withValues(alpha: isDark ? 0.50 : 0.40),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 13,
              color: isDark ? Colors.white : btnColor,
            ),
            const SizedBox(width: 5),
            Text(
              isActive ? 'Actif' : 'Pas actif',
              style: TextStyle(
                color: isDark ? Colors.white : btnColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
