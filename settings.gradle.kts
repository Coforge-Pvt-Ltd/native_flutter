pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        // Replace the versions below with the version used in your root build.gradle
        id("com.android.application") version "8.2.0" apply false
        id("com.android.library") version "8.2.0" apply false
        id("org.jetbrains.kotlin.android") version "1.9.0" apply false
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "SantParentApp"

include(":app")
include(":flutter")

apply(from = file("bank_query_flutter_module/.android/include_flutter.groovy"))
