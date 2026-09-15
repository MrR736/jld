cmake_minimum_required(VERSION 3.20)

project(JLDTest LANGUAGES NONE)

enable_testing()

find_package(Java REQUIRED)

include("${CMAKE_CURRENT_LIST_DIR}/../cmake/JLD.cmake")

# Helper
function(jld_test_assert_condition _condition _message)
	if(NOT ${_condition})
		message(FATAL_ERROR "[FAIL] ${_message}")
	endif()
	message(STATUS "[ OK ] ${_message}")
endfunction()

function(jld_test_assert_equal _actual _expected _message)
	if(NOT "${_actual}" STREQUAL "${_expected}")
		message(FATAL_ERROR
			"[FAIL] ${_message}\n"
			"  Expected: '${_expected}'\n"
			"  Actual:   '${_actual}'"
		)
	endif()
	message(STATUS "[ OK ] ${_message}")
endfunction()

# Test add_java_library()
add_java_library(aislib
	GROUP aislib
	ARTIFACT aislib
	VERSION 0.5.2
	MD5 1b6267a94167f781d3476024258346b4
)

if(NOT TARGET jld::aislib)
	message(FATAL_ERROR "[FAIL] jld::aislib target was not created")
endif()

message(STATUS "[ OK ] jld::aislib target created")

get_target_property(JLD_TEST_JAR jld::aislib JLD_JAR)

if(NOT JLD_TEST_JAR)
	message(FATAL_ERROR "[FAIL] jld::aislib has no JLD_JAR property")
endif()

message(STATUS "[ OK ] JLD_JAR = ${JLD_TEST_JAR}")

if(NOT EXISTS "${JLD_TEST_JAR}")
	message(FATAL_ERROR "[FAIL] downloaded JAR does not exist:\n${JLD_TEST_JAR}")
endif()

message(STATUS "[ OK ] downloaded JAR exists")

get_target_property(JLD_TEST_JAR_FILE jld::aislib JAR_FILE)
jld_test_assert_equal("${JLD_TEST_JAR_FILE}" "${JLD_TEST_JAR}" "JAR_FILE equals JLD_JAR")

# Test add_java_libraries()
add_java_libraries(
	HASH_ALGORITHM MD5
	LIBRARIES
		aislib:aislib:0.5.2:1b6267a94167f781d3476024258346b4
)

if(NOT TARGET jld::aislib)
	message(FATAL_ERROR "[FAIL] add_java_libraries() did not create target")
endif()

message(STATUS "[ OK ] add_java_libraries() created target")

# Test java_get_classpath()
java_get_classpath(JLD_TEST_CLASSPATH jld::aislib)

if(NOT JLD_TEST_CLASSPATH)
	message(FATAL_ERROR "[FAIL] java_get_classpath() returned empty classpath")
endif()

message(STATUS "[ OK ] java_get_classpath() = ${JLD_TEST_CLASSPATH}")

if(NOT JLD_TEST_CLASSPATH STREQUAL "${JLD_TEST_JAR}")
	message(FATAL_ERROR "[FAIL] classpath does not contain expected JAR")
endif()

message(STATUS "[ OK ] classpath contains expected JAR")

message(STATUS "")
message(STATUS "All JLD tests passed")
