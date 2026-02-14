add_java_libraries
==================

Add multiple Java libraries from Maven repositories in a single call.

This is a convenience wrapper around ``add_java_library()`` that allows
declaring several dependencies using a compact ``group:artifact:version`` syntax.

Synopsis
--------

.. code-block:: cmake

   add_java_libraries(
       [REPOSITORY <url>]
       LIBRARIES
           <group:artifact:version[:sha256]>
           ...
   )

Description
-----------

``add_java_libraries()`` parses each entry in ``LIBRARIES`` and internally
calls ``add_java_library()`` for each dependency.

Each library must be specified in the following format:

::

   group:artifact:version[:sha256]

Components:

- ``group`` — Maven group ID (e.g. ``org.slf4j``)
- ``artifact`` — Artifact ID (e.g. ``slf4j-api``)
- ``version`` — Artifact version (e.g. ``2.0.9``)
- ``sha256`` *(optional)* — SHA256 checksum for download verification

If ``REPOSITORY`` is not provided, the default Maven Central repository is used:

::

   https://repo1.maven.org/maven2

Behavior
--------

For each library entry:

1. The string is split on ``:``.
2. The components are validated.
3. ``add_java_library()`` is invoked with the parsed arguments.
4. An imported target is created:

   ::

      jld::<artifact>

Examples
--------

Basic usage:

.. code-block:: cmake

   add_java_libraries(
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9
           com.google.guava:guava:33.0.0-jre
   )

With explicit repository:

.. code-block:: cmake

   add_java_libraries(
       REPOSITORY https://repo.maven.apache.org/maven2
       LIBRARIES
           org.apache.commons:commons-lang3:3.14.0
   )

With SHA256 verification:

.. code-block:: cmake

   add_java_libraries(
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9:0123456789abcdef...
   )

Targets Created
---------------

For each entry:

::

   jld::<artifact>

These targets:

- Are ``INTERFACE IMPORTED`` libraries
- Contain a ``JLD_JAR`` property pointing to the downloaded JAR file
- Can be used with ``java_link_libraries()``

Errors
------

A fatal error occurs if:

- A library string has fewer than three components
- Download fails
- SHA256 verification fails (if provided)

See Also
--------

- ``add_java_library()``
- ``java_link_libraries()``
- ``java_get_classpath()``

``add_java_libraries()`` is intended as a lightweight alternative
to full Maven or Gradle integration within CMake-based Java builds.
