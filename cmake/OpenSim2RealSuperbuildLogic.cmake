# Check the environment and make sure stuff is uninstalled
if(OPENSIM2REAL_USES_PYTHON)
  include(check_python_environment)
endif()

# Check that ignition is installed if simulator is enabled
IF(OPENSIM2REAL_ENABLE_SIMULATION)
  include(check_for_ignition)
ENDIF()

# Setup the python paths for consistency of package installation.
if(OPENSIM2REAL_USES_PYTHON)
  # For iDynTree linking
  find_package(Python3 COMPONENTS Interpreter REQUIRED)

  # For other packages installation
  set(_python_code
    "from distutils.sysconfig import get_python_lib"
    "import os"
    "install_path = '${YCM_EP_INSTALL_DIR}'"
    "python_lib = get_python_lib(prefix=install_path)"
    "rel_path = os.path.relpath(python_lib, start=install_path)"
    "print(rel_path.replace(os.sep, '/'))")
  execute_process(
    COMMAND "${Python3_EXECUTABLE}" "-c" "${_python_code}"
    OUTPUT_VARIABLE _output
    RESULT_VARIABLE _result
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT _result EQUAL 0)
    message(
      FATAL_ERROR
        "execute_process(${Python_EXECUTABLE} -c '${_python_code}') returned "
        "error code ${_result}")
  endif()
  string(STRIP ${_output} OPENSIM2REAL_SUPERBUILD_PYTHON_INSTALL_DIR)
  file(TO_CMAKE_PATH "${OPENSIM2REAL_SUPERBUILD_PYTHON_INSTALL_DIR}" OPENSIM2REAL_SUPERBUILD_PYTHON_INSTALL_DIR)
  set(OPENSIM2REAL_SUPERBUILD_PYTHON_INSTALL_DIR_SETUP_SH ${OPENSIM2REAL_SUPERBUILD_PYTHON_INSTALL_DIR})
  message(STATUS "OPENSIM2REAL_SUPERBUILD_PYTHON_INSTALL_DIR_SETUP_SH: ${OPENSIM2REAL_SUPERBUILD_PYTHON_INSTALL_DIR_SETUP_SH}")
endif()

# Core dependencies for monopod_sdk
IF(OPENSIM2REAL_ENABLE_CORE)
  find_or_build_package(mpi_cmake_modules)
  find_or_build_package(real_time_tools)
  find_or_build_package(signal_handler)
  find_or_build_package(shared_memory)
  find_or_build_package(time_series)
ENDIF()

if(OPENSIM2REAL_ENABLE_MONOPODSDK)
  find_or_build_package(monopod_sdk)
endif()

IF(OPENSIM2REAL_ENABLE_SCENARIO)
  find_or_build_package(gym-ignition)
ENDIF()

IF(OPENSIM2REAL_ENABLE_SCENARIO_MONOPOD)
  find_or_build_package(scenario_monopod)
ENDIF()

if(OPENSIM2REAL_USES_PYTHON)
  include(Installpython_packages)
endif()

IF(OPENSIM2REAL_ENABLE_BUILDDOCS)
    find_or_build_package(hardware-documentation)
ENDIF()
