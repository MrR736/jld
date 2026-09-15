# JLD.cmake — Java Libraries Downloader
# Distributed under the OSI-approved BSD 3-Clause License.

cmake_minimum_required(VERSION 3.20)

find_package(Java REQUIRED)

set(JLD_VERSION "1.2" CACHE INTERNAL "JLD version")

set(JLD_CACHE_FILE "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/JLD.cache")
if(NOT EXISTS "${JLD_CACHE_FILE}")
	string(RANDOM LENGTH 8 ALPHABET "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" _random)
	file(WRITE "${JLD_CACHE_FILE}" "${_random}")
endif()

if(EXISTS "${JLD_CACHE_FILE}")
	file(READ "${JLD_CACHE_FILE}" JLD_CACHE_CONTENT)
endif()

set(
	JLD_FILES_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/JLD-${JLD_CACHE_CONTENT}.dir"
	CACHE PATH "Directory containing downloaded Java libraries"
)

if (WIN32)
	set(_jld_classpath_sep ";")
else()
	set(_jld_classpath_sep ":")
endif()

function(add_java_library _TARGET_NAME)
	set(options)
	set(oneValueArgs URL OUTPUT_NAME VERSION SHA256 SHA1 MD5 GROUP ARTIFACT REPOSITORY)
	set(multiValueArgs)

	cmake_parse_arguments(PARSE_ARGV 1 _jld_download "${options}" "${oneValueArgs}" "${multiValueArgs}")

	# Determine download URL
	if (_jld_download_URL)
		set(JLD_URL "${_jld_download_URL}")

	elseif (_jld_download_GROUP AND _jld_download_ARTIFACT AND _jld_download_VERSION)
		if (_jld_download_REPOSITORY)
			set(_jld_repo "${_jld_download_REPOSITORY}")
		else()
			set(_jld_repo "https://repo1.maven.org/maven2")
		endif()
		string(REPLACE "." "/" _jld_group_path "${_jld_download_GROUP}")
		set(JLD_URL
			"${_jld_repo}/${_jld_group_path}/${_jld_download_ARTIFACT}/${_jld_download_VERSION}/${_jld_download_ARTIFACT}-${_jld_download_VERSION}.jar"
		)
	else()
		message(FATAL_ERROR
			"add_java_library: Must provide either:\n"
			"  URL <url>\n"
			"OR\n"
			"  GROUP <group> ARTIFACT <artifact> VERSION <version>"
		)
	endif()

	# Determine output directory and name
	if (_jld_download_OUTPUT_NAME)
		set(JLD_OUTPUT_NAME "${_jld_download_OUTPUT_NAME}")
		set(JLD_OUTPUT_DIR "${JLD_FILES_DIRECTORY}/${_jld_download_OUTPUT_NAME}.dir")
	else()
		set(JLD_OUTPUT_DIR "${JLD_FILES_DIRECTORY}/${_TARGET_NAME}.dir")
		get_filename_component(JLD_OUTPUT_NAME "${JLD_URL}" NAME_WE)
	endif()

	# Determine final JAR filename
	get_filename_component(JLD_OUTPUT_FILE "${JLD_URL}" NAME)

	# Prepare hash option
	unset(_jld_hash)

	if (_jld_download_SHA256)
		set(_jld_hash EXPECTED_HASH "SHA256=${_jld_download_SHA256}")
		set(_jld_download_hash "${_jld_download_SHA256}")
		set(JLD_HASH_FILE "${JLD_OUTPUT_FILE}.sha256")
	elseif (_jld_download_SHA1)
		set(_jld_hash EXPECTED_HASH "SHA1=${_jld_download_SHA1}")
		set(_jld_download_hash "${_jld_download_SHA1}")
		set(JLD_HASH_FILE "${JLD_OUTPUT_FILE}.sha1")
	elseif (_jld_download_MD5)
		set(_jld_hash EXPECTED_HASH "MD5=${_jld_download_MD5}")
		set(_jld_download_hash "${_jld_download_MD5}")
		set(JLD_HASH_FILE "${JLD_OUTPUT_FILE}.md5")
	else()
		message(WARNING
			"add_java_library(${_TARGET_NAME}) called without "
			"SHA256, SHA1, or MD5. Download will not be verified."
		)
	endif()

	# Download
	if(NOT EXISTS "${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}")
		file(MAKE_DIRECTORY "${JLD_OUTPUT_DIR}")
		file(DOWNLOAD
			"${JLD_URL}"
			"${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}"
			SHOW_PROGRESS
			STATUS download_status
			LOG download_log
			${_jld_hash}
		)
		list(GET download_status 0 download_result)
		if(NOT download_result EQUAL 0)
			file(REMOVE "${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}")
			message(FATAL_ERROR "Failed to download ${JLD_OUTPUT_FILE}: ${download_log}")
		endif()
	endif()

	if(_jld_download_SHA256)
		file(SHA256 "${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}" _existing_hash)
		if(NOT _existing_hash STREQUAL _jld_download_SHA256)
			file(REMOVE "${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}")
		endif()
	elseif(_jld_download_SHA1)
		file(SHA1 "${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}" _existing_hash)
		if(NOT _existing_hash STREQUAL _jld_download_SHA1)
			file(REMOVE "${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}")
		endif()
	elseif(_jld_download_MD5)
		file(MD5 "${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}" _existing_hash)
		if(NOT _existing_hash STREQUAL _jld_download_MD5)
			file(REMOVE "${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}")
		endif()
	endif()

	# Create imported INTERFACE target
	if(NOT TARGET jld::${_TARGET_NAME})
		add_library(jld::${_TARGET_NAME} INTERFACE IMPORTED)
	endif()

	set_property(
		TARGET jld::${_TARGET_NAME}
		PROPERTY JLD_JAR "${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}"
	)

	set_property(
		TARGET jld::${_TARGET_NAME}
		PROPERTY JAR_FILE "${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}"
	)
