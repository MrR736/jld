# JLD — Java Libraries Downloader for CMake

JLD is a small, lightweight CMake module that allows you to **download and link Java libraries** (`.jar` files) directly in your CMake projects.

It supports both direct URLs and Maven-style coordinates (`GROUP + ARTIFACT + VERSION`).

---

## Features

* Download Java libraries from **Maven Central** or any custom repository.
* Supports **SHA256, SHA1, and MD5** verification.
* Automatically creates **CMake imported targets** (`jld::<name>`).
* Cross-platform support for Java classpaths (`:` on Unix, `;` on Windows).
* Retrieve Java classpaths with `java_get_classpath()`.
* Run Java applications with `java_run()`.
* Supports Maven-style library coordinates.
* Optional checksum sidecar files (`.sha256`, `.sha1`, `.md5`).
* Configurable download directory.
* Includes optional documentation and can be packaged for installation.

---

## Requirements

* CMake >= 3.20
* Java JDK
* Internet access when downloading libraries

---

## Installation

Copy the module to your project:

```bash
cp cmake/JLD.cmake /path/to/your/project/cmake/
```

Then add the module directory to your CMake module path:

```cmake
list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
)

include(JLD)
```

You can also install JLD system-wide and use the installed CMake package:

```cmake
find_package(JLD REQUIRED)
```

---

## Download Directory

By default, JLD stores downloaded libraries in:

```text
${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/JLD-XXXXXXXX.dir
```

where `XXXXXXXX` is a randomly generated 8-character identifier.
The identifier is stored in `JLD.cache` so the same directory is reused across subsequent CMake configurations.

For example:

```text
build/
└── CMakeFiles/
    ├── JLD.cache
    └── JLD-aB7xK92q.dir/
        └── ...
```

The directory can be overridden when configuring the project:

```bash
cmake -S . -B build \
    -DJLD_FILES_DIRECTORY=/path/to/jld
```

Or from CMake:

```cmake
set(
    JLD_FILES_DIRECTORY
    "${CMAKE_CURRENT_BINARY_DIR}/jld"
    CACHE PATH "Directory containing downloaded Java libraries"
)
```

---

## Download a Library from a URL

A library can be downloaded directly using `URL`:

```cmake
add_java_library(aislib
    URL "https://repo1.maven.org/maven2/aislib/aislib/0.5.2/aislib-0.5.2.jar"
    SHA256 "..."
)
```

This creates the imported target:

```text
jld::aislib
```

The downloaded JAR can be accessed through the target property:

```cmake
get_target_property(
    AISLIB_JAR
    jld::aislib
    JLD_JAR
)

message(STATUS "AISLIB JAR: ${AISLIB_JAR}")
```

---

## Maven Coordinates

JLD supports Maven-style coordinates:

```cmake
add_java_library(aislib
    GROUP aislib
    ARTIFACT aislib
    VERSION 0.5.2
    SHA256 "..."
)
```

The equivalent Maven URL is:

```text
https://repo1.maven.org/maven2/aislib/aislib/0.5.2/aislib-0.5.2.jar
```

The default repository is Maven Central.

---

## Custom Maven Repository

Use `REPOSITORY` to specify another Maven repository:

```cmake
add_java_library(example
    GROUP com.example
    ARTIFACT example
    VERSION 1.0.0
    REPOSITORY "https://repo.example.com/maven2"
    SHA256 "..."
)
```

---

## Multiple Libraries

Multiple Maven libraries can be downloaded with `add_java_libraries()`:

```cmake
add_java_libraries(
    HASH_ALGORITHM SHA256

    LIBRARIES
        "org.junit.jupiter:junit-jupiter-api:5.10.0:..."
        "org.slf4j:slf4j-api:2.0.9:..."
)
```

The coordinate format is:

```text
GROUP:ARTIFACT:VERSION[:HASH]
```

For example:

```text
org.slf4j:slf4j-api:2.0.9:<sha256>
```

