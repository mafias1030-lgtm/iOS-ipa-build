import 'dart:io';
import 'package:flutter/material.dart';
import '../models/participant.dart';

class ParticipantBubble extends StatelessWidget {
  final Participant participant;
  final bool showName;
  final VoidCallback? onToggle;
  final VoidCallback? onRemove;

  const ParticipantBubble({
    super.key,
    required this.participant,
    this.showName = true,
    this.onToggle,
    this.onRemove,
  });

  String get _initials {
    final parts = participant.name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color =
        participant.isActive ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onToggle,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 3),
                    color: isDark
                        ? const Color(0xFF1E1E30)
                        : scheme.surfaceContainerHighest,
                  ),
                  child: ClipOval(
                    child: participant.photoPath != null &&
                            File(participant.photoPath!).existsSync()
                        ? Image.file(
                            File(participant.photoPath!),
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              _initials,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                  ),
                ),
                if (participant.isCreator)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF39C12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star,
                          size: 12, color: Colors.white),
                    ),
                  ),
                if (onRemove != null && !participant.isCreator)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE74C3C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            if (showName) ...[
              const SizedBox(height: 6),
              Text(
                participant.name.split(' ').first,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
