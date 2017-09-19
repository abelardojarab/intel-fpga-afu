## Copyright(c) 2017, Intel Corporation
##
## Redistribution  and  use  in source  and  binary  forms,  with  or  without
## modification, are permitted provided that the following conditions are met:
##
## * Redistributions of  source code  must retain the  above copyright notice,
##   this list of conditions and the following disclaimer.
## * Redistributions in binary form must reproduce the above copyright notice,
##   this list of conditions and the following disclaimer in the documentation
##   and/or other materials provided with the distribution.
## * Neither the name  of Intel Corporation  nor the names of its contributors
##   may be used to  endorse or promote  products derived  from this  software
##   without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
## IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
## LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
## CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
## SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
## INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
## CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.

project("mpf")

cmake_minimum_required(VERSION 2.8)
set(CMAKE_VERSION_MAJOR 0)
set(CMAKE_VERSION_MINOR 0)
set(CMAKE_VERSION_PATCH 0)

find_package(Threads REQUIRED)
include(CheckIncludeFile)

if (NOT CMAKE_VERSION VERSION_LESS "3.1")
    if (NOT CMAKE_C_COMPILER_VERSION VERSION_LESS 4.7)
        # New CMake, new enough compiler, ideal case...
        set (CMAKE_C_STANDARD 11)
    else ()
        # Ideally here we would set CMAKE_C_STANDARD 99 but that isn't
        # working for our standard setup.
	if (NOT WIN32)
            set (CMAKE_C_FLAGS "--std=gnu99 ${CMAKE_C_FLAGS}")
	endif()
    endif ()
else ()
    # Old version of CMake doesn't know how to set C standard
    if (NOT CMAKE_C_COMPILER_VERSION VERSION_LESS 4.7)
        set (CMAKE_C_FLAGS "--std=gnu11 ${CMAKE_C_FLAGS}")
    else ()
        set (CMAKE_C_FLAGS "--std=gnu99 ${CMAKE_C_FLAGS}")
    endif ()
endif ()

find_package(Doxygen)
if (DOXYGEN_FOUND)
    include(doc/doxygen.cmake)
endif(DOXYGEN_FOUND)


##
## Allow specification of an alternate path to the FPGA library include files
## and binary.
##
set (FPGALIB_LIBS_PATH "")
set (FPGALIB_INC_PATH "")

if (WIN32)
    if("X$ENV{FPGALIB_ROOT}X" STREQUAL "XX")
        message(FATAL_ERROR "Must specify FPGALIB_ROOT")
    else()
        set(FPGALIB_ROOT $ENV{FPGALIB_ROOT})
    endif()

    get_filename_component(dir ${FPGALIB_ROOT} ABSOLUTE DIRECTORY)

    set(FPGALIB_LIBS_PATH ${dir}/binary/app+lib/x64)
    set(FPGALIB_INC_PATH ${dir}/headers)

    if(NOT IS_DIRECTORY ${FPGALIB_LIBS_PATH} OR NOT IS_DIRECTORY ${FPGALIB_INC_PATH}/fpga)
        message(FATAL_ERROR "Invalid FPGALIB_ROOT")
    endif()

    add_library(FpgaLib SHARED IMPORTED GLOBAL)

    set_property(TARGET FpgaLib PROPERTY IMPORTED_LOCATION_DEBUG ${FPGALIB_LIBS_PATH}/Debug/FpgaLib.dll)
    set_property(TARGET FpgaLib PROPERTY IMPORTED_IMPLIB_DEBUG ${FPGALIB_LIBS_PATH}/Debug/FpgaLib.lib)
    set_property(TARGET FpgaLib PROPERTY IMPORTED_LOCATION_RELEASE ${FPGALIB_LIBS_PATH}/Release/FpgaLib.dll)
    set_property(TARGET FpgaLib PROPERTY IMPORTED_IMPLIB_RELEASE ${FPGALIB_LIBS_PATH}/Release/FpgaLib.lib)

    include_directories(${FPGALIB_INC_PATH})
endif(WIN32)


include_directories(${CMAKE_SOURCE_DIR}/include)

find_file(FPGALIB_HDRS_PRESENT fpga/fpga.h PATHS ${FPGALIB_INC_PATH})

if (WIN32)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -wd4710 -wd4711 -wd4820 -O2")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -Od")

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Od")
else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -O2")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -O0")

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0")
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    message(FATAL_ERROR "Release mode not supported")
endif(CMAKE_BUILD_TYPE STREQUAL "Release")


##
## Build FPGA library if libfpga header files are present
##
check_include_file("fpga/fpga.h" FPGA_PRESENT)
if (FPGA_PRESENT OR FPGALIB_HDRS_PRESENT)
    include(src/mpf.cmake)
else(FPGA_PRESENT OR FPGALIB_HDRS_PRESENT)
    message("Not building ${CMAKE_SHARED_LIBRARY_PREFIX}MPF${CMAKE_SHARED_LIBRARY_SUFFIX} for ${CMAKE_SHARED_LIBRARY_PREFIX}fpga${CMAKE_SHARED_LIBRARY_SUFFIX} -- fpga/fpga.h not found")
endif(FPGA_PRESENT OR FPGALIB_HDRS_PRESENT)


##
## Build legacy AAL version of the MPF library if AAL appears to be installed.
##
check_include_file("aalsdk/AALTypes.h" AAL_PRESENT)
if (AAL_PRESENT)
    include(src_aal/mpf_aal.cmake)
else(AAL_PRESENT)
    message("Not building legacy ${CMAKE_SHARED_LIBRARY_PREFIX}MPF_AAL${CMAKE_SHARED_LIBRARY_SUFFIX} -- AAL not found")
endif(AAL_PRESENT)
