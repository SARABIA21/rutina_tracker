plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter debe ir después de los anteriores
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.rutina_tracker_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Forzar compatibilidad con Java 1.8
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // Habilitar desugaring de librerías del core
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Kotlin también apuntando a Java 1.8
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        applicationId = "com.example.rutina_tracker_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Añadimos la dependencia para desugar las librerías de Java 8+
dependencies {
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
