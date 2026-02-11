java_link_libraries
===================

Link Java library targets to a Java compilation target.

Usage
-----

.. code-block:: cmake

    java_link_libraries(<target> <jld_target_1> [<jld_target_2> ...])

Parameters
----------

- **`<target>`**
  Your Java compilation target created via `add_jar` or similar.

- **`<jld_target_n>`**
  One or more `jld::<name>` imported targets created by `add_java_library()`.

Behavior
--------

- Gathers all jar paths from the specified `jld::<name>` targets.
- Removes duplicates automatically.
- Sets the `-classpath` for Java compilation using `JAVA_COMPILE_FLAGS`.

Errors
------

- Fails if any dependency target does not exist.
- Fails if any dependency target does not have a `JLD_JAR` property.

Example
-------

.. code-block:: cmake

    add_java_library(guava
        GROUP com.google.guava
        ARTIFACT guava
        VERSION 32.1.2-jre
    )

    add_jar(MyApp SOURCES Main.java)

    java_link_libraries(MyApp jld::guava)
