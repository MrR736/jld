add_java_library
================

Add a Java library to the project by downloading a `.jar` file.
Supports direct URLs or Maven-style coordinates.

Usage
-----

.. code-block:: cmake

    add_java_library(<name>
        URL <url> [OUTPUT_NAME <name>] [SHA256 <hash>]
    )

    add_java_library(<name>
        GROUP <group> ARTIFACT <artifact> VERSION <version>
        [REPOSITORY <repo_url>] [OUTPUT_NAME <name>] [SHA256 <hash>]
    )

Parameters
----------

- **`<name>`**
  Name of the library target. Creates an imported target `jld::<name>`.

- **`URL <url>`** *(optional)*
  Direct URL to the `.jar` file. Either `URL` or `GROUP + ARTIFACT + VERSION` must be provided.

- **`GROUP <group>`** *(optional)*
  Maven group ID, e.g., `com.google.guava`.

- **`ARTIFACT <artifact>`** *(optional)*
  Maven artifact ID, e.g., `guava`.

- **`VERSION <version>`** *(optional)*
  Maven version, e.g., `32.1.2-jre`.

- **`REPOSITORY <repo_url>`** *(optional)*
  Base repository URL (defaults to Maven Central: `https://repo1.maven.org/maven2`).

- **`OUTPUT_NAME <name>`** *(optional)*
  Custom output filename without version. Defaults to artifact name or URL filename.

- **`SHA256 <hash>`** *(optional)*
  SHA256 hash of the jar for verification. If omitted, download is unverified.

Behavior
--------

- Downloads the jar to a build-specific directory:

  ``<build>/CMakeFiles/JLD-<SYSTEM>-<ARCH>/<name>.dir/``

- Creates an imported INTERFACE target: `jld::<name>`
- Re-downloads if the file is missing or hash mismatch occurs.

Example
-------

.. code-block:: cmake

    add_java_library(guava
        GROUP com.google.guava
        ARTIFACT guava
        VERSION 32.1.2-jre
        SHA256 1c3a0f0d6b44e1...
    )

    add_java_library(my-lib
        URL https://myserver.com/libs/my-lib-1.0.0.jar
    )
