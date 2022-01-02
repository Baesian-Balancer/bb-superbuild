# Core
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
find_or_build_package(mpi_cmake_modules)
find_or_build_package(real_time_tools)
find_or_build_package(signal_handler)
find_or_build_package(shared_memory)
find_or_build_package(time_series)

if(OPENSIM2REAL_ENABLE_MONOPODSDK OR OPENSIM2REAL_ENABLE_ALL)
  find_or_build_package(monopod_sdk)
endif()

# Robot scenario packages
if(OPENSIM2REAL_ENABLE_SCENARIO OR OPENSIM2REAL_ENABLE_ALL)
  if(OPENSIM2REAL_USES_PYTHON)
    # For iDynTree linking
    find_package(Python3 COMPONENTS Interpreter Development REQUIRED)
    find_package(SWIG 4.0 QUIET)

    execute_process(COMMAND ${Python3_EXECUTABLE} -c "from distutils import sysconfig; \
       print(sysconfig.get_python_lib(1,0,prefix=''))"
       OUTPUT_VARIABLE _PYTHON_INSTDIR)
    string(STRIP ${_PYTHON_INSTDIR} IDYNTREE_PYTHON_INSTALL_DIR)
    file(TO_CMAKE_PATH "${IDYNTREE_PYTHON_INSTALL_DIR}" IDYNTREE_PYTHON_INSTALL_DIR)
    set(IDYNTREE_PYTHON_INSTALL_DIR_SETUP_SH ${IDYNTREE_PYTHON_INSTALL_DIR})
    message(STATUS "IDYNTREE_PYTHON_INSTALL_DIR_SETUP_SH: ${IDYNTREE_PYTHON_INSTALL_DIR_SETUP_SH}")# If scenario is enabled. make sure gym ignition and scenario are uninstalled

    set(PYTHONPATHS "${YCM_EP_INSTALL_DIR}/${OPENSIM2REAL_SUPERBUILD_PYTHON_INSTALL_DIR_SETUP_SH}:\
    ${YCM_EP_INSTALL_DIR}/${IDYNTREE_PYTHON_INSTALL_DIR_SETUP_SH}")
    # Make sure gym-ignition and scenario is uninstalled before running
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${PYTHONPATHS} "${Python3_EXECUTABLE}" -c "import sys; \
        import os; import importlib.util; PYPATHS = [] if 'PYTHONPATH' not in os.environ else os.environ['PYTHONPATH'].split(':'); \
        sys.path = [p for p in sys.path if p not in [os.path.abspath(x) for x in PYPATHS]]; \
        print(importlib.util.find_spec('idyntree'))"
        OUTPUT_VARIABLE idyntree_OUT_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    # Make sure Scenario is uninstalled before Runinng
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${PYTHONPATHS} "${Python3_EXECUTABLE}" -c "import sys; \
        import os; import importlib.util; PYPATHS = [] if 'PYTHONPATH' not in os.environ else os.environ['PYTHONPATH'].split(':'); \
        sys.path = [p for p in sys.path if p not in [os.path.abspath(x) for x in PYPATHS]]; \
        print(importlib.util.find_spec('scenario'))"
        OUTPUT_VARIABLE Scenario_OUT_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    # Make sure gym-ignition and scenario is uninstalled before running
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${PYTHONPATHS} "${Python3_EXECUTABLE}" -c "import sys; \
        import os; import importlib.util; PYPATHS = [] if 'PYTHONPATH' not in os.environ else os.environ['PYTHONPATH'].split(':'); \
        sys.path = [p for p in sys.path if p not in [os.path.abspath(x) for x in PYPATHS]]; \
        print(importlib.util.find_spec('gym_ignition'))"
        OUTPUT_VARIABLE gym_ignition_OUT_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    if (NOT "${gym_ignition_OUT_PATH}" STREQUAL "None" )
      message(FATAL_ERROR
      "
      unexpected: Found gym-ignition python package already installed at ${gym_ignition_OUT_PATH} \
      despite having Scenario enabled. Please uninstall and try again.
      ")
    endif()
    if (NOT "${Scenario_OUT_PATH}" STREQUAL "None" )
      message(FATAL_ERROR
      "
      unexpected: Found scenario python package already installed at ${Scenario_OUT_PATH} \
      despite having Scenario enabled. Please uninstall and try again.
      ")
    endif()
    if (NOT "${idyntree_OUT_PATH}" STREQUAL "None" )
      message(FATAL_ERROR
      "
      unexpected: Found idyntree python package already installed at ${idyntree_OUT_PATH} \
      despite having Scenario enabled. Please uninstall and try again.
      ")
    endif()
  endif()
  find_or_build_package(iDynTree)
  find_or_build_package(gym-ignition)
  find_or_build_package(scenario_monopod)
  if(OPENSIM2REAL_USES_PYTHON)
    # Install the egg-info files
    # iDynTree
    set(EGG_BASE_PATH_IDYNTREE "${YCM_EP_INSTALL_DIR}/${IDYNTREE_PYTHON_INSTALL_DIR_SETUP_SH}")
    message(STATUS "Using \'${Python3_EXECUTABLE} setup.py egg_info --egg-base=${EGG_BASE_PATH_IDYNTREE}\' To create each egg info for idyntree python modules.")
    add_custom_command(TARGET iDynTree POST_BUILD
        COMMAND ${Python3_EXECUTABLE} setup.py egg_info --egg-base=${EGG_BASE_PATH_IDYNTREE}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/src/iDynTree
        COMMENT "Installing egg files for idyntree..."
    )

    # Scenario
    set(EGG_BASE_PATH_SCENARIO "${YCM_EP_INSTALL_DIR}/${OPENSIM2REAL_SUPERBUILD_PYTHON_INSTALL_DIR_SETUP_SH}")
    message(STATUS "Using \'${Python3_EXECUTABLE} setup.py egg_info --egg-base=${EGG_BASE_PATH_SCENARIO}\' \
    To create each egg info for python modules sceanrio and gym-ignition.")
    add_custom_command(TARGET gym-ignition POST_BUILD
        COMMAND  ${CMAKE_COMMAND} -E env PYTHONPATH=${PYTHONPATHS} ${Python3_EXECUTABLE} setup.py egg_info --egg-base=${EGG_BASE_PATH_SCENARIO}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/src/gym-ignition/scenario
        COMMENT "Installing egg files for scenario..."
    )

    if(OPENSIM2REAL_ENABLE_GYMIGNITION OR OPENSIM2REAL_ENABLE_ALL)
      # gym_ignition
      add_custom_command(TARGET gym-ignition POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${PROJECT_SOURCE_DIR}/src/gym-ignition/python/gym_ignition ${EGG_BASE_PATH_SCENARIO}/gym_ignition
        COMMENT "Moving gym-ignition into build python directory ${EGG_BASE_PATH_SCENARIO}...")

      add_custom_command(TARGET gym-ignition POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${PYTHONPATHS} ${Python3_EXECUTABLE}
        setup.py egg_info --egg-base=${EGG_BASE_PATH_SCENARIO}
        # COMMAND ${Python3_EXECUTABLE} -m pip install -e .
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/src/gym-ignition
        COMMENT "Installing egg files for gym-ignition..."
      )
    endif()
  endif()
endif()