// Constants for Qibla feature

// Alignment thresholds
const double kSuccessThreshold = 5.0; // degrees - small deviation is accepted and triggers success feedback
const double kNearThreshold = 10.0; // degrees - user is close to alignment
const double kToleranceThreshold = 45.0; // degrees - acceptable for prayer outside Mecca

// Smoothing & Animation
const double kSmoothingFactor = 0.15; // EMA filter - lower = more stable, higher = more responsive
const int kAnimationDurationMs = 200; // milliseconds for compass rotation animation

// Stability Logic
const Duration kStabilityDuration = Duration(milliseconds: 1000); // hold time before confirming alignment

// Confidence & Calibration
const double kLowConfidenceThreshold = 40.0; // below this, show calibration overlay
const int kConfidenceSampleSize = 5; // number of samples to calculate variance

// Visual Constants
const double kCompassSizeRatio = 0.75; // relative to screen width
const double kCenterHubSize = 140.0;
const double kKaabaIconSize = 32.0;
const int kCompassTickCount = 24; // ticks around the compass (every 15 degrees)
