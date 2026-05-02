import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/liquid_glass.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _firstNameCtrl = TextEditingController(text: profile.firstName);
    _lastNameCtrl = TextEditingController(text: profile.lastName);
    _firstNameCtrl.addListener(_onChanged);
    _lastNameCtrl.addListener(_onChanged);
  }

  void _onChanged() => setState(() => _hasChanges = true);

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choisir une photo',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.photo_library_rounded),
              ),
              title: const Text('Galerie photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.camera_alt_rounded),
              ),
              title: const Text('Appareil photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (choice == null) return;

    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: choice,
      maxWidth: 600,
      imageQuality: 85,
    );

    if (xfile != null && mounted) {
      final appDir = await getApplicationDocumentsDirectory();
      final dest = '${appDir.path}/profile_${const Uuid().v4()}.jpg';
      await File(xfile.path).copy(dest);
      if (!mounted) return;
      await context.read<ProfileProvider>().updateProfile(photoPath: dest);
    }
  }

  Future<void> _saveProfile() async {
    await context.read<ProfileProvider>().updateProfile(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
        );
    setState(() => _hasChanges = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil sauvegardé !'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassMeshBackground(
      primary: const Color(0xFF8E44AD),
      secondary: const Color(0xFF3498DB),
      tertiary: const Color(0xFFE91E63),
      child: Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'PROFIL',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 22,
          ),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, prov, _) {
          final profile = prov.profile;

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 110, 20, 40),
              child: Column(
                children: [
                  // Avatar section
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickPhoto,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: scheme.primaryContainer,
                              backgroundImage: profile.photoPath != null &&
                                      File(profile.photoPath!).existsSync()
                                  ? FileImage(File(profile.photoPath!))
                                  : null,
                              child: profile.photoPath == null
                                  ? Text(
                                      profile.initials,
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: scheme.onPrimaryContainer,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: _pickPhoto,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: scheme.surface, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    profile.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Profile fields
                  _SectionTitle(title: 'Informations personnelles'),
                  const SizedBox(height: 14),
                  LiquidGlass(
                    borderRadius: BorderRadius.circular(18),
                    blurSigma: 18,
                    child: Column(
                      children: [
                        TextField(
                          controller: _firstNameCtrl,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            labelText: 'Prénom',
                            prefixIcon: Icon(Icons.badge_outlined, size: 20),
                            border: InputBorder.none,
                            filled: false,
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Colors.white24,
                        ),
                        TextField(
                          controller: _lastNameCtrl,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            labelText: 'Nom',
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                            border: InputBorder.none,
                            filled: false,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_hasChanges) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Sauvegarder',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Preferences
                  _SectionTitle(title: 'Préférences'),
                  const SizedBox(height: 14),
                  LiquidGlass(
                    borderRadius: BorderRadius.circular(18),
                    blurSigma: 18,
                    child: SwitchListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      value: prov.isDarkMode,
                      onChanged: (_) => prov.toggleDarkMode(),
                      title: const Text(
                        'Mode sombre',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        prov.isDarkMode ? 'Activé' : 'Désactivé',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      secondary: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: prov.isDarkMode
                              ? const Color(0xFF1A1A2E)
                              : const Color(0xFFFFF9C4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          prov.isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: prov.isDarkMode
                              ? Colors.white70
                              : Colors.orange,
                          size: 22,
                        ),
                      ),
                      activeColor: scheme.primary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App version
                  Text(
                    'Activités entre amis v1.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    )); // closes GlassMeshBackground + Scaffold
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _SettingsCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}
