# Qibla Feature - Quick Reference Guide

## 🎯 Design Pattern
**Fixed-Target / Rotating-Compass**
- Kaaba fixed at top (0°)
- Compass rotates beneath
- User turns phone to align

---

## 📐 The Math

```dart
// Core formula
delta = shortestAngleDelta(phoneHeading, qiblaBearing)
compassRotation = -delta  // Negative = turn TO target

// Example: Phone at 350°, Qibla at 10°
delta = 20° (turn right)
compass rotates -20° (counter-clockwise)
```

---

## 🎨 Visual Layers (Bottom to Top)

1. **Background** - Dark (#0A0A0A)
2. **Compass Disk** - Rotating, with 24 ticks
3. **Center Hub** - Shows phone heading + delta
4. **Kaaba Badge** - Fixed at top, glows when aligned

---

## 📊 Alignment States

| State | Threshold | Color | Icon | Message |
|-------|-----------|-------|------|---------|
| **Perfect** | < 3° (1s hold) | 🟢 Green | ✓ | تم ضبط اتجاه القبلة |
| **Excellent** | < 3° | 🟢 Green | ⊙ | ممتاز! ثبّت الهاتف |
| **Good** | < 10° | 🟡 Amber | ⌖ | اقتربت جدًا |
| **Acceptable** | < 45° | ⚪ White | ← → | حرّك قليلاً |
| **Off** | > 45° | ⚫ Faded | ⊕ | استدر |

---

## ⚙️ Configuration (constants.dart)

```dart
// Accuracy Thresholds
kSuccessThreshold = 3.0°       // Perfect alignment
kNearThreshold = 10.0°         // Close to target
kToleranceThreshold = 45.0°    // Sharia-compliant

// Smoothing & Animation
kSmoothingFactor = 0.15        // Lower = stable, Higher = responsive
kAnimationDurationMs = 200     // Rotation animation speed
kStabilityDuration = 1000ms    // Hold time for "perfect"

// Calibration
kLowConfidenceThreshold = 40%  // Show calibration below this
kConfidenceSampleSize = 5      // Samples for variance calc
```

---

## 🔧 Tuning Guide

### Too Jittery?
```dart
kSmoothingFactor = 0.10  // More stable (slower response)
kAnimationDurationMs = 300  // Slower animations
```

### Too Sluggish?
```dart
kSmoothingFactor = 0.25  // More responsive (less stable)
kAnimationDurationMs = 150  // Faster animations
```

### Alignment Too Strict?
```dart
kSuccessThreshold = 5.0°  // Easier to achieve "perfect"
kStabilityDuration = 500ms  // Faster confirmation
```

---

## 🐛 Troubleshooting

### Compass Flickering
**Cause:** Smoothing factor too high
**Fix:** Decrease `kSmoothingFactor` to 0.10

### Slow Response
**Cause:** Smoothing factor too low
**Fix:** Increase `kSmoothingFactor` to 0.20

### False Alignments
**Cause:** Stability duration too short
**Fix:** Increase `kStabilityDuration` to 1500ms

### Constant Calibration Overlay
**Cause:** Low confidence threshold too high
**Fix:** Decrease `kLowConfidenceThreshold` to 30%

### Compass Not Rotating
**Check:**
1. Permission granted? → Check `_checkPermissionsAndStart()`
2. GPS enabled? → Check location services
3. Sensor supported? → Check `FlutterQiblah.androidDeviceSensorSupport()`
4. Stream active? → Check `qiblaProvider.notifier.startListening()`

---

## 🧪 Testing Checklist

### Visual Testing
- [ ] Smooth rotation (no jumps)
- [ ] Kaaba badge glows at alignment
- [ ] Center hub updates in real-time
- [ ] Color transitions smooth

### Functional Testing
- [ ] Alignment detection accurate
- [ ] Haptic feedback triggers
- [ ] Calibration overlay shows when needed
- [ ] Permission flow works

### Edge Cases
- [ ] 360° → 0° wrap (should be smooth)
- [ ] Near metal objects (should trigger calibration)
- [ ] Low GPS signal (should show confidence drop)
- [ ] Device rotation (should maintain state)

---

## 📱 User Instructions

### First Time Use
1. Grant location permission
2. Enable GPS
3. Hold phone flat
4. Turn body slowly
5. Watch compass rotate
6. Align indicator with Kaaba
7. Hold steady for 1 second
8. Feel haptic feedback ✓

### If Calibration Shows
1. Move away from metal
2. Move phone in figure-8 pattern
3. Repeat 3-4 times
4. Tap "فهمت" when done

---

## 🔍 Key Files Reference

| Component | File | Lines | Purpose |
|-----------|------|-------|---------|
| Math Utils | `angle_utils.dart` | ~70 | Circular calculations |
| State Model | `qibla_state.dart` | ~90 | Immutable state |
| Provider | `qibla_provider.dart` | ~170 | Stream + smoothing |
| Main Screen | `qibla_screen.dart` | ~230 | UI + permissions |
| Compass | `compass_view.dart` | ~280 | Visual layers |
| Calibration | `calibration_overlay.dart` | ~200 | Figure-8 guide |
| Constants | `constants.dart` | ~20 | Configuration |

---

## 🎯 Performance Tips

### Battery Optimization
- Stream auto-stops on screen dispose ✓
- Timers cleaned up properly ✓
- No background processing ✓

### Animation Optimization
- Single `TweenAnimationBuilder` per rotation
- Hardware-accelerated `Transform.rotate`
- Minimal widget rebuilds

### Memory Optimization
- Queue-based heading history (max 5)
- Proper subscription disposal
- No retained references

---

## 📚 Related Documentation

- [Full Implementation Guide](QIBLA_REDESIGN.md)
- [Session Summary](SESSION_SUMMARY.md)
- [Old Implementation Backup](lib/features/qibla/presentation/screens/qibla_screen.dart.backup)

---

## 🆘 Quick Fixes

### Reset to Default Settings
```dart
// In constants.dart
kSmoothingFactor = 0.15
kAnimationDurationMs = 200
kSuccessThreshold = 3.0
kStabilityDuration = Duration(milliseconds: 1000)
```

### Force Calibration Overlay
```dart
ref.read(qiblaProvider.notifier).showCalibration();
```

### Hide Calibration Overlay
```dart
ref.read(qiblaProvider.notifier).hideCalibration();
```

### Restart Stream
```dart
final notifier = ref.read(qiblaProvider.notifier);
notifier.stopListening();
await Future.delayed(Duration(milliseconds: 500));
notifier.startListening();
```

---

*Quick Reference v1.0 - February 24, 2026*
