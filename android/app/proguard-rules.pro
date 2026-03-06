# ============================================================================
# STRIPE SDK - KEEP ALL CLASSES AND INNER CLASSES
# ============================================================================

# Mantener TODAS las clases de Stripe sin obfuscación
-keep class com.stripe.** { *; }
-keepnames class com.stripe.** { *; }

# Mantener específicamente Push Provisioning y clases internas
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity$** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider { *; }

# Prevenir obfuscación de método références a Stripe
-keepclasseswithmembernames class com.stripe.** {
    *;
}

# ============================================================================
# REACT NATIVE STRIPE SDK
# ============================================================================
-keep class com.reactnativestripesdk.** { *; }
-keepnames class com.reactnativestripesdk.** { *; }
-keepclasseswithmembernames class com.reactnativestripesdk.** {
    *;
}

# Mantener específicamente clases internas de RNSS
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.PushProvisioningProxy$** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.DefaultPushProvisioningProxy { *; }

# ============================================================================
# FIREBASE (usado por la app)
# ============================================================================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keepclasseswithmembernames class com.google.firebase.** {
    *;
}

# ============================================================================
# GENERAL RULES
# ============================================================================

# Prevenir obfuscación de enums
-keepclassmembers enum * {
    <fields>;
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Prevenir obfuscación de constructores
-keepclasseswithmembers class * {
    public <init>(...);
}

# Mantener métodos de serialización
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ============================================================================
# ADDITIONAL STRIPE PAYMENT CLASSES
# ============================================================================

# Mantener clases de pagos de Stripe
-keep class com.stripe.android.payments.** { *; }
-keep class com.stripe.android.paymentsheet.** { *; }
-keep class com.stripe.android.paymentsheet.paymentsheetfragment { *; }

# Mantener interfaces y abstract classes
-keep interface com.stripe.** { *; }
-keep abstract class com.stripe.** { *; }

# Prevenir eliminación de código que es llamado mediante reflexión
-keepclasseswithmembers class com.stripe.** {
    public static void main(java.lang.String[]);
}

