add_java_library
================

Add a Java library to the project by downloading a ``.jar`` file.

The library can be specified using either a direct URL or Maven-style
coordinates. The command downloads the JAR during CMake configuration and
creates an imported target that can be used by other JLD commands.

Usage
-----

Direct URL
~~~~~~~~~~

.. code-block:: cmake

    add_java_library(<name>
        URL <url>
        [OUTPUT_NAME <name>]
        [SHA256 <hash> | SHA1 <hash> | MD5 <hash>]
    )

Maven coordinates
~~~~~~~~~~~~~~~~~

.. code-block:: cmake

    add_java_library(<name>
        GROUP <group>
        ARTIFACT <artifact>
        VERSION <version>
        [REPOSITORY <repo_url>]
        [OUTPUT_NAME <name>]
        [SHA256 <hash> | SHA1 <hash> | MD5 <hash>]
    )

Parameters
----------

``<name>``
    Name of the Java library target.

    The command creates an imported interface target:

    .. code-block:: text

        jld::<name>

``URL <url>``
    Direct URL to the ``.jar`` file.

    Either ``URL`` or ``GROUP``, ``ARTIFACT``, and ``VERSION`` must be
    specified.

``GROUP <group>``
    Maven group ID.

    Example:

    .. code-block:: text

        com.google.guava

``ARTIFACT <artifact>``
    Maven artifact ID.

    Example:

    .. code-block:: text

        guava

``VERSION <version>``
    Maven artifact version.

    Example:

    .. code-block:: text

        32.1.2-jre

``REPOSITORY <repo_url>``
    Base Maven repository URL.

    Defaults to:

    .. code-block:: text

        https://repo1.maven.org/maven2

    The repository URL is used together with ``GROUP``, ``ARTIFACT``, and
    ``VERSION`` to construct the JAR download URL.

``OUTPUT_NAME <name>``
    Custom output filename for the downloaded JAR.

    If omitted, the output filename is determined from the JAR filename in
    the specified URL.

``SHA256 <hash>``
    Expected SHA256 hash of the downloaded JAR.

    When specified, the downloaded file is verified against this hash.
    If the hash does not match, the existing file is considered invalid
    and is downloaded again.

``SHA1 <hash>``
    Expected SHA1 hash of the downloaded JAR.

    When specified, the downloaded file is verified against this hash.
    If the hash does not match, the existing file is considered invalid
    and is downloaded again.

``MD5 <hash>``
    Expected MD5 hash of the downloaded JAR.

    When specified, the downloaded file is verified against this hash.
    If the hash does not match, the existing file is considered invalid
    and is downloaded again.

Behavior
--------

The JAR is downloaded to a build-specific directory:

.. code-block:: text

    <build>/CMakeFiles/JLD-<CACHE-ID>.dir/<name>.dir/

For example:

.. code-block:: text

    build/CMakeFiles/JLD-XXXXXXXX.dir/guava.dir/

The cache ID is generated automatically by JLD and stored in:

.. code-block:: text

    <build>/CMakeFiles/JLD.cache

The command creates an imported ``INTERFACE`` target:

.. code-block:: text

    jld::<name>

The target can then be passed to other JLD commands that accept Java
libraries or JAR files.

If the JAR does not exist, it is downloaded automatically.

When a checksum is specified, an existing JAR is verified against the
expected checksum. If verification fails, the existing JAR is replaced
by a newly downloaded copy.

When no checksum is specified, an existing JAR is reused without
verification.

Maven URL
---------

When Maven coordinates are used, the repository URL and coordinates are
converted to the standard Maven repository layout.

For example:

.. code-block:: cmake

    add_java_library(guava
        GROUP com.google.guava
        ARTIFACT guava
        VERSION 32.1.2-jre
    )

uses the Maven repository path:

.. code-block:: text

    com/google/guava/guava/32.1.2-jre/guava-32.1.2-jre.jar

Examples
--------

Add a library from Maven Central
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: cmake

    add_java_library(guava
        GROUP com.google.guava
        ARTIFACT guava
        VERSION 32.1.2-jre
        SHA256 1c3a0f0d6b44e1...
    )

Add a library from a direct URL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: cmake

    add_java_library(my-lib
        URL https://myserver.com/libs/my-lib-1.0.0.jar
    )

Specify a custom output name
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: cmake

    add_java_library(my-lib
        URL https://myserver.com/libs/my-lib-1.0.0.jar
        OUTPUT_NAME my-library.jar
    )

Use SHA1 verification
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: cmake

    add_java_library(my-lib
        URL https://myserver.com/libs/my-lib-1.0.0.jar
        SHA1 0123456789abcdef0123456789abcdef01234567
    )

Use MD5 verification
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: cmake

    add_java_library(my-lib
        URL https://myserver.com/libs/my-lib-1.0.0.jar
        MD5 0123456789abcdef0123456789abcdef
    )

Use a custom Maven repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: cmake

    add_java_library(my-lib
        GROUP com.example
        ARTIFACT my-lib
        VERSION 1.2.3
        REPOSITORY https://repo.example.com/maven
    )

Use the library with ``add_jar``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once the library has been added, its target can be passed to
``add_jar``:

.. code-block:: cmake

    add_java_library(guava
        GROUP com.google.guava
        ARTIFACT guava
        VERSION 32.1.2-jre
    )

    add_java_library(my-lib
        URL https://myserver.com/libs/my-lib-1.0.0.jar
    )

    add_jar(my-app
        SOURCES
            Main.java
        INCLUDE_JARS
            jld::my-lib
            jld::guava
    )

Notes
-----

- The ``URL`` form is useful for libraries hosted outside Maven
  repositories.
- The Maven form provides a convenient way to reference standard Maven
  artifacts.
- SHA256 verification is recommended when reproducible or trusted builds
  are required.
- SHA1 and MD5 are supported for compatibility with repositories or
  existing projects that use these algorithms.
- Only one of ``SHA256``, ``SHA1``, or ``MD5`` should be specified.
- The generated ``jld::<name>`` target is intended to be consumed by
  other JLD commands rather than linked directly as a native CMake
  library.
