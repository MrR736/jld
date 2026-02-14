JLD
===

Java Libraries Downloader module for CMake.

JLD provides lightweight Maven-style dependency management for Java
projects built with CMake. It enables downloading JAR files from Maven
repositories and creating imported targets that integrate with CMake’s
Java toolchain.

This module is distributed under the BSD 3-Clause License.

Overview
--------

JLD provides the following features:

- Download JAR files from Maven repositories
- Optional SHA256 verification of downloaded artifacts
- Creation of ``INTERFACE IMPORTED`` targets
- Automatic construction of platform-correct Java classpaths
- Convenience helpers for running Java applications
- Support for declaring multiple dependencies in a single call

The module is intentionally lightweight and does not perform
transitive dependency resolution.

Commands
--------

The following commands are provided:

.. toctree::
   :maxdepth: 1

   add_java_library
   add_java_libraries
   java_link_libraries
   java_get_classpath
   java_run

Basic Usage
-----------

.. code-block:: cmake

   find_package(JLD REQUIRED)

   add_java_libraries(
       LIBRARIES
            org.slf4j:slf4j-api:2.0.9:3a1f8e9f5c8d4b2e7c6a1b9d0e2f4a6c8d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5
            com.google.guava:guava:33.0.0-jre:9b8a7c6d5e4f3210abcdef1234567890abcdef1234567890abcdef1234567890
   )

   add_jar(my_app
       SOURCES src/Main.java
   )

   java_link_libraries(my_app
       jld::slf4j-api
       jld::guava
   )

   java_run(run_app
       MAIN_CLASS com.example.Main
       LIBRARIES
           jld::slf4j-api
           jld::guava
   )

Design Goals
------------

JLD is designed to be:

- Minimal and dependency-free
- Fully integrated with native CMake workflows
- Reproducible through optional hash verification
- Independent of external build tools such as Maven or Gradle

Target Naming
-------------

Each downloaded artifact defines an imported target with the form:

::

   jld::<artifact>

These targets:

- Are ``INTERFACE IMPORTED`` libraries
- Store the downloaded JAR path in the ``JLD_JAR`` property
- Can be passed to ``java_link_libraries()``
- Can be used with ``java_get_classpath()`` and ``java_run()``

Platform Behavior
-----------------

Classpath separators are selected automatically:

- ``;`` on Windows
- ``:`` on UNIX-like systems

Limitations
-----------

JLD does not:

- Resolve transitive dependencies
- Parse POM files
- Detect version conflicts
- Manage dependency graphs

For advanced dependency management, a dedicated build system such as
Maven or Gradle may be more appropriate.

See Also
--------

CMake’s built-in Java support:

- ``add_jar()``
- ``find_package(Java)``
- ``UseJava`` module
