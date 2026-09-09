import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.imaanly.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.imaanly.app"
        minSdkVersion(flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = (keystoreProperties["keyAlias"] as? String) ?: ""
            keyPassword = (keystoreProperties["keyPassword"] as? String) ?: ""
            storeFile = (keystoreProperties["storeFile"] as? String)?.let { file(it) }
            storePassword = (keystoreProperties["storePassword"] as? String) ?: ""
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            val hasReleaseKeystore =
                !((keystoreProperties["keyAlias"] as? String).isNullOrBlank()) &&
                    !((keystoreProperties["keyPassword"] as? String).isNullOrBlank()) &&
                    !((keystoreProperties["storePassword"] as? String).isNullOrBlank()) &&
                    (keystoreProperties["storeFile"] as? String)?.isNotBlank() == true &&
                    (keystoreProperties["storeFile"] as? String)?.let { file(it).exists() } == true

            // Never ship a release build signed with the debug key. Local/CI
            // release builds must provide an explicit release keystore.
            check(hasReleaseKeystore) {
                "Release signing is not configured. Create android/key.properties " +
                    "with keyAlias, keyPassword, storeFile, and storePassword."
            }
            signingConfig = signingConfigs.getByName("release")
        }
    }
    buildToolsVersion = "36.1.0"
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
