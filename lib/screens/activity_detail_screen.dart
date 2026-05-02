import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/participant.dart';
import '../providers/activities_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/participant_bubble.dart';

class ActivityDetailScreen extends StatelessWidget {
  final String activityId;
  const ActivityDetailScreen({super.key, required this.activityId});

  String _formatDateFull(DateTime dt) {
    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    final day = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$day ${dt.day} $month ${dt.year} à ${h}h$m';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ActivitiesProvider, ProfileProvider>(
      builder: (context, activitiesProv, profileProv, _) {
        final activity = activitiesProv.getById(activityId);
        if (activity == null) {
          // Already navigating away — show empty transparent scaffold
          return const Scaffold(backgroundColor: Colors.transparent);
        }

        final userId = profileProv.profile.id;
        final isCreator = activity.creatorId == userId;
        final color = AppTheme.activityColor(activity.type);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final actives =
            activity.participants.where((p) => p.isActive).toList();
        final inactives =
            activity.participants.where((p) => !p.isActive).toList();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Sliver App Bar with colored header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        AppTheme.activityIcon(activity.type),
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        activity.type.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              activity.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                backgroundColor: color,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info cards
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.location_on_rounded,
                              label: 'Lieu',
                              value: activity.location,
                              color: color,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.group_rounded,
                              label: 'Joueurs',
                              value:
                                  '${activity.activeCount}/${activity.maxParticipants}',
                              color: color,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date & Heure',
                        value: _formatDateFull(activity.dateTime),
                        color: color,
                        isDark: isDark,
                        fullWidth: true,
                      ),

                      const SizedBox(height: 28),

                      // Participants section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Participants',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          if (activity.participants.length <
                              activity.maxParticipants)
                            TextButton.icon(
                              onPressed: () => _showAddParticipantDialog(
                                  context, activity, activitiesProv),
                              icon: const Icon(Icons.person_add_rounded,
                                  size: 16),
                              label: const Text('Ajouter'),
                              style: TextButton.styleFrom(
                                foregroundColor: color,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Actifs section
                      if (actives.isNotEmpty) ...[
                        _SectionLabel(
                          label: 'Actifs',
                          count: actives.length,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(height: 12),
                        _ParticipantsRow(
                          participants: actives,
                          activitiesProv: activitiesProv,
                          activityId: activityId,
                          isCreator: isCreator,
                          userId: userId,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Pas actifs section
                      if (inactives.isNotEmpty) ...[
                        _SectionLabel(
                          label: 'Pas actifs',
                          count: inactives.length,
                          color: AppTheme.primaryRed,
                        ),
                        const SizedBox(height: 12),
                        _ParticipantsRow(
                          participants: inactives,
                          activitiesProv: activitiesProv,
                          activityId: activityId,
                          isCreator: isCreator,
                          userId: userId,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Delete button
                      if (isCreator) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () =>
                              _confirmDelete(context, activitiesProv),
                          child: LiquidGlass(
                            borderRadius: BorderRadius.circular(16),
                            blurSigma: 18,
                            tint: AppTheme.primaryRed,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppTheme.primaryRed,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Supprimer l\'activité',
                                  style: TextStyle(
                                    color: AppTheme.primaryRed,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, ActivitiesProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'activité'),
        content: const Text(
            'Es-tu sûr de vouloir supprimer cette activité ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Capturer le messenger avant toute navigation
              final messenger = ScaffoldMessenger.of(context);
              // 2. Fermer le dialog
              Navigator.pop(ctx);
              // 3. Retourner à l'accueil AVANT de supprimer
              //    → évite que le Consumer2 affiche un écran noir
              if (context.mounted) Navigator.pop(context);
              // 4. Supprimer de la base locale
              await provider.deleteActivity(activityId);
              HapticFeedback.mediumImpact();
              // 5. Notification brève sur l'écran d'accueil
              messenger.showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Activité supprimée',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF2ECC71),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  duration: const Duration(seconds: 3),
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showAddParticipantDialog(
    BuildContext context,
    Activity activity,
    ActivitiesProvider provider,
  ) {
    final nameCtrl = TextEditingController();
    String? photoPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ajouter un participant',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final xfile = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 400,
                          imageQuality: 80,
                        );
                        if (xfile != null) {
                          final appDir =
                              await getApplicationDocumentsDirectory();
                          final dest =
                              '${appDir.path}/${const Uuid().v4()}.jpg';
                          await File(xfile.path).copy(dest);
                          setModalState(() => photoPath = dest);
                        }
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(ctx)
                            .colorScheme
                            .primaryContainer,
                        backgroundImage: photoPath != null
                            ? FileImage(File(photoPath!))
                            : null,
                        child: photoPath == null
                            ? Icon(
                                Icons.add_a_photo_outlined,
                                color: Theme.of(ctx)
                                    .colorScheme
                                    .onPrimaryContainer,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: nameCtrl,
                        autofocus: true,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          labelText: 'Nom du participant',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      final participant = Participant(
                        id: const Uuid().v4(),
                        name: name,
                        isActive: false,
                        photoPath: photoPath,
                      );
                      final added =
                          await provider.addParticipant(activityId, participant);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        if (!added) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Nombre maximum de participants atteint')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.activityColor(activity.type),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Ajouter',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final bool fullWidth;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(18),
      blurSigma: 16,
      tint: color,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.25 : 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.30),
                width: 0.8,
              ),
            ),
            child: Icon(icon, color: isDark ? Colors.white : color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: fullWidth ? 2 : 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SectionLabel(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _ParticipantsRow extends StatelessWidget {
  final List<Participant> participants;
  final ActivitiesProvider activitiesProv;
  final String activityId;
  final bool isCreator;
  final String userId;

  const _ParticipantsRow({
    required this.participants,
    required this.activitiesProv,
    required this.activityId,
    required this.isCreator,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: participants.map((p) {
        return ParticipantBubble(
          participant: p,
          onToggle: () =>
              activitiesProv.toggleParticipantStatus(activityId, p.id),
          onRemove: isCreator && !p.isCreator
              ? () => activitiesProv.removeParticipant(activityId, p.id)
              : null,
        );
      }).toList(),
    );
  }
}
