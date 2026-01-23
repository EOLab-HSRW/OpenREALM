cmake_minimum_required(VERSION 3.18)

set(MODULE_NAME io)

find_package(OpenCV 3.3.1 EXACT QUIET)
if (NOT OpenCV_FOUND)
    find_package(OpenCV 3 QUIET)
endif()
if (NOT OpenCV_FOUND)
    find_package(OpenCV 4 REQUIRED)
    message(WARNING "OpenCV 4 Support is experimental, use at your own risk!")
endif()

find_package(GDAL 3.4 REQUIRED)                         # (Ubuntu 22.04 apt available version)
find_package(Boost REQUIRED COMPONENTS filesystem)
find_package(PCL 1.12 REQUIRED COMPONENTS io common)    # (Ubuntu 22.04 apt available version)
find_package(Eigen3 3.4 REQUIRED NO_MODULE)             # (Ubuntu 22.04 apt available version)
find_package(exiv2 CONFIG REQUIRED NAMES exiv2) # Harley: Let's avoid this from apt

add_library(${MODULE_NAME} SHARED
    src/cv_export.cpp
    src/cv_import.cpp
    src/exif_export.cpp
    src/exif_import.cpp
    src/gdal_continuous_writer.cpp
    src/gis_export.cpp
    src/mvs_export.cpp
    src/pcl_export.cpp
    src/realm_export.cpp
    src/realm_import.cpp
    src/utilities.cpp
)

target_link_libraries(${MODULE_NAME}
    PUBLIC
    core
    opencv_imgcodecs
    # GDAL::GDAL # this was added in 3.5: see https://gdal.org/en/release-3.12/development/cmake.html#using-gdal-in-cmake-projects
    ${GDAL_LIBRARY} # for version 3.4
    ${Boost_LIBRARIES}
    ${PCL_LIBRARIES}
    Eigen3::Eigen
    exiv2lib
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
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/cv_export.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/cv_import.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/exif_export.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/exif_import.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/gdal_continuous_writer.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/gis_export.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/mvs_export.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/pcl_export.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/realm_export.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/realm_import.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/utilities.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/${MODULE_NAME}
)

if(TESTS_ENABLED)
    include(GoogleTest)
    find_package(GTest REQUIRED)

    add_executable(run_realm_io_tests
        test/test_realm_io.cpp
        test/mvs_io_test.cpp
        test/cv_io_test.cpp
        test/realm_io_test.cpp
    )

    # Standard linking to gtest stuff.
    target_link_libraries(run_realm_io_tests GTest::gtest_main GTest::gtest)

    # Extra linking for the project.
    target_link_libraries(run_realm_io_tests ${MODULE_NAME})

    add_custom_command(TARGET run_realm_io_tests PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/test/data $<TARGET_FILE_DIR:run_realm_io_tests>
    )

    # This is so you can do 'make test' to see all your tests run, instead of
    # manually running the executable run_unit_tests to see those specific tests.
    add_test(
        NAME
        realm_io_unit_tests
        COMMAND
        ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}/run_realm_io_tests
    )

endif()
