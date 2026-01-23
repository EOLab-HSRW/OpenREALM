cmake_minimum_required(VERSION 3.18)

set(MODULE_NAME densifier_base)

find_package(OpenCV 3.3.1 EXACT QUIET)
if (NOT OpenCV_FOUND)
    find_package(OpenCV 3 QUIET)
endif()
if (NOT OpenCV_FOUND)
    find_package(OpenCV 4 REQUIRED)
    message(WARNING "OpenCV 4 Support is experimental, use at your own risk!")
endif()

# TODO: Handle plane_sweep integration

add_library(${MODULE_NAME} SHARED
    src/densifier_dummy.cpp
    src/densifier_factory.cpp
    src/densifier_settings_factory.cpp
    # src/plane_sweep.cpp
)

target_link_libraries(${MODULE_NAME}
    PUBLIC
    core
    io
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
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/densifier_IF.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/densifier_dummy.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/densifier_factory.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/densifier_settings.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/densifier_settings_factory.h
    # ${CMAKE_CURRENT_SOURCE_DIR}/include/${module_NAME}/plane_sweep.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/${MODULE_NAME}
)
