# Copyright 2016 Proyectos y Sistemas de Mantenimiento SL (eProsima).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###############################################################################
# CMake build rules for FastRTPS
###############################################################################
cmake_minimum_required(VERSION 2.8.12)

# Set CMAKE_BUILD_TYPE to Release by default.
if(DEFINED CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING
        "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
        )
else()
    set(CMAKE_BUILD_TYPE Release CACHE STRING
        "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
        )
endif()

## lihf ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
#配置C++编译器
set(CMAKE_CXX_COMPILER /home/lihf/ant_robot/ant_robot_sdk/firefly/rk3568/crosstool/sysroots/x86_64-zxic-linux/usr/bin/aarch64-zxic-linux/aarch64-zxic-linux-g++)
#配置C编译器
set(CMAKE_C_COMPILER /home/lihf/ant_robot/ant_robot_sdk/firefly/rk3568/crosstool/sysroots/x86_64-zxic-linux/usr/bin/aarch64-zxic-linux/aarch64-zxic-linux-gcc)
#配置系统路径
set(CMAKE_SYSROOT /home/lihf/ant_robot/ant_robot_sdk/firefly/rk3568/crosstool/sysroots/aarch64-zxic-linux)
#配置库文件头文件搜索路径
set(CMAKE_FIND_ROOT_PATH  /home/lihf/ant_robot/ant_robot_sdk/firefly/rk3568/crosstool/sysroots/aarch64-zxic-linux)

SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

SET(ASIO_INCLUDE_DIR /home/lihf/ant_robot/Apollo_cyberRT/open_sources/_build/include/asio)
SET(TINYXML2_INCLUDE_DIR /home/lihf/ant_robot/Apollo_cyberRT/open_sources/_build/include)
SET(TINYXML2_LIBRARY /home/lihf/ant_robot/Apollo_cyberRT/open_sources/_build/lib/libtinyxml2.so)
SET(fastcdr_INCLUDE_DIR /home/lihf/ant_robot/Apollo_cyberRT/open_sources/_build/include/fastcdr)
SET(fastcdr_LIB_DIR /home/lihf/ant_robot/Apollo_cyberRT/open_sources/_build/lib)
##///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

project("fastrtps")
set(PROJECT_NAME_STYLED "FastRTPS")
set(PROJECT_NAME_LARGE "Fast RTPS")
string(TOUPPER "${PROJECT_NAME}" PROJECT_NAME_UPPER)
set(${PROJECT_NAME}_DESCRIPTION_SUMMARY "C++ library implementation of RTPS protocol")
set(${PROJECT_NAME}_DESCRIPTION "eProsima ${PROJECT_NAME_LARGE} library provides publication/subscription communication using RTPS protocol.")

message(STATUS "Configuring ${PROJECT_NAME_LARGE}")

###############################################################################
# Version information                                                         #
###############################################################################

#If not set, copy over product version from configure.ac
if(NOT PROJECT_MAJOR_VERSION)
    file(STRINGS
        ${PROJECT_SOURCE_DIR}/configure.ac
        PROJECT_MAJOR_VERSION_TMP
        REGEX "^m4_define\\(\\[?version_major\\]?, *\\[?[0-9]+\\]?\\)"
        )
    file(STRINGS
        ${PROJECT_SOURCE_DIR}/configure.ac
        PROJECT_MINOR_VERSION_TMP
        REGEX "^m4_define\\(\\[?version_minor\\]?, *\\[?[0-9]+\\]?\\)"
        )
    file(STRINGS
        ${PROJECT_SOURCE_DIR}/configure.ac
        PROJECT_MICRO_VERSION_TMP
        REGEX "^m4_define\\(\\[?version_micro\\]?, *\\[?[0-9]+\\]?\\)"
        )

    string(REGEX REPLACE "m4_define\\(\\[?version_major\\]?, *\\[?([0-9]+)\\]?\\)"
        "\\1"
        PROJECT_MAJOR_VERSION
        ${PROJECT_MAJOR_VERSION_TMP}
        )
    string(REGEX REPLACE "m4_define\\(\\[?version_minor\\]?, *\\[?([0-9]+)\\]?\\)"
        "\\1"
        PROJECT_MINOR_VERSION
        ${PROJECT_MINOR_VERSION_TMP}
        )
    string(REGEX REPLACE "m4_define\\(\\[?version_micro\\]?, *\\[?([0-9]+)\\]?\\)"
        "\\1"
        PROJECT_MICRO_VERSION
        ${PROJECT_MICRO_VERSION_TMP}
        )
endif()

