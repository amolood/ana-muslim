import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/theme/app_colors.dart';

class IslamicPdfViewerScreen extends StatefulWidget {
  const IslamicPdfViewerScreen({
    required this.url,
    required this.title,
    super.key,
  });

  final String url;
  final String title;

  @override
  State<IslamicPdfViewerScreen> createState() => _IslamicPdfViewerScreenState();
}

class _IslamicPdfViewerScreenState extends State<IslamicPdfViewerScreen> {
  bool _isLoading = true;
  String? _error;
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _pdfBytes = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse(widget.url),
            headers: const {
              'User-Agent': 'Mozilla/5.0',
              'Accept': 'application/pdf,*/*',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        throw Exception('empty-body');
      }

      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر عرض ملف PDF داخل التطبيق';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'عرض الكتاب',
          style: GoogleFonts.tajawal(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border(context)),
                        color: AppColors.surface(context),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _error != null
                          ? _PdfError(message: _error!, onRetry: _loadPdf)
                          : _pdfBytes == null
                          ? const SizedBox.shrink()
                          : SfPdfViewer.memory(
                              _pdfBytes!,
                              canShowScrollHead: true,
                              canShowScrollStatus: true,
                              onDocumentLoadFailed: (details) {
                                if (!mounted) return;
                                setState(() {
                                  _error = 'تعذر عرض ملف PDF';
                                  _isLoading = false;
                                });
                              },
                            ),
                    ),
                  ),
                  if (_isLoading && _error == null)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
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

class _PdfError extends StatelessWidget {
  const _PdfError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(color: Colors.red.shade300, fontSize: 14),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: onRetry,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(
            'إعادة المحاولة',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
