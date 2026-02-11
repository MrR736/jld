# JLD.cmake — Java Libraries Downloader
# Distributed under the OSI-approved BSD 3-Clause License.

cmake_minimum_required(VERSION 3.20)

function(add_java_library _TARGET_NAME)
    set(options)
    set(oneValueArgs "URL;OUTPUT_NAME;VERSION;SHA256;GROUP;ARTIFACT;REPOSITORY")
    set(multiValueArgs "")

    cmake_parse_arguments(PARSE_ARGV 1 _jld_download "${options}" "${oneValueArgs}" "${multiValueArgs}")

    # Determine classpath separator
    if (WIN32)
        set(_jld_classpath_sep ";")
    else()
        set(_jld_classpath_sep ":")
    endif()

    # Determine download URL
    if (_jld_download_URL)
        set(JLD_URL "${_jld_download_URL}")

    elseif (_jld_download_GROUP AND
            _jld_download_ARTIFACT AND
            _jld_download_VERSION)

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
        set(JLD_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/JLD-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}.dir/${_jld_download_OUTPUT_NAME}.dir")
    else()
        set(JLD_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/JLD-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}.dir/${_TARGET_NAME}.dir")
        get_filename_component(JLD_OUTPUT_NAME "${JLD_URL}" NAME_WE)
    endif()

    # Determine final jar filename
    get_filename_component(JLD_OUTPUT_FILE "${JLD_URL}" NAME)

    # Prepare hash option
    set(_jld_hash)
    if (DEFINED _jld_download_SHA256 AND NOT _jld_download_SHA256 STREQUAL "")
        set(_jld_hash EXPECTED_HASH "SHA256=${_jld_download_SHA256}")
    else()
        message(WARNING
            "add_java_library(${_TARGET_NAME}) called without SHA256. "
            "Download will not be verified."
        )
    endif()

    # Download the file (re-downloads if hash mismatch)
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

    # Create imported INTERFACE target
    if (NOT TARGET jld::${_TARGET_NAME})
        add_library(jld::${_TARGET_NAME} INTERFACE IMPORTED)
    endif()

    set_property(TARGET jld::${_TARGET_NAME}
        PROPERTY JLD_JAR "${JLD_OUTPUT_DIR}/${JLD_OUTPUT_FILE}"
    )
endfunction()


function(java_link_libraries _TARGET)
    if (NOT TARGET "${_TARGET}")
        message(FATAL_ERROR "jld_link_libraries: Target '${_TARGET}' does not exist.")
    endif()

    if (WIN32)
        set(_jld_classpath_sep ";")
    else()
        set(_jld_classpath_sep ":")
    endif()

    set(_jld_classpath_list)

    foreach(_dep IN LISTS ARGN)
        if (NOT TARGET "${_dep}")
            message(FATAL_ERROR "jld_link_libraries: '${_dep}' is not a valid target.")
        endif()

        get_target_property(_jar "${_dep}" JLD_JAR)

        if (NOT _jar)
            message(FATAL_ERROR "jld_link_libraries: Target '${_dep}' has no JLD_JAR property.")
        endif()

        list(APPEND _jld_classpath_list "${_jar}")
    endforeach()

    # Remove duplicates
    list(REMOVE_DUPLICATES _jld_classpath_list)

    # Join into single classpath string
    string(JOIN "${_jld_classpath_sep}" _jld_classpath ${_jld_classpath_list})

    # Set classpath for Java compilation
    set_property(TARGET "${_TARGET}" APPEND PROPERTY JAVA_COMPILE_FLAGS "-classpath ${_jld_classpath}")
endfunction()