set(PROJECT_VERSION ${PROJECT_MAJOR_VERSION}.${PROJECT_MINOR_VERSION}.${PROJECT_MICRO_VERSION})

message(STATUS "Version: ${PROJECT_VERSION}")
message(STATUS "To change de version modify the file configure.ac")

###############################################################################
# Generation of windows installers.
###############################################################################
if(WIN32)
    option(EPROSIMA_INSTALLER "Activate the creation of a build to create windows installers" OFF)
    option(EPROSIMA_INSTALLER_MINION "Informs this is part of an installer" OFF)
endif()

###############################################################################
# Warning level
###############################################################################
if(MSVC OR MSVC_IDE)
    if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
        string(REGEX REPLACE "/W[0-4]" "/W4" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
    endif()

    if(EPROSIMA_EXTRA_CMAKE_CXX_FLAGS)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${EPROSIMA_EXTRA_CMAKE_CXX_FLAGS}")
    endif()
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -pedantic -Wextra -Wno-unknown-pragmas -std=c++11")
endif()

###############################################################################
# GCC colors if using CCache
###############################################################################
if("${CMAKE_CXX_COMPILER_LAUNCHER}" STREQUAL "ccache" AND
        CMAKE_COMPILER_IS_GNUCXX AND
        CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 4,8)
    add_compile_options(-fdiagnostics-color=always)
endif()

###############################################################################
# Test system configuration
###############################################################################
include(${PROJECT_SOURCE_DIR}/cmake/dev/check_configuration.cmake)
check_stdcxx()
check_compile_feature()
check_endianness()

###############################################################################
# Check MSVC architecture
###############################################################################
if(MSVC OR MSVC_IDE)
    check_msvc_arch()
endif()

###############################################################################
# Installation paths
###############################################################################
set(BIN_INSTALL_DIR bin/ CACHE PATH "Installation directory for binaries")
set(INCLUDE_INSTALL_DIR include/ CACHE PATH "Installation directory for C++ headers")
set(LIB_INSTALL_DIR lib/ CACHE PATH "Installation directory for libraries")
set(DATA_INSTALL_DIR share/ CACHE PATH "Installation directory for data")
if(WIN32)
    set(DOC_DIR "doc")
else()
    set(DOC_DIR "${DATA_INSTALL_DIR}/doc")
endif()
set(DOC_INSTALL_DIR ${DOC_DIR} CACHE PATH "Installation directory for documentation")
if(WIN32)
    set(LICENSE_INSTALL_DIR . CACHE PATH "Installation directory for licenses")
else()
    set(LICENSE_INSTALL_DIR ${DATA_INSTALL_DIR}/${PROJECT_NAME} CACHE PATH "Installation directory for licenses")
endif()

###############################################################################
# eProsima build options
###############################################################################
option(EPROSIMA_BUILD "Activate internal building" OFF)
option(MINION "Tells if it is a subproject of a superproject" OFF)

if(EPROSIMA_INSTALLER)
    set(EPROSIMA_BUILD ON)
endif()


###############################################################################
# Internal debug messages
###############################################################################

option(INTERNAL_DEBUG "Activate developer debug messages" OFF)
if(EPROSIMA_BUILD AND NOT EPROSIMA_INSTALLER_MINION)
	set(INTERNAL_DEBUG ON)
endif()

###############################################################################
# Load CMake modules
###############################################################################
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR}/cmake/modules)


###############################################################################
# Default shared libraries
###############################################################################
# Global flag to cause add_library() to create shared libraries if on.
# If set to true, this will cause all libraries to be built shared
# unless the library was explicitly added as a static library.
option(BUILD_SHARED_LIBS "Create shared libraries by default" ON)

###############################################################################
# Load external projects.
###############################################################################
option(THIRDPARTY "Activate the use of internal thirdparties" OFF)

if(EPROSIMA_BUILD)
    set(THIRDPARTY ON)
endif()

include(${PROJECT_SOURCE_DIR}/cmake/dev/eprosima_libraries.cmake)

find_eprosima_package(fastcdr)
find_eprosima_thirdparty(Asio asio)
find_eprosima_thirdparty(TinyXML2 tinyxml2)

if(ANDROID)
    find_eprosima_thirdparty(android-ifaddrs android-ifaddrs)
endif()

###############################################################################
# Options
###############################################################################
option(SECURITY "Activate security" OFF)

if(SECURITY)
    find_package(OpenSSL REQUIRED)
endif()

###############################################################################
# Java application
###############################################################################
option(BUILD_JAVA "Activate the compilation of the Java application" OFF)

if(EPROSIMA_INSTALLER)
    set(BUILD_JAVA ON)
endif()

