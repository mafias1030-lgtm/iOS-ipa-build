import 'dart:async';
import 'package:flutter/material.dart';
import '../services/places_service.dart';

class LocationAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const LocationAutocompleteField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  State<LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState
    extends State<LocationAutocompleteField> {
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  Timer? _debounce;
  List<PlacePrediction> _suggestions = [];
  bool _loading = false;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _hideDropdown();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hideDropdown();
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    final text = widget.controller.text;

    if (text.length < 2) {
      if (_showDropdown) _hideDropdown();
      return;
    }

    _debounce =
        Timer(const Duration(milliseconds: 320), () => _fetch(text));
  }

  Future<void> _fetch(String query) async {
    if (!mounted) return;
    setState(() => _loading = true);
    _updateOverlay();

    final results = await PlacesService.autocomplete(query);

    if (!mounted) return;
    setState(() {
      _suggestions = results;
      _loading = false;
      _showDropdown = results.isNotEmpty;
    });

    if (results.isNotEmpty) {
      _showOverlay();
    } else {
      _hideDropdown();
    }
  }

  void _onSelectSuggestion(PlacePrediction prediction) {
    widget.controller.text = prediction.description;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
    _focusNode.unfocus();
    _hideDropdown();
  }

  // ─── Overlay helpers ─────────────────────────────────────────────────────

  void _showOverlay() {
    _hideDropdown();
    final overlay = Overlay.of(context);
    _overlayEntry = _buildOverlayEntry();
    overlay.insert(_overlayEntry!);
    setState(() => _showDropdown = true);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _showDropdown = false);
  }

  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Positioned(
          width: _getFieldWidth(),
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 58),
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                builder: (_, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * -8),
                    child: child,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E30)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _suggestions
                                .asMap()
                                .entries
                                .map((entry) {
                              final i = entry.key;
                              final p = entry.value;
                              return _SuggestionTile(
                                prediction: p,
                                isLast: i == _suggestions.length - 1,
                                isDark: isDark,
                                onTap: () => _onSelectSuggestion(p),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getFieldWidth() {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 300;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        validator: widget.validator,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: 'Lieu',
          prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
          suffixIcon: _loading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _showDropdown
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        widget.controller.clear();
                        _hideDropdown();
                      },
                    )
                  : null,
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final PlacePrediction prediction;
  final bool isLast;
  final bool isDark;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.prediction,
    required this.isLast,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.place_rounded,
                    size: 18,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediction.mainText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (prediction.secondaryText.isNotEmpty)
                        Text(
                          prediction.secondaryText,
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.north_west_rounded,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 60,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
      ],
    );
  }
}
