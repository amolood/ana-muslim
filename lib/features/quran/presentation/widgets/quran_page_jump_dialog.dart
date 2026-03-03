import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';

/// Dialog that allows the user to jump directly to a specific Mushaf page.
class QuranPageJumpDialog extends StatefulWidget {
  const QuranPageJumpDialog({super.key, required this.initialPage});

  final int initialPage;

  @override
  State<QuranPageJumpDialog> createState() => _QuranPageJumpDialogState();
}

class _QuranPageJumpDialogState extends State<QuranPageJumpDialog> {
  late String _input;

  @override
  void initState() {
    super.initState();
    _input = widget.initialPage.toString();
  }

  void _submit() {
    Navigator.of(context).pop(int.tryParse(_input.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        title: Text(
          'الانتقال إلى صفحة',
          style: GoogleFonts.tajawal(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: TextFormField(
          key: const ValueKey('page-jump-input'),
          initialValue: _input,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onChanged: (value) => _input = value,
          onFieldSubmitted: (_) => _submit(),
          style: GoogleFonts.tajawal(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'من 1 إلى 604',
            hintStyle: GoogleFonts.tajawal(
              color: context.colors.textSecondary,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.colors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: context.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: _submit,
            child: Text(
              'انتقال',
              style: GoogleFonts.tajawal(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