The hash algorithm is specified separately:

```cmake
add_java_libraries(
    HASH_ALGORITHM SHA256

    LIBRARIES
        "org.slf4j:slf4j-api:2.0.9:<sha256>"
)
```

Supported algorithms:

* `SHA256`
* `SHA1`
* `MD5`

If `HASH_ALGORITHM` is omitted, `SHA256` is used.

---

## Link Libraries to a Java Target

JLD provides `INCLUDE_JARS` for adding JLD libraries to a Java target:

```cmake
add_java_library(aislib
    GROUP aislib
    ARTIFACT aislib
    VERSION 0.5.2
    SHA256 "..."
)

add_java_executable(my_app
    SOURCES
        src/Main.java

    INCLUDE_JARS
        jld::aislib
)
```

Multiple JARs can be specified:

```cmake
add_java_executable(my_app
    SOURCES
        src/Main.java

    INCLUDE_JARS
        jld::aislib
        jld::junit
        jld::slf4j
)
```

JLD generates the appropriate platform-specific Java classpath.

On Linux/macOS:

```text
:
```

On Windows:

```text
;
```

---

## Get a Java Classpath

Use `java_get_classpath()` when the classpath is needed directly:

```cmake
java_get_classpath(
    CLASSPATH
    jld::aislib
)

message(STATUS "Classpath: ${CLASSPATH}")
```

For multiple libraries:

```cmake
java_get_classpath(
    CLASSPATH
    jld::aislib
    jld::junit
    jld::slf4j
)
```

---

## Run a Java Application

JLD provides `java_run()` for creating a CMake target that runs a Java main class:

```cmake
java_run(run_app
    MAIN_CLASS com.example.Main

    LIBRARIES
        jld::aislib

    ARGS
        "hello"
        "world"
)
```

Then run:

```bash
cmake --build build --target run_app
```

---

## Target Properties

Each JLD library target provides the `JLD_JAR` property:

```cmake
get_target_property(
    JAR
    jld::aislib
    JLD_JAR
)

message(STATUS "JAR: ${JAR}")
```

The same path is also available through `JAR_FILE`:

```cmake
get_target_property(
    JAR
    jld::aislib
    JAR_FILE
)
```

---

## Checksum Verification

JLD can verify downloaded JAR files during the download.

### SHA256

```cmake
add_java_library(example
    URL "https://example.com/example.jar"
    SHA256 "0123456789abcdef..."
)
```

### SHA1

```cmake
add_java_library(example
    URL "https://example.com/example.jar"
    SHA1 "0123456789abcdef..."
)
```

### MD5

```cmake
add_java_library(example
    URL "https://example.com/example.jar"
    MD5 "0123456789abcdef..."
)
```

When a hash is provided, CMake verifies the downloaded file using `file(DOWNLOAD)`.

---

## Complete Example

Project structure:

```text
my-project/
├── CMakeLists.txt
├── cmake/
│   └── JLD.cmake
└── src/
    └── Main.java
```

`CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.20)

project(MyJavaProject)

find_package(Java REQUIRED)

list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
)

include(JLD)

add_java_library(aislib
    GROUP aislib
    ARTIFACT aislib
    VERSION 0.5.2
    SHA256 "..."
)

add_java_executable(my_app
    SOURCES
        src/Main.java

    INCLUDE_JARS
        jld::aislib
)
```

Configure and build:

```bash
cmake -S . -B build
cmake --build build
```

---

## Testing

JLD includes CMake-based tests for:

* URL validation
* JAR downloading
* SHA256/SHA1/MD5 verification
* Imported target creation
* Target properties
* Maven coordinates
* Multiple library downloads
* Java classpath generation
* Java target linking

Configure the test project:

```bash
cmake -S test -B build-test
```

Build:

```bash
cmake --build build-test
```

Run tests:

```bash
ctest --test-dir build-test --output-on-failure
```

---

## License

JLD is distributed under the **OSI-approved BSD 3-Clause License**.
