# Flutter rules
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Firebase rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Razorpay rules
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keep class proguard.annotation.** { *; }
-dontwarn proguard.annotation.**

# Keep your app-specific classes
-keep class com.quick.primeleads.** { *; }