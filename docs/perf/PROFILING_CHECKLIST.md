# Flutter Profile Baseline Checklist (Real Android Device)

## Objective
- Measure runtime behavior on real device in Profile mode.
- Build repeatable before/after data for optimization work.

## Device & Environment
1. Use one fixed mid-range Android device for all runs.
2. Keep battery >= 60%.
3. Disable Battery Saver and Performance throttling modes.
4. Close heavy background apps/downloads.
5. Keep device cool; avoid charging during long runs.
6. Use same network conditions across baseline and re-test.

## Build & Run (Profile Mode)
1. Connect device:
   - `adb devices`
   - `flutter devices`
2. Run app in profile:
   - `bash tool/profile_android.sh <DEVICE_ID>`
3. Keep this run command as-is for all baseline/re-test sessions.

## DevTools Attach
1. From run logs, open VM Service URL.
2. Open DevTools Performance, Memory, and CPU Profiler tabs.
3. Before each scenario:
   - Press GC once in Memory.
   - Wait 5 seconds idle.
   - Start recording.

## Repeatability Rules
1. Same device, same build, same orientation.
2. Same scenario duration and action sequence.
3. Run each scenario 3 times.
4. Use median values for before/after comparison.

## Capture Order
1. Qibla scenarios (Q1, Q2, Q3)
2. Home scenarios (H1, H2, H3)
3. Prayer Times scenarios (P1, P2, P3)

## What to Save
1. Fill `/Users/molood/I'mMuslim/docs/perf/METRICS_BEFORE_AFTER.csv`
2. Fill `/Users/molood/I'mMuslim/docs/perf/BASELINE_REPORT_TEMPLATE.md`
3. Save timeline screenshots for top 3 worst spikes.
