cmake_minimum_required(VERSION 3.18)

add_subdirectory(densifier_base)

# find_package(CUDAToolkit QUIET)
#
# if (CUDAToolkit_FOUND)
#     enable_language(CUDA)
#     add_subdirectory(densifier_impl/PlaneSweepLib/)
# else()
#     message(WARNING "CUDA Toolkint not found. Skiping PlaneSweepLib module")
# endif()
#
