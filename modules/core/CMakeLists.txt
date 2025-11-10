cmake_minimum_required(VERSION 3.18)

set(MODULE_NAME core)

find_package(OpenCV 3.3.1 EXACT QUIET)
if (NOT OpenCV_FOUND)
    find_package(OpenCV 3 QUIET)
endif()
if (NOT OpenCV_FOUND)
    find_package(OpenCV 4 REQUIRED)
    message(WARNING "OpenCV 4 Support is experimental, use at your own risk!")
endif()

find_package(GDAL 3.4 REQUIRED) # (Ubuntu 22.04 apt available version)

# get_target_property(_gdal GDAL::GDAL LOCATION)
# message(STATUS "GDAL::GDAL => ${_gdal}")
# get_target_property(_gdal_inc GDAL::GDAL INTERFACE_INCLUDE_DIRECTORIES)
# message(STATUS "GDAL includes => ${_gdal_inc}")

add_library(${MODULE_NAME} SHARED
    src/timer.cpp
    src/analysis.cpp
    src/camera.cpp
    src/camera_settings_factory.cpp
    src/conversions.cpp
    src/cv_grid_map.cpp
    src/depthmap.cpp
    src/frame.cpp
    src/plane_fitter.cpp
    src/point_cloud.cpp
    src/settings_base.cpp
    src/stereo.cpp
    src/timer.cpp
    src/worker_thread_base.cpp
)

target_link_libraries(${MODULE_NAME}
    PUBLIC
    opencv_core
    opencv_imgproc
    opencv_calib3d
    # GDAL::GDAL # this was added in 3.5: see https://gdal.org/en/release-3.12/development/cmake.html#using-gdal-in-cmake-projects
    ${GDAL_LIBRARY} # for version 3.4
)

target_compile_features(${MODULE_NAME} PUBLIC cxx_std_17)

target_include_directories(${MODULE_NAME}
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
set_target_properties(${MODULE_NAME} PROPERTIES EXPORT_NAME ${MODULE_NAME})

add_library(${PROJECT_NAME}::${MODULE_NAME} ALIAS ${MODULE_NAME})


set_property(GLOBAL APPEND PROPERTY OPENREALM_MODULES_TARGETS core)

install(TARGETS core
    EXPORT ${PROJECT_NAME}Targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/analysis.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/camera.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/camera_settings.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/camera_settings_factory.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/conversions.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/cv_grid_map.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/depthmap.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/frame.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/imu_settings.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/loguru.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/plane_fitter.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/point_cloud.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/settings_base.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/stereo.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/structs.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/timer.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/tree_node.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/utm32.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/wgs84.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/worker_thread_base.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/${MODULE_NAME}
)


if(TESTS_ENABLED)
    include(GoogleTest)
    find_package(GTest REQUIRED)

    add_executable(run_realm_core_tests
        test/test_realm_core.cpp
        test/test_helper.cpp
        test/conversion_test.cpp
        test/cvgridmap_test.cpp
        test/depthmap_test.cpp
        test/frame_test.cpp
        test/pinhole_test.cpp
        test/plane_fitter_test.cpp
        test/settings_test.cpp
        test/stereo_test.cpp
        test/worker_thread_test.cpp
    )

    # Standard linking to gtest stuff.
    target_link_libraries(run_realm_core_tests GTest::gtest_main GTest::gtest)

    # Extra linking for the project.
    target_link_libraries(run_realm_core_tests ${MODULE_NAME} )

    add_custom_command(TARGET run_realm_core_tests PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/test/data $<TARGET_FILE_DIR:run_realm_core_tests>
    )

    # This is so you can do 'make test' to see all your tests run, instead of
    # manually running the executable run_unit_tests to see those specific tests.
    add_test(
        NAME
        realm_core_unit_tests
        COMMAND
        ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}/run_realm_core_tests
    )
endif()
