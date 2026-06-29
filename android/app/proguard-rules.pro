# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# just_audio
-keep class com.ryanheise.just_audio.** { *; }

# home_widget
-keep class es.antonborri.home_widget.** { *; }

# Kotlin
-dontwarn kotlin.**
-keep class kotlin.** { *; }
