import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val defaultDebugAppId = "com.example.hobby_hub"
val keystoreProperties = Properties().apply {
    val file = rootProject.file("keystore.properties")
    if (file.exists()) {
        file.inputStream().use { load(it) }
    }
}

fun secret(key: String): String? {
    return (project.findProperty(key) as String?)
        ?: System.getenv(key)
        ?: keystoreProperties.getProperty(key)
}

val configuredAppId =
    secret("HH_APPLICATION_ID")
val appId = configuredAppId ?: defaultDebugAppId

val releaseStoreFile =
    secret("HH_RELEASE_STORE_FILE")
val releaseStorePassword =
    secret("HH_RELEASE_STORE_PASSWORD")
val releaseKeyAlias =
    secret("HH_RELEASE_KEY_ALIAS")
val releaseKeyPassword =
    secret("HH_RELEASE_KEY_PASSWORD")
val isReleaseTaskRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}

if (isReleaseTaskRequested && (configuredAppId.isNullOrBlank() || appId == defaultDebugAppId)) {
    throw GradleException(
        "Release applicationId is not configured. " +
            "Set HH_APPLICATION_ID to your production package (not com.example.hobby_hub).",
    )
}

android {
    namespace = appId
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = appId
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (
                releaseStoreFile.isNullOrBlank() ||
                    releaseStorePassword.isNullOrBlank() ||
                    releaseKeyAlias.isNullOrBlank() ||
                    releaseKeyPassword.isNullOrBlank()
            ) {
                if (isReleaseTaskRequested) {
                    throw GradleException(
                        "Release signing is not configured. " +
                            "Set HH_RELEASE_STORE_FILE, HH_RELEASE_STORE_PASSWORD, " +
                            "HH_RELEASE_KEY_ALIAS and HH_RELEASE_KEY_PASSWORD in gradle.properties or environment.",
                    )
                }

                val debugConfig = signingConfigs.getByName("debug")
                storeFile = debugConfig.storeFile
                storePassword = debugConfig.storePassword
                keyAlias = debugConfig.keyAlias
                keyPassword = debugConfig.keyPassword
                return@create
            }

            storeFile = file(releaseStoreFile)
            storePassword = releaseStorePassword
            keyAlias = releaseKeyAlias
            keyPassword = releaseKeyPassword
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
