import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';

class _LocationCandidate {
  const _LocationCandidate({
    required this.lat,
    required this.lng,
    required this.label,
    required this.source,
  });

  final double lat;
  final double lng;
  final String label;
  final String source;
}

class ManualLocationTile extends ConsumerStatefulWidget {
  final ManualLocation? manualLoc;
  const ManualLocationTile({super.key, required this.manualLoc});

  @override
  ConsumerState<ManualLocationTile> createState() => _ManualLocationTileState();
}

class _ManualLocationTileState extends ConsumerState<ManualLocationTile> {
  bool _loading = false;
  String? _error;

  Future<void> _pickLocation() async {
    var queryText = widget.manualLoc?.name ?? '';
    var searching = false;
    var gettingCurrentLocation = false;
    var sheetError = '';
    var results = <_LocationCandidate>[];

    final selectedCandidate = await showModalBottomSheet<_LocationCandidate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> runSearch() async {
              final query = queryText.trim();
              if (query.isEmpty) {
                setSheetState(() {
                  sheetError = 'اكتب اسم مدينة أو دولة أو أدخل الإحداثيات';
                });
                return;
              }

              setSheetState(() {
                searching = true;
                sheetError = '';
              });

              try {
                final found = await _searchLocationCandidates(query);
                if (!ctx.mounted) return;
                setSheetState(() {
                  results = found;
                  if (found.isEmpty) {
                    sheetError =
                        'لم نجد نتائج. جرّب كتابة الدولة/المدينة بشكل مختلف أو استخدم الإحداثيات';
                  }
                });
              } catch (_) {
                if (!ctx.mounted) return;
                setSheetState(() {
                  sheetError = 'تعذّر البحث الآن، حاول مرة أخرى';
                });
              } finally {
                if (ctx.mounted) {
                  setSheetState(() {
                    searching = false;
                  });
                }
              }
            }

            Future<void> useCurrentLocation() async {
              setSheetState(() {
                gettingCurrentLocation = true;
                sheetError = '';
              });
              try {
                final candidate = await _buildCurrentLocationCandidate();
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop(candidate);
              } catch (e) {
                if (!ctx.mounted) return;
                setSheetState(() {
                  sheetError = e.toString();
                });
              } finally {
                if (ctx.mounted) {
                  setSheetState(() {
                    gettingCurrentLocation = false;
                  });
                }
              }
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    12 + MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(ctx).size.height * 0.76,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'اختيار الموقع الجغرافي',
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'يمكنك البحث بأي مدينة/محافظة/دولة حول العالم أو إدخال الإحداثيات (lat,lng)',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: queryText,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onChanged: (value) => queryText = value,
                          onFieldSubmitted: (_) => runSearch(),
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'مثال: مكة المكرمة أو 21.4225,39.8262',
                            hintStyle: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: Colors.white38,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.07),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: searching ? null : runSearch,
                                icon: searching
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Icon(Icons.travel_explore_rounded),
                                label: Text(
                                  'بحث',
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size.fromHeight(42),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: gettingCurrentLocation
                                    ? null
                                    : useCurrentLocation,
                                icon: gettingCurrentLocation
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : const Icon(Icons.my_location_rounded),
                                label: Text(
                                  'استخدم موقعي',
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                  minimumSize: const Size.fromHeight(42),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (sheetError.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            sheetError,
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: Colors.red.shade300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Expanded(
                          child: results.isEmpty
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(14),
                                  child: Text(
                                    'ابدأ البحث لعرض المناطق المتاحة',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 13,
                                      color: AppColors.textSecondaryDark,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: results.length,
                                  separatorBuilder: (_, index) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final candidate = results[index];
                                    final coords =
                                        '${candidate.lat.toStringAsFixed(4)}, ${candidate.lng.toStringAsFixed(4)}';
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () =>
                                          Navigator.of(ctx).pop(candidate),
                                      child: Ink(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          10,
                                          12,
                                          10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceElevated(
                                            context,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border(context),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_rounded,
                                              color: AppColors.primary,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    candidate.label,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.tajawal(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${candidate.source} • $coords',
                                                    style: GoogleFonts.tajawal(
                                                      fontSize: 11.5,
                                                      color: AppColors
                                                          .textSecondaryDark,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_left_rounded,
                                              color:
                                                  AppColors.textSecondaryDark,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    if (selectedCandidate == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(manualLocationProvider.notifier)
          .save(
            selectedCandidate.lat,
            selectedCandidate.lng,
            selectedCandidate.label,
          );
      ref.invalidate(locationProvider);
      ref.invalidate(locationNameProvider);
      ref.invalidate(prayerTimesProvider);
      ref.invalidate(adjustedPrayerTimesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'تم تحديد الموقع: ${selectedCandidate.label}',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'تعذّر حفظ الموقع');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<_LocationCandidate>> _searchLocationCandidates(
    String query,
  ) async {
    final candidates = <_LocationCandidate>[];
    final seen = <String>{};

    void addCandidate(_LocationCandidate candidate) {
      final key =
          '${candidate.lat.toStringAsFixed(5)},${candidate.lng.toStringAsFixed(5)}';
      if (!seen.add(key)) return;
      candidates.add(candidate);
    }

    final manualCoords = _tryParseCoordinates(query);
    if (manualCoords != null) {
      addCandidate(manualCoords);
    }

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'jsonv2',
        'limit': '10',
        'addressdetails': '1',
        'accept-language': 'ar,en',
      });
      final response = await http
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'User-Agent': "I'mMuslim/1.0 (Islamic App)",
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          for (final item in decoded.take(10)) {
            if (item is! Map) continue;
            final lat = double.tryParse('${item['lat'] ?? ''}');
            final lng = double.tryParse('${item['lon'] ?? ''}');
            if (lat == null || lng == null) continue;
            final label = (item['display_name'] ?? '').toString().trim();
            addCandidate(
              _LocationCandidate(
                lat: lat,
                lng: lng,
                label: label.isEmpty ? query : label,
                source: 'نتائج عالمية',
              ),
            );
          }
        }
      }
    } catch (_) {
      // Ignore and continue with local geocoder fallback.
    }

    if (candidates.isEmpty) {
      try {
        final geocoded = await locationFromAddress(
          query,
        ).timeout(const Duration(seconds: 10));
        for (final loc in geocoded.take(8)) {
          addCandidate(
            _LocationCandidate(
              lat: loc.latitude,
              lng: loc.longitude,
              label: query,
              source: 'نتائج الجهاز',
            ),
          );
        }
      } catch (_) {
        // Ignored: handled by empty results in caller.
      }
    }

    return candidates;
  }

  Future<_LocationCandidate> _buildCurrentLocationCandidate() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('فعّل خدمة الموقع (GPS) ثم حاول مرة أخرى');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('تم رفض صلاحية الموقع');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('صلاحية الموقع مرفوضة دائمًا. فعّلها من إعدادات الجهاز');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 12),
      ),
    );
    final label = await _labelForCoordinates(
      position.latitude,
      position.longitude,
      fallback: 'موقعي الحالي',
    );
    return _LocationCandidate(
      lat: position.latitude,
      lng: position.longitude,
      label: label,
      source: 'GPS',
    );
  }

  Future<String> _labelForCoordinates(
    double lat,
    double lng, {
    required String fallback,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city =
            place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            '';
        final country = place.country ?? '';
        if (city.isNotEmpty && country.isNotEmpty) return '$city، $country';
        if (city.isNotEmpty) return city;
        if (country.isNotEmpty) return country;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[PrayerAdjustment] geocoding failed: $e');
    }
    return fallback;
  }

  _LocationCandidate? _tryParseCoordinates(String query) {
    final normalized = query
        .trim()
        .replaceAll('،', ',')
        .replaceAll(';', ',')
        .replaceAll(RegExp(r'\s+'), '');
    final parts = normalized.split(',');
    if (parts.length != 2) return null;

    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;

    return _LocationCandidate(
      lat: lat,
      lng: lng,
      label: 'إحداثيات يدوية',
      source: 'إحداثيات',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSet = widget.manualLoc != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSet
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.borderTeal,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSet ? Icons.location_on : Icons.location_off_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الموقع الجغرافي',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isSet ? widget.manualLoc!.name : 'يستخدم GPS تلقائيًا',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: isSet
                            ? AppColors.primary
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                    if (isSet)
                      Text(
                        '${widget.manualLoc!.lat.toStringAsFixed(4)}, ${widget.manualLoc!.lng.toStringAsFixed(4)}',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: AppColors.textSecondaryDark,
                        ),
                      )
                    else
                      Text(
                        'ابحث عالميًا بالمدينة/الدولة أو بالإحداثيات',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                  ],
                ),
              ),
              if (_loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else ...[
                if (isSet)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                    onPressed: () {
                      ref.read(manualLocationProvider.notifier).clear();
                      setState(() => _error = null);
                    },
                    tooltip: 'إزالة الموقع اليدوي',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _pickLocation,
                  icon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  label: Text(
                    isSet ? 'تغيير' : 'تحديد',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: Colors.red.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
