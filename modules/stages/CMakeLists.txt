cmake_minimum_required(VERSION 3.18)

set(MODULE_NAME stages)

find_package(OpenCV 3.3.1 EXACT QUIET)
if (NOT OpenCV_FOUND)
    find_package(OpenCV 3 QUIET)
endif()
if (NOT OpenCV_FOUND)
    find_package(OpenCV 4 REQUIRED)
    message(WARNING "OpenCV 4 Support is experimental, use at your own risk!")
endif()

add_library(${MODULE_NAME} SHARED
    src/conversions.cpp
    src/densification.cpp
    src/mosaicing.cpp
    src/ortho_rectification.cpp
    src/pose_estimation.cpp
    src/stage_base.cpp
    src/stage_settings_factory.cpp
    src/surface_generation.cpp
    src/tileing.cpp
)

target_link_libraries(${MODULE_NAME}
    PUBLIC
    core
    io
    ortho
    vslam
    densifier_base
    opencv_core
)

target_compile_features(${MODULE_NAME} PUBLIC cxx_std_17)

target_include_directories(${MODULE_NAME}
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
set_target_properties(${MODULE_NAME} PROPERTIES EXPORT_NAME ${MODULE_NAME})

add_library(${PROJECT_NAME}::${MODULE_NAME} ALIAS ${MODULE_NAME})

set_property(GLOBAL APPEND PROPERTY OPENREALM_MODULES_TARGETS ${MODULE_NAME})

install(TARGETS ${MODULE_NAME}
    EXPORT ${PROJECT_NAME}Targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/conversions.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/densification.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/mosaicing.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/ortho_rectification.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/pose_estimation.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/stage_base.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/stage_settings.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/stage_settings_factory.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/surface_generation.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/tileing.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/${MODULE_NAME}
)
