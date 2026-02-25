# Keep Flutter runtime and plugin registration classes.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep app entry points.
-keep class com.anaalmuslim.app.** { *; }

# Ignore missing Play Core classes (removed for SDK 34 compatibility)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager**

# Pusher Channels Flutter - SLF4J Logger
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }
-keepclassmembers class org.slf4j.** { *; }

# Pusher Channels
-keep class com.pusher.** { *; }
-keepclassmembers class com.pusher.** { *; }
-dontwarn com.pusher.**
