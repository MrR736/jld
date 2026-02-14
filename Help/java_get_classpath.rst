java_get_classpath
==================

Construct a platform-correct Java classpath string from JLD targets.

Synopsis
--------

.. code-block:: cmake

   java_get_classpath(<out-var> <target>...)

Description
-----------

``java_get_classpath()`` collects the ``JLD_JAR`` property from each
specified target and joins them into a single classpath string using
the correct platform separator:

- ``;`` on Windows
- ``:`` on UNIX-like systems

The resulting classpath string is stored in ``<out-var>`` in the
parent scope.

Arguments
---------

``<out-var>``
  Name of the variable that will receive the classpath string.

``<target>...``
  One or more imported JLD targets (typically ``jld::<artifact>``).

Behavior
--------

For each target:

1. Verifies the target exists.
2. Reads its ``JLD_JAR`` property.
3. Appends the jar path to the classpath list.
4. Removes duplicate entries.
5. Joins them into a single string.
6. Sets the output variable in the parent scope.

Errors
------

A fatal error occurs if:

- A specified target does not exist
- A target does not contain a ``JLD_JAR`` property

Example
-------

.. code-block:: cmake

   add_java_libraries(
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9
           com.google.guava:guava:33.0.0-jre
   )

   java_get_classpath(MY_CLASSPATH
       jld::slf4j-api
       jld::guava
   )

   add_custom_target(run_app
       COMMAND java -cp "${MY_CLASSPATH}" com.example.Main
   )

Notes
-----

This function does not automatically include compiled classes
from the current project. It only aggregates JLD-managed jars.

See Also
--------

- ``add_java_library()``
- ``add_java_libraries()``
- ``java_link_libraries()``
- ``java_run()``
