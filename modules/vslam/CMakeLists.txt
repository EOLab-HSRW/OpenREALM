cmake_minimum_required(VERSION 3.18)

set(MODULE_NAME vslam)

find_package(OpenCV 3.3.1 EXACT QUIET)
if (NOT OpenCV_FOUND)
    find_package(OpenCV 3 QUIET)
endif()
if (NOT OpenCV_FOUND)
    find_package(OpenCV 4 REQUIRED)
    message(WARNING "OpenCV 4 Support is experimental, use at your own risk!")
endif()

include(FetchContent)
FetchContent_Declare(json URL https://github.com/nlohmann/json/releases/download/v3.12.0/json.tar.xz)
FetchContent_MakeAvailable(json)

# find_package(nlohmann_json 3.12.0 REQUIRED) # NOTE: we do not need this if fetch
# find_package(GDAL REQUIRED)
# find_package(Boost REQUIRED COMPONENTS filesystem)
# find_package(Eigen3 REQUIRED NO_MODULE)

add_library(${MODULE_NAME} SHARED
    src/dummy_referencer.cpp
    src/geometric_referencer.cpp
    src/open_vslam.cpp
    # src/orb_slam.cpp
    # src/ov2_slam.cpp
    src/visual_slam_factory.cpp
    src/visual_slam_settings_factory.cpp
)

target_link_libraries(${MODULE_NAME}
    PUBLIC
    core
    io
    opencv_core
    nlohmann_json::nlohmann_json
    # ${GDAL_LIBRARY}
    # ${Boost_LIBRARIES}
    # Eigen3::Eigen
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
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/dummy_referencer.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/geometric_referencer.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/geospatial_referencer_IF.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/open_vslam.h
    # ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/orb_slam.h
    # ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/ov2_slam.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/visual_slam_IF.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/visual_slam_factory.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/visual_slam_settings.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}/${MODULE_NAME}/visual_slam_settings_factory.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/${MODULE_NAME}
)
