import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/activities_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/location_autocomplete_field.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen>
    with SingleTickerProviderStateMixin {
  ActivityType? _selectedType;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _maxPlayersCtrl = TextEditingController(text: '10');

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _maxPlayersCtrl.dispose();
    super.dispose();
  }

  void _selectType(ActivityType type) {
    setState(() {
      _selectedType = type;
      switch (type) {
        case ActivityType.foot:
          if (_nameCtrl.text.isEmpty || _nameCtrl.text == 'Tennis à Huizingen') {
            _nameCtrl.text = 'Football';
          }
          _locationCtrl.text = 'Wildersport';
          break;
        case ActivityType.tennis:
          _nameCtrl.text = 'Tennis à Huizingen';
          _locationCtrl.text = 'Huizingen';
          break;
        case ActivityType.autre:
          if (_nameCtrl.text == 'Football' ||
              _nameCtrl.text == 'Tennis à Huizingen') {
            _nameCtrl.clear();
          }
          if (_locationCtrl.text == 'Wildersport' ||
              _locationCtrl.text == 'Huizingen') {
            _locationCtrl.clear();
          }
          break;
      }
    });
    _animController.forward(from: 0);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _submit() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis un type d\'activité')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final profile = context.read<ProfileProvider>().profile;
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final activity = Activity.create(
      name: _nameCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      dateTime: dateTime,
      maxParticipants: int.tryParse(_maxPlayersCtrl.text) ?? 10,
      type: _selectedType!,
      creatorId: profile.id,
      creatorName: profile.displayName,
      creatorPhotoPath: profile.photoPath,
    );

    await context.read<ActivitiesProvider>().addActivity(activity);
    if (mounted) {
      HapticFeedback.lightImpact();
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgPrimary = _selectedType != null
        ? AppTheme.activityColor(_selectedType!)
        : const Color(0xFF7C4DFF);

    return GlassMeshBackground(
      primary: bgPrimary,
      secondary: Color.lerp(bgPrimary, Colors.blue, 0.5)!,
      tertiary: Color.lerp(bgPrimary, Colors.teal, 0.4)!,
      child: Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'NOUVELLE ACTIVITÉ',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 110, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type d\'activité',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
                    ),
              ),
              const SizedBox(height: 14),
              Row(
                children: ActivityType.values.map((type) {
                  final color = AppTheme.activityColor(type);
                  final isSelected = _selectedType == type;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: type != ActivityType.autre ? 10 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => _selectType(type),
                        child: AnimatedScale(
                          scale: isSelected ? 1.04 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: LiquidGlass(
                            borderRadius: BorderRadius.circular(20),
                            blurSigma: isSelected ? 22 : 16,
                            tint: isSelected ? color : null,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Icon(
                                  AppTheme.activityIcon(type),
                                  color: isDark ? Colors.white : color,
                                  size: 28,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  type.label,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : (isSelected
                                            ? color
                                            : const Color(0xFF1A1A2E)),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              if (_selectedType != null)
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Détails',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF1A1A2E),
                                  ),
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          controller: _nameCtrl,
                          label: 'Nom de l\'activité',
                          icon: Icons.edit_outlined,
                          validator: (v) => v?.trim().isEmpty == true
                              ? 'Champ obligatoire'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        LocationAutocompleteField(
                          controller: _locationCtrl,
                          validator: (v) => v?.trim().isEmpty == true
                              ? 'Champ obligatoire'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _PickerTile(
                                icon: Icons.calendar_today_outlined,
                                label: 'Date',
                                value: _formatDate(_selectedDate),
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PickerTile(
                                icon: Icons.access_time_rounded,
                                label: 'Heure',
                                value:
                                    '${_selectedTime.hour.toString().padLeft(2, '0')}h${_selectedTime.minute.toString().padLeft(2, '0')}',
                                onTap: _pickTime,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _FormField(
                          controller: _maxPlayersCtrl,
                          label: 'Nombre de joueurs max',
                          icon: Icons.group_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 1) {
                              return 'Minimum 1 joueur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: _submit,
                          child: LiquidGlass(
                            borderRadius: BorderRadius.circular(18),
                            blurSigma: 20,
                            tint: AppTheme.activityColor(
                                _selectedType ?? ActivityType.autre),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Ajouter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.activityColor(
                                          _selectedType ?? ActivityType.autre),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    )); // closes GlassMeshBackground + Scaffold
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E30) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
