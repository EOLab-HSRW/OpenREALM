# This file is part of OpenREALM.
#
# Copyright (C) 2018 Alexander Kern <laxnpander at gmail dot com> (Braunschweig University of Technology)
# For more information see <https://github.com/EOLab-HSRW/OpenREALM>
#
# OpenREALM is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# OpenREALM is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenREALM. If not, see <http://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 3.18)

set(CMAKE_CXX_STANDARD 17 CACHE STRING "C++ standard")
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
# set(CMAKE_CXX_EXTENSIONS ON)
# set(CMAKE_POSITION_INDEPENDENT_CODE ON)
# set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# set(CMAKE_PROJECT_TOP_LEVEL_INCLUDES "${CMAKE_CURRENT_LIST_DIR}/cmake/ConanBootstrap.cmake")

project(OpenREALM VERSION 1.0.0 LANGUAGES CXX)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

option(${PROJECT_NAME}_BUILD_CORE       "Build core"          ON)
option(${PROJECT_NAME}_BUILD_IO         "Build io"            ON)
option(${PROJECT_NAME}_BUILD_DENSIFIER  "Build densifier"     ON)
option(${PROJECT_NAME}_BUILD_ORTHO      "Build ortho"         ON)
option(${PROJECT_NAME}_BUILD_VSLAM_BASE "Build vslam_base"    ON)
option(${PROJECT_NAME}_BUILD_STAGES     "Build stages"        ON)

option(TESTS_ENABLED "Whether to build test binaries" ON)

# Prefer config packages installed by Spack over Find<...>.cmake modules
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON)

set_property(GLOBAL PROPERTY OPENREALM_MODULES_TARGETS "")


if (${PROJECT_NAME}_BUILD_CORE)
  add_subdirectory(modules/core)
endif()

if (${PROJECT_NAME}_BUILD_IO)
  add_subdirectory(modules/io)
endif()

if (${PROJECT_NAME}_BUILD_DENSIFIER)
  add_subdirectory(modules/densifier)
endif()

if (${PROJECT_NAME}_BUILD_ORTHO)
  add_subdirectory(modules/ortho)
endif()

if (${PROJECT_NAME}_BUILD_VSLAM_BASE)
  add_subdirectory(modules/vslam)
endif()

if (${PROJECT_NAME}_BUILD_STAGES)
    add_subdirectory(modules/stages)
endif()

get_property(_OPENREALM_MODULES_TARGETS GLOBAL PROPERTY OPENREALM_MODULES_TARGETS)

add_library(${PROJECT_NAME} INTERFACE)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
if (_OPENREALM_MODULES_TARGETS)
    target_link_libraries(${PROJECT_NAME} INTERFACE ${_OPENREALM_MODULES_TARGETS})
endif()


set(AVAILABLE_COMPONENTS "${OPENREALM_MODULES_TARGETS}") # used by the Config.cmake

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

set(OPENREALM_CONFIG_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}-${PROJECT_VERSION})

install(EXPORT ${PROJECT_NAME}Targets
  NAMESPACE ${PROJECT_NAME}::
  FILE ${PROJECT_NAME}Targets.cmake
  DESTINATION ${OPENREALM_CONFIG_INSTALL_DIR}
)

# Package config + version files
configure_package_config_file(
  "${PROJECT_SOURCE_DIR}/cmake/${PROJECT_NAME}Config.cmake.in"
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  INSTALL_DESTINATION ${OPENREALM_CONFIG_INSTALL_DIR}
)

write_basic_package_version_file(
    "${PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  DESTINATION ${OPENREALM_CONFIG_INSTALL_DIR}
)

set(OPENREALM_ADDITIONAL_FILES_INSTALL_DIR "${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}-${PROJECT_VERSION}")
install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE"
    "${CMAKE_CURRENT_SOURCE_DIR}/README.md"
    DESTINATION ${OPENREALM_ADDITIONAL_FILES_INSTALL_DIR}
)
