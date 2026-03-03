import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';
import '../../../../core/theme/app_colors.dart';

/// بطاقة اختيار نطاق الحفظ
class RangeSelectorCard extends StatefulWidget {
  final Function(int surah, int start, int end) onRangeSelected;

  const RangeSelectorCard({
    super.key,
    required this.onRangeSelected,
  });

  @override
  State<RangeSelectorCard> createState() => _RangeSelectorCardState();
}

class _RangeSelectorCardState extends State<RangeSelectorCard> {
  int _selectedSurah = 1;
  int _startAyah = 1;
  int _endAyah = 7;
  int _maxAyahs = 7; // عدد آيات السورة المختارة

  final TextEditingController _startController = TextEditingController(text: '1');
  final TextEditingController _endController = TextEditingController(text: '7');

  @override
  void initState() {
    super.initState();
    _updateMaxAyahs();
  }

  void _updateMaxAyahs() {
    try {
      final surah = QuranCtrl.instance.surahs
          .firstWhere((s) => s.surahNumber == _selectedSurah);
      setState(() {
        _maxAyahs = surah.ayahs.length;
        // تحديث نهاية النطاق إذا كانت أكبر من عدد الآيات
        if (_endAyah > _maxAyahs) {
          _endAyah = _maxAyahs;
          _endController.text = _maxAyahs.toString();
        }
      });
    } catch (e) {
      // في حالة عدم تحميل البيانات بعد
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppColors.cardDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'اختر نطاق الحفظ',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // اختيار السورة
            Text(
              'السورة',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isDark ? AppColors.backgroundDeepDark : Colors.grey[50],
              ),
              child: DropdownButton<int>(
                value: _selectedSurah,
                isExpanded: true,
                underline: const SizedBox(),
                items: List.generate(
                  114,
                  (index) {
                    final surahNum = index + 1;
                    String surahName = '';
                    try {
                      final surah = QuranCtrl.instance.surahs
                          .firstWhere((s) => s.surahNumber == surahNum);
                      surahName = surah.arabicName;
                    } catch (e) {
                      surahName = 'سورة $surahNum';
                    }
                    return DropdownMenuItem(
                      value: surahNum,
                      child: Text(
                        '$surahNum. $surahName',
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedSurah = value!;
                    _updateMaxAyahs();
                    // إعادة تعيين النطاق
                    _startAyah = 1;
                    _endAyah = _maxAyahs > 10 ? 10 : _maxAyahs;
                    _startController.text = '1';
                    _endController.text = _endAyah.toString();
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // اختيار النطاق
            Text(
              'النطاق (من - إلى)',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                // من الآية
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isDark ? AppColors.backgroundDeepDark : Colors.grey[50],
                    ),
                    child: TextField(
                      controller: _startController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'من',
                        hintStyle: GoogleFonts.tajawal(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      onChanged: (value) {
                        final ayah = int.tryParse(value);
                        if (ayah != null && ayah >= 1 && ayah <= _maxAyahs) {
                          setState(() => _startAyah = ayah);
                        }
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),

                // إلى الآية
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isDark ? AppColors.backgroundDeepDark : Colors.grey[50],
                    ),
                    child: TextField(
                      controller: _endController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'إلى',
                        hintStyle: GoogleFonts.tajawal(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      onChanged: (value) {
                        final ayah = int.tryParse(value);
                        if (ayah != null && ayah >= 1 && ayah <= _maxAyahs) {
                          setState(() => _endAyah = ayah);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // معلومات النطاق
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfo('عدد الآيات', '${_endAyah - _startAyah + 1}', isDark),
                  Container(
                    width: 1,
                    height: 30,
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  _buildInfo('إجمالي السورة', '$_maxAyahs', isDark),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // زر التطبيق
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_startAyah <= _endAyah) {
                    widget.onRangeSelected(_selectedSurah, _startAyah, _endAyah);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'بداية النطاق يجب أن تكون أقل من أو تساوي النهاية',
                          style: GoogleFonts.tajawal(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'تطبيق النطاق',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }
}
