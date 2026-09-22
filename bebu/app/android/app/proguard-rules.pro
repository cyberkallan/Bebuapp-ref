# Keep all data classes (common in Kotlin)
-keep class com.yourpackage.** { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Flutter & R8 compatibility
-dontwarn androidx.**
-dontwarn io.flutter.embedding.**

# Gson (if using)
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
