# JLD — Java Libraries Downloader for CMake

JLD is a small, lightweight CMake module that allows you to **download and link Java libraries** (`.jar` files) directly inside CMake projects.

It supports both:

* Direct download URLs
* Maven-style coordinates (`GROUP + ARTIFACT + VERSION`)

JLD is designed to be simple, portable, and dependency-free — no Maven or Gradle required.

---

## Features

* Download Java libraries from **Maven Central** or custom repositories
* Optional **SHA256 verification** for secure downloads
* Automatically creates **imported CMake targets** (`jld::<name>`)
* Cross-platform **classpath handling** (`:` on Unix, `;` on Windows)
* Simple integration with CMake Java targets
* Lightweight and self-contained (pure CMake)

---

## Requirements

* **CMake ≥ 3.20**
* **Java JDK**
* Internet connection (for downloading dependencies)

---

## Installation

### Option 1 — Copy into your project

Copy the module into your project:

```bash
mkdir -p cmake
cp JLD.cmake cmake/
```

Then include it in your `CMakeLists.txt`:

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(JLD)
```

---

### Option 2 — System-wide installation

Install it into your CMake module path:

```bash
cp JLD.cmake /usr/local/share/cmake/Modules/
```

Then simply:

```cmake
include(JLD)
```

---

# Usage

---

## 1. Download a Library (Maven Coordinates)

```cmake
add_java_library(guava
    GROUP com.google.guava
    ARTIFACT guava
    VERSION 33.0.0-jre
    SHA256 <expected_hash_here>
)
```

This creates an imported target:

```
jld::guava
```

---

## 2. Download via Direct URL

```cmake
add_java_library(my_lib
    URL https://example.com/my-lib.jar
    SHA256 <expected_hash_here>
)
```

---

## 3. Add Multiple Libraries

```cmake
add_java_libraries(
    LIBRARIES
        "com.google.guava:guava:33.0.0-jre"
        "org.apache.commons:commons-lang3:3.14.0"
)
```

Format:

```
group:artifact:version[:sha256]
```

---

## 4. Link Libraries to a Java Target

```cmake
add_jar(MyApp
    SOURCES src/Main.java
)

java_link_libraries(MyApp
    jld::guava
)
```

JLD automatically sets the correct `-classpath`.

---

## 5. Get Classpath Manually

```cmake
java_get_classpath(MY_CLASSPATH
    jld::guava
)

message(STATUS "Classpath: ${MY_CLASSPATH}")
```

---

## 6. Run a Java Program

```cmake
java_run(run_app
    MAIN_CLASS com.example.Main
    LIBRARIES jld::guava
    ARGS arg1 arg2
)
```

Then execute:

```bash
cmake -S . -B build
cmake --build build --target run_app
```

---

# Security

If `SHA256` is provided, downloads are verified automatically.

If omitted, a warning is emitted and the file is downloaded without verification.

For production environments, **always provide SHA256** to ensure reproducible and secure builds.

---

# Limitations

* No transitive dependency resolution (unlike Maven or Gradle)
* No automatic POM parsing
* Downloads occur during the CMake configure step

JLD is intended to be a **minimal, lightweight alternative**, not a full Java build system replacement.

---

# Design Philosophy

JLD focuses on:

* Simplicity
* Portability
* Zero external tooling
* Clean CMake integration

If you require full dependency graph management, version conflict resolution, or advanced packaging, consider using Maven or Gradle.

---

# License

BSD 3-Clause License
See `LICENSE` for details.

---

# Contributing

Contributions, bug reports, and suggestions are welcome.

Please open an issue or submit a pull request.
