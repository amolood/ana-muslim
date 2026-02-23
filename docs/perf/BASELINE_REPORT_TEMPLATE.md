# Baseline Performance Report (Fillable)

## 1) Environment Summary
- App build/version:
- Flutter version:
- Device model:
- Android version:
- Test date/time:
- Battery/thermal state:
- Network state:
- Orientation policy:

## 2) Screen-by-Screen Measurements
- Source sheet: `/Users/molood/I'mMuslim/docs/perf/METRICS_BEFORE_AFTER.csv`

## 3) Top Observed Bottlenecks (Ranked)
1. Screen/Scenario:
   - Evidence:
   - Suspected root cause:
   - Confidence: Low / Medium / High
2. Screen/Scenario:
   - Evidence:
   - Suspected root cause:
   - Confidence: Low / Medium / High
3. Screen/Scenario:
   - Evidence:
   - Suspected root cause:
   - Confidence: Low / Medium / High

## 4) Data-Driven Inference Rules Applied
- UI frame spikes during sensor movement -> likely update/rebuild frequency too high.
- Memory baseline keeps rising after leaving screen + GC -> likely retained references/subscriptions.
- Raster spikes during scrolling -> likely rendering/layout/paint inefficiencies.
- CPU spikes matching timer intervals -> likely broad rebuilds or heavy per-tick formatting.

## 5) Initial Optimization Priorities
### Quick Wins
1.
2.
3.

### Medium Refactors
1.
2.
3.

### Deep Fixes (only if metrics justify)
1.
2.

## 6) Risk & Regression Notes
- Potential UX regressions:
- Behavioral regressions to test:
- Memory/performance trade-offs:
