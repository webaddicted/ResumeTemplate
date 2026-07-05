import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:template/global/theme/app_theme.dart';
import 'package:template/global/theme/text_style.dart';

/// Circular profile-photo picker used in both form wizards.
/// Uses the system photo picker (no extra permissions needed) and keeps
/// bytes in memory so it works on Android and web alike.
class PhotoPickerField extends StatefulWidget {
  const PhotoPickerField({
    super.key,
    required this.photo,
    required this.onChanged,
  });

  final Uint8List? photo;
  final ValueChanged<Uint8List?> onChanged;

  @override
  State<PhotoPickerField> createState() => _PhotoPickerFieldState();
}

class _PhotoPickerFieldState extends State<PhotoPickerField> {
  bool _picking = false;

  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file != null) {
        widget.onChanged(await file.readAsBytes());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: photo == null ? 'Add profile photo' : 'Change profile photo',
            child: InkWell(
              onTap: _picking ? null : _pick,
              customBorder: const CircleBorder(),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceAlt,
                  border: Border.all(
                    color: photo != null ? AppTheme.accent : AppTheme.outline,
                    width: photo != null ? 2 : 1,
                  ),
                  image: photo != null
                      ? DecorationImage(
                          image: MemoryImage(photo),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photo == null
                    ? (_picking
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.add_a_photo_rounded,
                            color: AppTheme.textSecondary,
                          ))
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Photo',
                  style: AppTextStyle.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  'Optional — shown in the header of your document.',
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _picking ? null : _pick,
                      icon: const Icon(Icons.photo_library_rounded, size: 18),
                      label: Text(photo == null ? 'Add photo' : 'Change'),
                    ),
                    if (photo != null)
                      TextButton.icon(
                        onPressed: () => widget.onChanged(null),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18),
                        label: const Text('Remove'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Labelled text field used across the form wizard.
class FormField2 extends StatelessWidget {
  const FormField2({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text.rich(
              TextSpan(
                text: label,
                style: AppTextStyle.titleSmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
                children: [
                  if (required)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppTheme.accent),
                    ),
                ],
              ),
            ),
          ),
          _StatefulField(
            value: value,
            hint: hint,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            semanticLabel: label,
          ),
        ],
      ),
    );
  }
}

/// Keeps a controller alive so the cursor doesn't jump while typing,
/// but syncs when the underlying value changes externally (e.g. Load Sample).
class _StatefulField extends StatefulWidget {
  const _StatefulField({
    required this.value,
    required this.onChanged,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.semanticLabel,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? semanticLabel;

  @override
  State<_StatefulField> createState() => _StatefulFieldState();
}

class _StatefulFieldState extends State<_StatefulField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant _StatefulField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      textField: true,
      child: TextField(
        controller: _controller,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        style: AppTextStyle.inputText.copyWith(color: AppTheme.textPrimary),
        decoration: InputDecoration(hintText: widget.hint),
      ),
    );
  }
}

/// Section header inside a form step.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyle.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 4),
              child: Text(
                subtitle!,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card wrapper for one repeatable entry (job, project, etc.)
/// with an optional remove action.
class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.title,
    required this.child,
    this.onRemove,
  });

  final String title;
  final Widget child;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.titleLarge.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              if (onRemove != null)
                Semantics(
                  button: true,
                  label: 'Remove $title',
                  child: IconButton(
                    onPressed: onRemove,
                    iconSize: 20,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// "+ Add …" button under a repeatable list.
class AddEntryButton extends StatelessWidget {
  const AddEntryButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.accent,
        side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.5)),
      ),
    );
  }
}

/// Step progress indicator (1–6) shown at the top of the wizard.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.current,
    required this.total,
    required this.titles,
  });

  final int current; // 1-based
  final int total;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(total * 2 - 1, (i) {
            if (i.isOdd) {
              final done = (i ~/ 2) + 1 < current;
              return Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: done ? AppTheme.accent : AppTheme.outline,
                ),
              );
            }
            final step = (i ~/ 2) + 1;
            final isActive = step == current;
            final isDone = step < current;
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive || isDone
                    ? AppTheme.accent
                    : AppTheme.surfaceAlt,
                border: Border.all(
                  color: isActive || isDone ? AppTheme.accent : AppTheme.outline,
                ),
              ),
              alignment: Alignment.center,
              child: isDone
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : Text(
                      '$step',
                      style: AppTextStyle.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? Colors.white
                            : AppTheme.textSecondary,
                      ),
                    ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          'Step $current of $total — ${titles[current - 1]}',
          style: AppTextStyle.titleSmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Dynamic list of single-line text items (expertise tags, bullet points).
class DynamicTextList extends StatelessWidget {
  const DynamicTextList({
    super.key,
    required this.items,
    required this.onChanged,
    required this.addLabel,
    this.hint,
  });

  final List<String> items;
  final ValueChanged<List<String>> onChanged;
  final String addLabel;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatefulField(
                    value: items[i],
                    hint: hint,
                    maxLines: 2,
                    semanticLabel: '$addLabel item ${i + 1}',
                    onChanged: (v) {
                      final next = [...items];
                      next[i] = v;
                      onChanged(next);
                    },
                  ),
                ),
                if (items.length > 1)
                  Semantics(
                    button: true,
                    label: 'Remove item ${i + 1}',
                    child: IconButton(
                      onPressed: () {
                        final next = [...items]..removeAt(i);
                        onChanged(next);
                      },
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        AddEntryButton(
          label: addLabel,
          onTap: () => onChanged([...items, '']),
        ),
      ],
    );
  }
}