if(BUILD_JAVA)
    include(${PROJECT_SOURCE_DIR}/cmake/dev/java_support.cmake)

    gradle_build(${PROJECT_SOURCE_DIR}/${PROJECT_NAME}gen
        THIRDPARTY_DEPENDENCY idl
        THIRDPARTY_DEPENDENCY fastcdr
        )
endif()

###############################################################################
# Compile library.
###############################################################################
add_subdirectory(src/cpp)

###############################################################################
# Testing options
###############################################################################
option(PERFORMANCE_TESTS "Activate the building and execution of performance tests" OFF)
option(EPROSIMA_BUILD_TESTS "Activate the building and execution unit tests and integral tests" OFF)

if(EPROSIMA_BUILD AND NOT EPROSIMA_INSTALLER AND NOT EPROSIMA_INSTALLER_MINION)
    set(EPROSIMA_BUILD_TESTS ON)
endif()

###############################################################################
# Testing
###############################################################################
if(EPROSIMA_BUILD_TESTS AND NOT EPROSIMA_INSTALLER AND NOT EPROSIMA_INSTALLER_MINION)
    file(TO_CMAKE_PATH "${PROJECT_SOURCE_DIR}/valgrind.supp" MEMORYCHECK_SUPPRESSIONS_FILE)
    enable_testing()
    include(CTest)
    add_subdirectory(test)
endif()

###############################################################################
# Performance tests
###############################################################################
add_subdirectory(test/performance)

###############################################################################
# Examples
###############################################################################
option(COMPILE_EXAMPLES "Build example" OFF)

if(EPROSIMA_BUILD)
    set(COMPILE_EXAMPLES ON)
endif()

if(COMPILE_EXAMPLES)
	add_subdirectory(examples)
endif()

###############################################################################
# Documentation
###############################################################################
# Add an option to toggle the generation of the API documentation.
option(BUILD_DOCUMENTATION "Use doxygen to create product documentation" OFF)

if(EPROSIMA_INSTALLER)
    set(BUILD_DOCUMENTATION ON)
    set(DOXYGEN_SHOULD_SKIP_THIS_PUBLIC "DOXYGEN_SHOULD_SKIP_THIS_PUBLIC")
endif()

if(BUILD_DOCUMENTATION)
    find_package(Doxygen)
    if(NOT DOXYGEN_FOUND)
        message(FATAL_ERROR "doxygen is needed to build the documentation. Please install it correctly")
    endif()
    if(UNIX)
        find_program(DOXYFILE_MAKE make)
        if(DOXYFILE_MAKE)
            message(STATUS "Found Make: ${DOXYFILE_MAKE}")
        else()
            message(FATAL_ERROR "make is needed to build the documentation. Please install it correctly")
        endif()
    elseif(WIN32)
        set(DOXYFILE_MAKE make.bat)
    endif()
    find_program(WGET_EXE wget)
    if(WGET_EXE)
        message(STATUS "Found WGet: ${WGET_EXE}")
    else()
        message(FATAL_ERROR "wget is needed to build the documentation. Please install it correctly")
    endif()
    find_program(UNZIP_EXE unzip)
    if(UNZIP_EXE)
        message(STATUS "Found Unzip: ${UNZIP_EXE}")
    else()
        message(FATAL_ERROR "unzip is needed to build the documentation. Please install it correctly")
    endif()

    # Target to create documentation directories
    add_custom_target(docdirs
        COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BINARY_DIR}/doc
        COMMENT "Creating documentation directory" VERBATIM)

    ### Doxygen ########################3

    # Configure the template doxyfile for or specific project
    configure_file(doxyfile.in ${PROJECT_BINARY_DIR}/doxyfile @ONLY IMMEDIATE)
    # Add custom target to run doxygen when ever the project is build
    add_custom_target(doxygen
        COMMAND "${DOXYGEN_EXECUTABLE}" "${PROJECT_BINARY_DIR}/doxyfile"
        SOURCES "${PROJECT_BINARY_DIR}/doxyfile"
        COMMENT "Generating API documentation with doxygen" VERBATIM)

    add_dependencies(doxygen docdirs)

    ### README html ########################

    if(WIN32)
        set(README_LOCATION "${PROJECT_BINARY_DIR}/")
        set(README_LOCATION_PREFFIX "doc/")
        set(README_INSTALL_LOCATION ".")
    else()
        set(README_LOCATION "${PROJECT_BINARY_DIR}/doc/")
        set(README_INSTALL_LOCATION "${DOC_INSTALL_DIR}")
    endif()

    configure_file(doc/README.html.in ${README_LOCATION}/README.html @ONLY IMMEDIATE)

    ### ReadTheDocs ########################

    add_custom_target(readthedocs
        COMMAND "${WGET_EXE}" "https://media.readthedocs.org/htmlzip/eprosima-fast-rtps/latest/eprosima-fast-rtps.zip"
        COMMAND "${UNZIP_EXE}" "eprosima-fast-rtps.zip" -d "${PROJECT_BINARY_DIR}/doc/"
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${PROJECT_BINARY_DIR}/doc/manual"
        COMMAND ${CMAKE_COMMAND} -E rename "${PROJECT_BINARY_DIR}/doc/eprosima-fast-rtps-latest" "${PROJECT_BINARY_DIR}/doc/manual"
        COMMAND ${CMAKE_COMMAND} -E remove "eprosima-fast-rtps.zip"
        )

    add_dependencies(readthedocs docdirs)

    add_custom_target(doc ALL
        COMMENT "Generated project documentation" VERBATIM)

    add_dependencies(doc doxygen readthedocs)
