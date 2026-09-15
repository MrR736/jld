cmake_minimum_required(VERSION 3.20)

project(JLD
	VERSION 1.2
	DESCRIPTION "Java Libraries Downloader for CMake"
	LANGUAGES NONE
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(JLD_CMAKE_LIBDIR "${CMAKE_INSTALL_PREFIX}/lib/cmake")

# Package version
write_basic_package_version_file(
	"${CMAKE_CURRENT_BINARY_DIR}/JLDConfigVersion.cmake"
	VERSION "${PROJECT_VERSION}"
	COMPATIBILITY SameMajorVersion
)

# Package configuration
configure_package_config_file(
	"${CMAKE_CURRENT_SOURCE_DIR}/JLDConfig.cmake.in"
	"${CMAKE_CURRENT_BINARY_DIR}/JLDConfig.cmake"
	INSTALL_DESTINATION
		"${JLD_CMAKE_LIBDIR}/JLD"
	NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

# Install JLD CMake module
install(
	FILES
		"${CMAKE_CURRENT_SOURCE_DIR}/cmake/JLD.cmake"
		"${CMAKE_CURRENT_BINARY_DIR}/JLDConfig.cmake"
		"${CMAKE_CURRENT_BINARY_DIR}/JLDConfigVersion.cmake"
	DESTINATION
		"${JLD_CMAKE_LIBDIR}/JLD"
)

# Documentation
install(
	DIRECTORY
		"${CMAKE_CURRENT_SOURCE_DIR}/Help/"
	DESTINATION
		"${CMAKE_INSTALL_DATADIR}/JLD"
)

include(CPack)
