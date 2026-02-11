cmake_minimum_required(VERSION 3.20)
project(JLD VERSION 1.0 LANGUAGES NONE)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

write_basic_package_version_file(
	"${CMAKE_CURRENT_BINARY_DIR}/JLDConfigVersion.cmake"
	VERSION ${PROJECT_VERSION}
	COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
	"${CMAKE_CURRENT_SOURCE_DIR}/JLDConfig.cmake.in"
	"${CMAKE_CURRENT_BINARY_DIR}/JLDConfig.cmake"
	INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/JLD
)

install(FILES
	"${CMAKE_CURRENT_SOURCE_DIR}/cmake/JLD.cmake"
	"${CMAKE_CURRENT_BINARY_DIR}/JLDConfig.cmake"
	"${CMAKE_CURRENT_BINARY_DIR}/JLDConfigVersion.cmake"
	DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/JLD
)

# Install documentation
install(DIRECTORY Help/module
	DESTINATION ${CMAKE_INSTALL_DATADIR}/doc/JLD
)
