cmake_minimum_required(VERSION 3.20)

project(JLD
	VERSION 1.1
	DESCRIPTION "Java Libraries Downloader for CMake"
	LANGUAGES NONE
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

install(FILES
	"${CMAKE_CURRENT_SOURCE_DIR}/cmake/JLD.cmake"
	DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/JLD"
)

write_basic_package_version_file(
	"${CMAKE_CURRENT_BINARY_DIR}/JLDConfigVersion.cmake"
	VERSION ${PROJECT_VERSION}
	COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
	"${CMAKE_CURRENT_SOURCE_DIR}/JLDConfig.cmake.in"
	"${CMAKE_CURRENT_BINARY_DIR}/JLDConfig.cmake"
	INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/JLD"
	NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

install(FILES
	"${CMAKE_CURRENT_BINARY_DIR}/JLDConfig.cmake"
	"${CMAKE_CURRENT_BINARY_DIR}/JLDConfigVersion.cmake"
	DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/JLD"
)

install(DIRECTORY
	"${CMAKE_CURRENT_SOURCE_DIR}/Help/"
	DESTINATION "${CMAKE_INSTALL_DATADIR}/JLD"
)

include(CPack)
