pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

rootProject.name = "SantParentApp"

include(":app")

// Inclusion of Flutter module
val flutterProjectRoot = rootDir.resolve("bank_query_flutter_module")
val includeFlutterScript = flutterProjectRoot.resolve(".android/include_flutter.groovy")

if (includeFlutterScript.exists()) {
    apply(from = includeFlutterScript)
} else {
    // If you haven't run 'flutter pub get' in the module, 
    // we still need to include the project if it was previously there,
    // but the script is the preferred way.
    logger.warn("Flutter module script not found. Run 'flutter pub get' in bank_query_flutter_module")
}
