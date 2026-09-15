add_java_libraries
==================

Add multiple Java libraries from Maven repositories in a single call.

This is a convenience wrapper around ``add_java_library()`` that allows
declaring several Maven dependencies using a compact
``group:artifact:version[:hash]`` syntax.

Synopsis
--------

.. code-block:: cmake

   add_java_libraries(
       [HASH_ALGORITHM <algorithm>]
       [REPOSITORY <url>]
       LIBRARIES
           <group:artifact:version[:hash]>
           ...
   )

Description
-----------

``add_java_libraries()`` parses each entry in ``LIBRARIES`` and internally
calls ``add_java_library()`` for each dependency.

Each library must be specified in the following format:

::

   group:artifact:version[:hash]

Components:

``group``
    Maven group ID.

    Example:

    ::

       org.slf4j

``artifact``
    Maven artifact ID.

    Example:

    ::

       slf4j-api

``version``
    Maven artifact version.

    Example:

    ::

       2.0.9

``hash``
    Optional checksum used to verify the downloaded JAR.

    The hash algorithm is selected using ``HASH_ALGORITHM``. Supported
    algorithms are ``SHA256``, ``SHA1``, and ``MD5``.

``HASH_ALGORITHM <algorithm>``
    Selects the checksum algorithm used for optional hashes.

    Supported values are:

    - ``SHA256``
    - ``SHA1``
    - ``MD5``

    If omitted, ``SHA256`` is used.

``REPOSITORY <url>``
    Base Maven repository URL.

    If omitted, Maven Central is used:

    ::

       https://repo1.maven.org/maven2

    The repository URL is passed to ``add_java_library()`` for every
    library in the list.

Behavior
--------

For each library entry:

1. The entry is split on ``:``.
2. The number of components is validated.
3. The group, artifact, version, and optional hash are extracted.
4. The selected hash algorithm is applied to the optional hash.
5. ``add_java_library()`` is invoked with the parsed arguments.
6. An imported ``INTERFACE`` target is created.

For example:

.. code-block:: cmake

   add_java_libraries(
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9
           com.google.guava:guava:33.0.0-jre
   )

is equivalent to:

.. code-block:: cmake

   add_java_library(slf4j-api
       GROUP org.slf4j
       ARTIFACT slf4j-api
       VERSION 2.0.9
   )

   add_java_library(guava
       GROUP com.google.guava
       ARTIFACT guava
       VERSION 33.0.0-jre
   )

The generated targets are:

.. code-block:: text

   jld::slf4j-api
   jld::guava

Examples
--------

Basic usage
~~~~~~~~~~~

.. code-block:: cmake

   add_java_libraries(
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9
           com.google.guava:guava:33.0.0-jre
   )

Specify a custom repository
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: cmake

   add_java_libraries(
       REPOSITORY https://repo.maven.apache.org/maven2
       LIBRARIES
           org.apache.commons:commons-lang3:3.14.0
   )

SHA256 verification
~~~~~~~~~~~~~~~~~~~

By default, an optional hash is interpreted as SHA256:

.. code-block:: cmake

   add_java_libraries(
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9:0123456789abcdef...
   )

The equivalent explicit form is:

.. code-block:: cmake

   add_java_libraries(
       HASH_ALGORITHM SHA256
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9:0123456789abcdef...
   )

SHA1 verification
~~~~~~~~~~~~~~~~~

.. code-block:: cmake

   add_java_libraries(
       HASH_ALGORITHM SHA1
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9:0123456789abcdef0123456789abcdef01234567
   )

MD5 verification
~~~~~~~~~~~~~~~~

.. code-block:: cmake

   add_java_libraries(
       HASH_ALGORITHM MD5
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9:0123456789abcdef0123456789abcdef
   )

Targets Created
---------------

For each library, an imported ``INTERFACE`` target is created:

.. code-block:: text

   jld::<artifact>

For example:

.. code-block:: text

   jld::slf4j-api
   jld::guava

Each target contains a ``JLD_JAR`` property pointing to the downloaded
JAR file.

The targets can be used with:

- ``java_get_classpath()``
- ``java_run()``
- Other JLD commands that consume Java library targets

Hash Verification
-----------------

When ``HASH_ALGORITHM`` is specified, the optional fourth component of
each library entry is passed to ``add_java_library()`` using the selected
algorithm.

For example:

.. code-block:: cmake

   add_java_libraries(
       HASH_ALGORITHM SHA256
       LIBRARIES
           org.example:example:1.0.0:0123456789abcdef...
   )

is equivalent to:

.. code-block:: cmake

   add_java_library(example
       GROUP org.example
       ARTIFACT example
       VERSION 1.0.0
       SHA256 0123456789abcdef...
   )

If no hash is supplied, the library is downloaded without checksum
verification.

Repository Handling
-------------------

A single ``REPOSITORY`` value applies to all libraries in the call.

For example:

.. code-block:: cmake

   add_java_libraries(
       REPOSITORY https://repo.example.com/maven
       LIBRARIES
           com.example:library-a:1.0.0
           com.example:library-b:2.0.0
   )

This is equivalent to specifying the same repository for each
``add_java_library()`` invocation.

Errors
------

A fatal error occurs if:

- A library entry contains fewer than three components.
- A library entry contains more than four components.
- ``HASH_ALGORITHM`` is not ``SHA256``, ``SHA1``, or ``MD5``.
- The underlying ``add_java_library()`` call fails.
- The JAR download fails.
- The supplied checksum does not match the downloaded JAR.

Notes
-----

- ``LIBRARIES`` entries must use ``:`` as the component separator.
- Each entry must contain at least ``group``, ``artifact``, and ``version``.
- The optional fourth component is interpreted according to
  ``HASH_ALGORITHM``.
- The default checksum algorithm is ``SHA256``.
- A single ``REPOSITORY`` applies to all libraries in the call.
- Each artifact creates a target named ``jld::<artifact>``.
- Libraries with the same artifact name may therefore result in target
  name conflicts.
- ``add_java_libraries()`` does not resolve transitive dependencies.
- ``add_java_libraries()`` is intended as a lightweight alternative to
  full Maven or Gradle dependency management in CMake-based Java builds.

See Also
--------

- ``add_java_library()``
- ``java_get_classpath()``
- ``java_run()``