endif()

###############################################################################
# Packaging
###############################################################################
# Install external eprosima libraries
install_eprosima_libraries()

# Install licenses
install(FILES ${PROJECT_SOURCE_DIR}/LICENSE
    DESTINATION ${LICENSE_INSTALL_DIR}
    COMPONENT licenses
    )
set(CPACK_COMPONENT_LICENSES_HIDDEN 1)

# Install examples
install(DIRECTORY ${PROJECT_SOURCE_DIR}/examples/C++
    DESTINATION examples/
    COMPONENT examples
    )

set(CPACK_COMPONENT_EXAMPLES_DISPLAY_NAME "Examples")
set(CPACK_COMPONENT_EXAMPLES_DESCRIPTION "eProsima ${PROJECT_NAME_LARGE} examples")

set(CPACK_COMPONENTS_ALL headers licenses examples)

if(BUILD_JAVA)
    install(FILES ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}gen/share/fastrtps/${PROJECT_NAME}gen.jar
        DESTINATION ${DATA_INSTALL_DIR}/${PROJECT_NAME}
        COMPONENT java
        )

    if(WIN32)
        install(PROGRAMS
            ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}gen/scripts/${PROJECT_NAME}gen.bat
            DESTINATION ${BIN_INSTALL_DIR}
            COMPONENT java
            )
    else()
        install(PROGRAMS
            ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}gen/scripts/${PROJECT_NAME}gen
            DESTINATION ${BIN_INSTALL_DIR}
            COMPONENT java
            )
    endif()

    ### Java component
    set(CPACK_COMPONENT_JAVA_DISPLAY_NAME "Java application")
    set(CPACK_COMPONENT_JAVA_DESCRIPTION "eProsima ${PROJECT_NAME_LARGE} generator")

    set(CPACK_COMPONENTS_ALL ${CPACK_COMPONENTS_ALL} java)
endif()

if(BUILD_DOCUMENTATION)

    # Instalation of doxygen files
    install(DIRECTORY ${PROJECT_BINARY_DIR}/doc/api_reference
        DESTINATION ${DOC_INSTALL_DIR}
        COMPONENT documentation
        )

    install(FILES "${README_LOCATION}/README.html"
        DESTINATION ${README_INSTALL_LOCATION}
        COMPONENT documentation
        )

    install(DIRECTORY ${PROJECT_BINARY_DIR}/doc/manual
        DESTINATION ${DOC_INSTALL_DIR}
        COMPONENT documentation
        )

    ### Documentation component
    set(CPACK_COMPONENT_DOCUMENTATION_DISPLAY_NAME "Documentation")
    set(CPACK_COMPONENT_DOCUMENTATION_DESCRIPTION "eProsima ${PROJECT_NAME_LARGE} documentation")

    set(CPACK_COMPONENTS_ALL ${CPACK_COMPONENTS_ALL} documentation)
endif()

if(MSVC OR MSVC_IDE)
    if(EPROSIMA_INSTALLER)
        set(CPACK_COMPONENTS_ALL ${CPACK_COMPONENTS_ALL}
            libraries_i86Win32VS2013
            libraries_x64Win64VS2013
            libraries_i86Win32VS2015
            libraries_x64Win64VS2015
            )
    else()
        set(CPACK_COMPONENTS_ALL ${CPACK_COMPONENTS_ALL} libraries_${MSVC_ARCH})
    endif()
else()
    set(CPACK_COMPONENTS_ALL ${CPACK_COMPONENTS_ALL} libraries)
endif()

include(${PROJECT_SOURCE_DIR}/cmake/packaging/eProsimaPackaging.cmake)
