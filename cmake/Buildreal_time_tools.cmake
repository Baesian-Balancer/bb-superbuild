
include(YCMEPHelper)
include(FindOrBuildPackage)

find_or_build_package(pybind11 QUIET)
find_or_build_package(Eigen3 QUIET)
find_or_build_package(mpi_cmake_modules QUIET)

ycm_ep_helper(real_time_tools TYPE GIT
              STYLE GITHUB
              REPOSITORY machines-in-motion/real_time_tools.git
              TAG master
              COMPONENT core
              FOLDER src
              # CMAKE_ARGS -DBUILD_TESTING=OFF
              DEPENDS pybind11
                      Eigen3
                      mpi_cmake_modules)