endfunction()

function(add_java_libraries)
	set(options)
	set(oneValueArgs HASH_ALGORITHM REPOSITORY)
	set(multiValueArgs LIBRARIES)

	cmake_parse_arguments(PARSE_ARGV 0 _jld_multi "${options}" "${oneValueArgs}" "${multiValueArgs}" )
	if(NOT _jld_multi_HASH_ALGORITHM)
		set(_jld_multi_HASH_ALGORITHM SHA256)
	endif()
	if(NOT _jld_multi_HASH_ALGORITHM STREQUAL "SHA256"
		AND NOT _jld_multi_HASH_ALGORITHM STREQUAL "SHA1"
		AND NOT _jld_multi_HASH_ALGORITHM STREQUAL "MD5")
		message(FATAL_ERROR
			"add_java_libraries: HASH_ALGORITHM must be one of "
			"SHA256, SHA1, or MD5; got '${_jld_multi_HASH_ALGORITHM}'"
		)
	endif()
	unset(_repository_arg)
	if(_jld_multi_REPOSITORY)
		set(_repository_arg REPOSITORY ${_jld_multi_REPOSITORY})
	endif()
	foreach(_lib IN LISTS _jld_multi_LIBRARIES)
		unset(_hash_type_arg)
		string(REPLACE ":" ";" _parts "${_lib}")
		list(LENGTH _parts _len)
		if(_len LESS 3 OR _len GREATER 4)
			message(FATAL_ERROR
				"Invalid library format: ${_lib}\n"
				"Expected: group:artifact:version[:hash]"
			)
		endif()
		list(GET _parts 0 _group)
		list(GET _parts 1 _artifact)
		list(GET _parts 2 _version)
		if(_len EQUAL 4)
			list(GET _parts 3 _hash)
			set(_hash_type_arg ${_jld_multi_HASH_ALGORITHM} ${_hash})
		endif()
		add_java_library(${_artifact}
			GROUP ${_group}
			ARTIFACT ${_artifact}
			VERSION ${_version}
			${_hash_type_arg}
			${_repository_arg}
		)
	endforeach()
endfunction()

function(java_get_classpath _OUT_VAR)
	set(_jld_classpath_list)

	foreach(_dep IN LISTS ARGN)
		get_target_property(_jar "${_dep}" JLD_JAR)
		if (NOT _jar)
			message(FATAL_ERROR "Target '${_dep}' has no JLD_JAR property.")
		endif()
		list(APPEND _jld_classpath_list "${_jar}")
	endforeach()

	list(REMOVE_DUPLICATES _jld_classpath_list)
	string(JOIN "${_jld_classpath_sep}" _classpath ${_jld_classpath_list})
	set(${_OUT_VAR} "${_classpath}" PARENT_SCOPE)
endfunction()

function(java_run _TARGET)
	set(options)
	set(oneValueArgs MAIN_CLASS)
	set(multiValueArgs LIBRARIES ARGS)
	cmake_parse_arguments(PARSE_ARGV 1 _jld_run "${options}" "${oneValueArgs}" "${multiValueArgs}")
	if (NOT _jld_run_MAIN_CLASS)
		message(FATAL_ERROR "java_run: MAIN_CLASS required.")
	endif()

	java_get_classpath(_cp ${_jld_run_LIBRARIES})
	add_custom_target(${_TARGET}
		COMMAND ${Java_JAVA_EXECUTABLE} -cp "${_cp}" ${_jld_run_MAIN_CLASS} ${_jld_run_ARGS}
		DEPENDS ${_jld_run_LIBRARIES}
	)
endfunction()
