# Repeatable Profiling Scenarios (Qibla / Home / Prayer Times)

## Global Fixed Conditions
1. Same device and build for all runs.
2. Same orientation during a given scenario.
3. Record 2 seconds before action start and 2 seconds after action end.
4. Repeat each scenario 3 times.
5. Keep user interactions identical.

## Qibla (Highest Priority)

### Q1: Continuous Sensor Movement
- Entry path: Home -> Qibla.
- Duration: 60s.
- Actions:
  1. Move phone slowly in all directions continuously.
  2. Avoid abrupt shakes.
- Repetitions: 3.
- Focus metrics: UI P95/max frame time, jank count, CPU spikes, GC/min.

### Q2: Near-Alignment Stability
- Entry path: Home -> Qibla.
- Duration: 40s.
- Actions:
  1. Approach alignment and hold for 10s.
  2. Move out of alignment for 5s.
  3. Re-align and hold for 10s.
- Repetitions: 3.
- Focus metrics: state flicker signs, frame spikes near threshold, CPU bursts.

### Q3: Enter/Exit Stress
- Entry path: Home -> Qibla.
- Duration: 5 cycles.
- Actions:
  1. Enter Qibla, stay 8s.
  2. Exit to previous screen.
  3. Re-enter.
- Repetitions: 3.
- Focus metrics: memory end after exit, subscription leak signs, frame spikes on enter.

## Home

### H1: Idle Stability
- Entry path: App launch -> Home.
- Duration: 60s.
- Actions: no touch input.
- Repetitions: 3.
- Focus metrics: periodic frame spikes, timer-driven CPU spikes, GC cadence.

### H2: Scroll + Navigation
- Entry path: Home.
- Duration: 45s.
- Actions:
  1. Scroll top -> bottom -> top (3 times).
  2. Open one card/details page and return.
- Repetitions: 3.
- Focus metrics: raster spikes, janky frames on scroll, nav transition spikes.

### H3: Audio Card Active (if available)
- Entry path: Home with active playback card.
- Duration: 60s.
- Actions:
  1. Start/continue playback.
  2. Observe progress updates.
  3. Navigate away/back once.
- Repetitions: 3.
- Focus metrics: progress-driven rebuild spam, CPU periodic spikes, memory drift.

## Prayer Times

### P1: Timer Baseline
- Entry path: Home -> Prayer Times.
- Duration: 90s.
- Actions: keep screen open, no interaction.
- Repetitions: 3.
- Focus metrics: per-tick CPU spikes, frame jitter, GC frequency.

### P2: Scroll During Ticks
- Entry path: Prayer Times.
- Duration: 60s.
- Actions:
  1. Scroll list up/down 3 times while countdown runs.
- Repetitions: 3.
- Focus metrics: combined tick + scroll impact, raster/UI contention.

### P3: Tab Transition Load
- Entry path: Prayer Times <-> Home.
- Duration: 5 cycles.
- Actions:
  1. Open Prayer Times for 10s.
  2. Return Home for 10s.
  3. Repeat.
- Repetitions: 3.
- Focus metrics: offscreen timer pause effectiveness, memory and CPU on tab swap.
