java_run
========

Create a custom target that runs a Java application with JLD libraries.

Synopsis
--------

.. code-block:: cmake

   java_run(<target>
       MAIN_CLASS <class>
       [LIBRARIES <target>...]
       [ARGS <arg>...]
   )

Description
-----------

``java_run()`` creates a custom target that executes the Java runtime
with a generated classpath built from JLD targets.

It is a convenience wrapper around:

- ``java_get_classpath()``
- ``add_custom_target()``

Arguments
---------

``<target>``
  Name of the custom target to create.

``MAIN_CLASS <class>``
  Fully-qualified name of the Java entry point class.
  (Required)

``LIBRARIES <target>...``
  JLD targets whose jars should be added to the classpath.

``ARGS <arg>...``
  Arguments passed to the Java application at runtime.

Behavior
--------

1. Generates a classpath from ``LIBRARIES``.
2. Creates a custom target executing:

   ::

      java -cp "<classpath>" <MAIN_CLASS> <ARGS>

3. Adds dependencies on the specified libraries.

Example
-------

.. code-block:: cmake

   add_java_libraries(
       LIBRARIES
           org.slf4j:slf4j-api:2.0.9
   )

   java_run(run_app
       MAIN_CLASS com.example.Main
       LIBRARIES jld::slf4j-api
       ARGS hello world
   )

Then run:

::

   cmake --build . --target run_app

Notes
-----

- This function does not compile Java sources.
- It assumes the main class is available in the classpath.
- Platform-specific classpath separators are handled automatically.

Typical Workflow
----------------

1. Add dependencies via ``add_java_libraries()``.
2. Compile Java sources.
3. Use ``java_run()`` to create a runnable target.

See Also
--------

- ``java_get_classpath()``
- ``add_java_libraries()``
- ``java_link_libraries()``
