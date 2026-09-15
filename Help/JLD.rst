JLD
===

Java Libraries Downloader module for CMake.

JLD provides lightweight Maven-style dependency management for Java
projects built with CMake. It downloads JAR files from Maven repositories
or direct URLs, creates imported CMake targets, and provides helpers for
constructing Java classpaths and running Java applications.

This module is distributed under the BSD 3-Clause License.

Overview
--------

JLD provides the following features:

- Download JAR files from Maven repositories or direct URLs
- Optional SHA256, SHA1, and MD5 verification of downloaded artifacts
- Creation of ``INTERFACE IMPORTED`` targets
- Automatic construction of platform-correct Java classpaths
- Convenience helpers for running Java applications
- Support for declaring multiple Maven dependencies in a single call
- Build-local caching of downloaded Java libraries
- Integration with CMake's Java support and ``UseJava`` module

JLD is intentionally lightweight and does not perform transitive
dependency resolution.

Commands
--------

The following commands are provided:

.. toctree::
   :maxdepth: 1

   add_java_library
   add_java_libraries
   java_get_classpath
   java_run

Basic Usage
-----------

The JLD module can be used together with CMake's Java support:

.. code-block:: cmake

   find_package(JLD REQUIRED)

   add_java_libraries(
       HASH_ALGORITHM SHA256
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9:3a1f8e9f5c8d4b2e7c6a1b9d0e2f4a6c8d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5
           com.google.guava:guava:33.0.0-jre:9b8a7c6d5e4f3210abcdef1234567890abcdef1234567890abcdef1234567890
   )

   add_jar(my_app
       SOURCES
           src/Main.java
       INCLUDE_JARS
           jld::slf4j-api
           jld::guava
   )

   java_run(run_app
       MAIN_CLASS com.example.Main
       LIBRARIES
           jld::slf4j-api
           jld::guava
   )

Direct Library Usage
~~~~~~~~~~~~~~~~~~~~

A single library can be added with ``add_java_library()``:

.. code-block:: cmake

   add_java_library(guava
       GROUP com.google.guava
       ARTIFACT guava
       VERSION 33.0.0-jre
   )

   add_jar(my_app
       SOURCES
           Main.java
       INCLUDE_JARS
           jld::guava
   )

Libraries can also be downloaded from a direct URL:

.. code-block:: cmake

   add_java_library(my_lib
       URL https://example.com/libs/my-lib-1.0.0.jar
       SHA256 0123456789abcdef...
   )

Multiple Libraries
~~~~~~~~~~~~~~~~~~

Several Maven dependencies can be declared with
``add_java_libraries()``:

.. code-block:: cmake

   add_java_libraries(
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9
           com.google.guava:guava:33.0.0-jre
           org.apache.commons:commons-lang3:3.14.0
   )

The resulting JLD targets can then be passed directly to
``add_jar()`` through ``INCLUDE_JARS``:

.. code-block:: cmake

   add_jar(my_app
       SOURCES
           Main.java
       INCLUDE_JARS
           jld::slf4j-api
           jld::guava
           jld::commons-lang3
   )

Checksum Verification
~~~~~~~~~~~~~~~~~~~~~

Checksum verification is optional.

SHA256 is the default algorithm:

.. code-block:: cmake

   add_java_libraries(
       LIBRARIES
           org.example:example:1.0.0:0123456789abcdef...
   )

The algorithm can be selected explicitly:

.. code-block:: cmake

   add_java_libraries(
       HASH_ALGORITHM SHA256
       LIBRARIES
           org.example:example:1.0.0:0123456789abcdef...
   )

The supported algorithms are:

- ``SHA256``
- ``SHA1``
- ``MD5``

For reproducible builds, SHA256 verification is recommended.

Repository Selection
~~~~~~~~~~~~~~~~~~~~

Maven Central is used by default:

.. code-block:: text

   https://repo1.maven.org/maven2

A different Maven repository can be specified:

.. code-block:: cmake

   add_java_libraries(
       REPOSITORY https://repo.example.com/maven
       LIBRARIES
           com.example:my-library:1.2.3
   )

Individual libraries can also specify their repository when using
``add_java_library()``.

Design Goals
------------

JLD is designed to be:

- **Minimal** -- provides only the dependency functionality required by
  CMake-based Java projects.
- **Dependency-free** -- does not require Maven, Gradle, or another
  external dependency-management system.
- **CMake-native** -- integrates Java libraries into the CMake target
  model.
- **Reproducible** -- supports cryptographic hash verification of
  downloaded artifacts.
- **Portable** -- automatically handles platform-specific Java
  classpath separators.
- **Predictable** -- does not implicitly resolve or download transitive
  dependencies.

Target Naming
-------------

Each downloaded artifact creates an imported target with the form:

.. code-block:: text

   jld::<artifact>

For example:

