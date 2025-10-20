
cmake_minimum_required(VERSION 3.15)

set(LIBRARY_NAME realm_densifier_base)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

################################################################################
# Dependencies
################################################################################

# Fix to avoid OpenCV package confusion with ROS melodic
find_package(OpenCV 3.3.1 EXACT QUIET)
if (NOT OpenCV_FOUND)
    find_package(OpenCV 3 QUIET)
endif()
if (NOT OpenCV_FOUND)
    find_package(OpenCV 4 REQUIRED)
    message(WARNING "OpenCV 4 Support is experimental, use at your own risk!")
endif()


################################################################################
# Sources
################################################################################


set(root ${CMAKE_CURRENT_SOURCE_DIR})

# Use presence of the PSL target (added by the submodule) to decide CUDA path.
set(DENSIFIER_WITH_CUDA FALSE)
if (TARGET PSL OR TARGET PSL::PSL)
    set(DENSIFIER_WITH_CUDA TRUE)
    message(STATUS "PSL target found — building densifier with CUDA support.")
endif()

# if (DENSIFIER_WITH_CUDA)
#     add_definitions(-DUSE_CUDA)
#     set(DENSIFIER_IMPL_LIBS PSL)
#     set(DENSIFIER_IMPL_LIBS_HEADER ${psl_INCLUDE_DIR})
#     set(DENSIFIER_IMPL_HEADERS ${root}/include/realm_densifier_base/plane_sweep.h)
#     set(DENSIFIER_IMPL_SOURCES ${root}/src/plane_sweep.cpp)
# endif()

set(HEADER_FILES
        ${root}/include/realm_densifier_base/densifier_dummy.h
        ${root}/include/realm_densifier_base/densifier_factory.h
        ${root}/include/realm_densifier_base/densifier_IF.h
        ${root}/include/realm_densifier_base/densifier_settings.h
        ${root}/include/realm_densifier_base/densifier_settings_factory.h
        ${DENSIFIER_IMPL_HEADERS}
)

set(SOURCE_FILES
        ${root}/src/densifier_factory.cpp
        ${root}/src/densifier_settings_factory.cpp
        ${root}/src/densifier_dummy.cpp
        ${DENSIFIER_IMPL_SOURCES})

if (DENSIFIER_WITH_CUDA)
    list(APPEND HEADER_FILES
        ${root}/include/realm_densifier_base/plane_sweep.h
    )
    list(APPEND SOURCE_FILES
        ${root}/src/plane_sweep.cpp
    )
endif()


source_group(TREE ${root} FILES ${HEADER_FILES} ${SOURCE_FILES})

# Define the folder containing the header files for this library
set(realm_densifier_base_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include PARENT_SCOPE)


################################################################################
# Build
################################################################################

add_library(${LIBRARY_NAME} SHARED
    ${SOURCE_FILES}
    ${HEADER_FILES}
    ${FORM_HEADERS}
    ${HEADERS_MOC}
    ${RESOURCES_RCC}
)

# Public headers for dependents
target_include_directories(${LIBRARY_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${OpenREALM_INC_INSTALL_DIR}>
    PRIVATE
        ${OpenCV_INCLUDE_DIRS}
)

# Definitions: expose USE_CUDA only when the CUDA impl is compiled
if (DENSIFIER_WITH_CUDA)
    target_compile_definitions(${LIBRARY_NAME} PUBLIC USE_CUDA)
endif()

# Link deps
target_link_libraries(${LIBRARY_NAME}
    PUBLIC
        realm_core
        realm_io
    PRIVATE

        ${OpenCV_LIBRARIES}
)

# Link PSL if available (transitively brings its public include dirs)
if (TARGET PSL::PSL)
    target_link_libraries(${LIBRARY_NAME} PUBLIC PSL::PSL)
elseif (TARGET PSL)
    target_link_libraries(${LIBRARY_NAME} PUBLIC PSL)
endif()

################################################################################
# Install
################################################################################

set_target_properties(${LIBRARY_NAME}
    PROPERTIES OUTPUT_NAME "open_${LIBRARY_NAME}-${OpenREALM_VERSION}"
)


install(TARGETS ${LIBRARY_NAME} EXPORT OpenREALMTargets
    RUNTIME  DESTINATION ${OpenREALM_RUNTIME_INSTALL_DIR}
    LIBRARY  DESTINATION ${OpenREALM_LIBRARY_INSTALL_DIR}
    ARCHIVE  DESTINATION ${OpenREALM_ARCHIVE_INSTALL_DIR}
    FRAMEWORK DESTINATION ${OpenREALM_FRAMEWORK_INSTALL_DIR}
)

install(
    DIRECTORY include/${LIBRARY_NAME}
    DESTINATION ${OpenREALM_INC_INSTALL_DIR}

    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.hpp"
)
