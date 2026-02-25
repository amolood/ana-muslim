import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';

/// Example demonstrating how to use the new Ayah Range Playback feature
///
/// This feature allows playing a specific range of ayahs with:
/// - Precise stopping at the end ayah
/// - Loop mode for memorization
/// - Pause/resume/stop controls
/// - Automatic download management
/// - Visual highlighting and page navigation
class AyahRangePlaybackExample extends StatefulWidget {
  const AyahRangePlaybackExample({super.key});

  @override
  State<AyahRangePlaybackExample> createState() =>
      _AyahRangePlaybackExampleState();
}

class _AyahRangePlaybackExampleState extends State<AyahRangePlaybackExample> {
  int _selectedSurah = 55; // Ar-Rahman
  int _startAyah = 1;
  int _endAyah = 10;
  bool _loop = false;
  bool _stopAtEnd = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayah Range Playback Example'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title
          const Text(
            'تشغيل نطاق من الآيات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Surah Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختر السورة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<int>(
                    value: _selectedSurah,
                    isExpanded: true,
                    items: List.generate(
                      114,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('سورة ${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedSurah = value!;
                        // Reset ayah range when surah changes
                        _startAyah = 1;
                        _endAyah = 10;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Ayah Range Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'نطاق الآيات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('من الآية:'),
                            TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: _startAyah.toString(),
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final ayah = int.tryParse(value);
                                if (ayah != null) {
                                  setState(() => _startAyah = ayah);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('إلى الآية:'),
                            TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: _endAyah.toString(),
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final ayah = int.tryParse(value);
                                if (ayah != null) {
                                  setState(() => _endAyah = ayah);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Playback Options
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'خيارات التشغيل',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('تكرار النطاق (للحفظ)'),
                    subtitle: const Text('استمر في تكرار الآيات للحفظ'),
                    value: _loop,
                    onChanged: (value) => setState(() => _loop = value),
                  ),
                  SwitchListTile(
                    title: const Text('التوقف عند النهاية'),
                    subtitle: const Text('إيقاف التشغيل عند الوصول لآخر آية'),
                    value: _stopAtEnd,
                    onChanged: (value) => setState(() => _stopAtEnd = value),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Play Button
          ElevatedButton.icon(
            onPressed: _playRange,
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'تشغيل النطاق',
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Control Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _skipPrevious,
                  icon: const Icon(Icons.skip_previous),
                  label: const Text('السابقة'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pauseResume,
                  icon: const Icon(Icons.pause),
                  label: const Text('إيقاف/استئناف'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _skipNext,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('التالية'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Stop Button
          ElevatedButton.icon(
            onPressed: _stop,
            icon: const Icon(Icons.stop),
            label: const Text('إيقاف التشغيل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          // Predefined Examples
          const Text(
            'أمثلة سريعة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Example 1: Surah Ar-Rahman (55) ayahs 1-13
          _buildQuickExample(
            'سورة الرحمن (آيات 1-13)',
            'المطابقة بين آيات النعم',
            () => _playQuickExample(55, 1, 13),
          ),

          // Example 2: Al-Baqarah (2) ayahs 1-5 with loop
          _buildQuickExample(
            'سورة البقرة (آيات 1-5)',
            'مع التكرار للحفظ',
            () => _playQuickExample(2, 1, 5, loop: true),
          ),

          // Example 3: Al-Kahf (18) ayahs 1-10
          _buildQuickExample(
            'سورة الكهف (آيات 1-10)',
            'فضل حفظ أول عشر آيات',
            () => _playQuickExample(18, 1, 10),
          ),

          // Example 4: Yaseen (36) ayahs 1-12
          _buildQuickExample(
            'سورة يس (آيات 1-12)',
            'قلب القرآن',
            () => _playQuickExample(36, 1, 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickExample(
      String title, String subtitle, VoidCallback onTap) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.play_circle_outline),
        onTap: onTap,
      ),
    );
  }

  Future<void> _playRange() async {
    try {
      await AudioCtrl.instance.playAyahRange(
        context: context,
        surahNumber: _selectedSurah,
        startAyah: _startAyah,
        endAyah: _endAyah,
        loop: _loop,
        stopAtEnd: _stopAtEnd,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'بدأ تشغيل الآيات من $_startAyah إلى $_endAyah',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playQuickExample(
    int surah,
    int start,
    int end, {
    bool loop = false,
  }) async {
    setState(() {
      _selectedSurah = surah;
      _startAyah = start;
      _endAyah = end;
      _loop = loop;
    });

    await _playRange();
  }

  Future<void> _skipNext() async {
    try {
      await AudioCtrl.instance.skipNextInRange();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _skipPrevious() async {
    try {
      await AudioCtrl.instance.skipPreviousInRange();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _pauseResume() async {
    try {
      if (AudioCtrl.instance.state.isPlaying.value) {
        await AudioCtrl.instance.pausePlayer();
      } else {
        await AudioCtrl.instance.state.audioPlayer.play();
        AudioCtrl.instance.state.isPlaying.value = true;
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _stop() async {
    try {
      await AudioCtrl.instance.stopRangePlayback();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إيقاف التشغيل'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