.. code-block:: text

   jld::guava
   jld::slf4j-api

These targets:

- Are ``INTERFACE IMPORTED`` libraries.
- Store the downloaded JAR path in the ``JLD_JAR`` property.
- Store the downloaded JAR path in the ``JAR_FILE`` property.
- Can be passed to ``add_jar()`` through ``INCLUDE_JARS``.
- Can be used with ``java_get_classpath()``.
- Can be used with ``java_run()``.

The target represents the JAR as a Java dependency rather than as a
native C or C++ library.

Download and Cache Behavior
---------------------------

JLD stores downloaded libraries inside the CMake build directory.

The cache directory has the following general structure:

.. code-block:: text

   <build>/
   └── CMakeFiles/
       ├── JLD.cache
       └── JLD-<cache-id>.dir/
           ├── <library-1>.dir/
           │   └── <library-1>.jar
           ├── <library-2>.dir/
           │   └── <library-2>.jar
           └── ...

The cache identifier is generated automatically and stored in:

.. code-block:: text

   <build>/CMakeFiles/JLD.cache

If the requested JAR already exists, JLD reuses the existing file
according to the configured checksum behavior.

When a checksum is provided, the downloaded artifact can be verified
against the expected hash.

Classpath Handling
------------------

JLD provides ``java_get_classpath()`` for obtaining a classpath from
JLD library targets.

The classpath separator is selected automatically for the host platform.

On Windows:

.. code-block:: text

   ;

On UNIX-like systems:

.. code-block:: text

   :

For example, a Windows classpath may look like:

.. code-block:: text

   library-a.jar;library-b.jar

while a UNIX-like system uses:

.. code-block:: text

   library-a.jar:library-b.jar

Using JLD targets with ``add_jar()``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Java compilation dependencies should normally be passed directly to
CMake's ``add_jar()`` command using ``INCLUDE_JARS``:

.. code-block:: cmake

   add_jar(my_app
       SOURCES
           Main.java
       INCLUDE_JARS
           jld::guava
           jld::slf4j-api
   )

This avoids the need for an additional JLD linking command.

Running Java Applications
-------------------------

The ``java_run()`` command creates a CMake target that executes a Java
application using the specified JLD libraries.

Example:

.. code-block:: cmake

   java_run(run_app
       MAIN_CLASS com.example.Main
       LIBRARIES
           jld::slf4j-api
           jld::guava
   )

Additional arguments can be passed with ``ARGS``:

.. code-block:: cmake

   java_run(run_app
       MAIN_CLASS com.example.Main
       LIBRARIES
           jld::guava
       ARGS
           --input
           input.txt
           --verbose
   )

The generated target can then be built with:

.. code-block:: console

   cmake --build build --target run_app

Limitations
-----------

JLD intentionally does not provide full Maven or Gradle dependency
management.

JLD does not:

- Resolve transitive dependencies.
- Parse Maven POM files.
- Automatically download dependency trees.
- Detect dependency version conflicts.
- Resolve multiple versions of the same artifact.
- Select compatible dependency versions.
- Provide Maven scopes such as ``compile``, ``runtime``, or ``test``.
- Manage Java modules or module descriptors automatically.

For advanced dependency management, a dedicated build system such as
Maven or Gradle may be more appropriate.

Security and Reproducibility
----------------------------

Downloads without a checksum are not cryptographically verified by JLD.

For reproducible builds, provide a checksum for each downloaded artifact:

.. code-block:: cmake

   add_java_library(guava
       GROUP com.google.guava
       ARTIFACT guava
       VERSION 33.0.0-jre
       SHA256 0123456789abcdef...
   )

When using ``add_java_libraries()``, the checksum algorithm can be
selected with ``HASH_ALGORITHM``:

.. code-block:: cmake

   add_java_libraries(
       HASH_ALGORITHM SHA256
       LIBRARIES
           com.google.guava:guava:33.0.0-jre:0123456789abcdef...
   )

SHA256 is recommended for new projects. SHA1 and MD5 are provided
primarily for compatibility with existing repositories and projects.

CMake Integration
-----------------

JLD is designed to complement CMake's built-in Java support rather than
replace it.

A typical project uses:

.. code-block:: cmake

   find_package(Java REQUIRED)
   include(UseJava)

   find_package(JLD REQUIRED)

   add_java_libraries(
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9
   )

   add_jar(my_app
       SOURCES
           src/Main.java
       INCLUDE_JARS
           jld::slf4j-api
   )

JLD provides dependency management and classpath utilities, while
CMake's ``UseJava`` module provides Java compilation support.

See Also
--------

JLD commands:

- ``add_java_library()``
- ``add_java_libraries()``
- ``java_get_classpath()``
- ``java_run()``

CMake Java support:

- ``find_package(Java)``
- ``add_jar()``
- ``UseJava``

License
-------

JLD is distributed under the BSD 3-Clause License.
