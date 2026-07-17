val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }
}

subprojects {
    val configureNamespace = {
        if (project.hasProperty("android")) {
            val android = project.property("android")
            try {
                val getNamespace = android?.javaClass?.getMethod("getNamespace")
                val namespace = getNamespace?.invoke(android)
                if (namespace == null) {
                    val setNamespace = android?.javaClass?.getMethod("setNamespace", String::class.java)
                    setNamespace?.invoke(android, "dev.isar.${project.name.replace("-", "_")}")
                }
            } catch (e: Exception) {
                // Ignore exception
            }

            try {
                val compileSdkVersionMethod = android?.javaClass?.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                compileSdkVersionMethod?.invoke(android, 36)
            } catch (e1: Exception) {
                try {
                    val setCompileSdk = android?.javaClass?.getMethod("setCompileSdk", java.lang.Integer::class.java)
                    setCompileSdk?.invoke(android, 36)
                } catch (e2: Exception) {
                    try {
                        val setCompileSdkInt = android?.javaClass?.getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                        setCompileSdkInt?.invoke(android, 36)
                    } catch (e3: Exception) {
                        // Ignore
                    }
                }
            }
        }
    }

    if (project.state.executed) {
        configureNamespace()
    } else {
        project.afterEvaluate {
            configureNamespace()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

