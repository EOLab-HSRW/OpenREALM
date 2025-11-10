cmake_minimum_required(VERSION 3.18)

set(MODULE_NAME ortho)

find_package(OpenCV 3.3.1 EXACT QUIET)
if (NOT OpenCV_FOUND)
    find_package(OpenCV 3 QUIET)
endif()
if (NOT OpenCV_FOUND)
    find_package(OpenCV 4 REQUIRED)
    message(WARNING "OpenCV 4 Support is experimental, use at your own risk!")
endif()
find_package(GDAL REQUIRED)
find_package(Boost REQUIRED COMPONENTS filesystem)
find_package(Eigen3 REQUIRED NO_MODULE)

add_library(${MODULE_NAME} SHARED
    src/delaunay_2d.cpp
    src/dsm.cpp
    src/gdal_warper.cpp
    src/map_tiler.cpp
    src/rectification.cpp
    src/tile.cpp
    src/tile_cache.cpp
)

target_link_libraries(${MODULE_NAME}
    PUBLIC
    core
    io
    opencv_core
    GDAL::GDAL
    ${Boost_LIBRARIES}
    Eigen3::Eigen
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
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/delaunay_2d.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/dsm.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/gdal_warper.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/map_tiler.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/nanoflann.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/nearest_neighbor.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/rectification.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/tile.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${MODULE_NAME}/tile_cache.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/${MODULE_NAME}
)
