# MSVC coverage sample: build file.
# Author: Mario Fucini
# Copyright (c) 2026 Fucini Consulting. Released under the MIT License; see the
# LICENSE file in the repository root.

cmake_minimum_required(VERSION 3.16)
project(coverage_studio_demo_cpp_msvc CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build the tiny test binary. This file is what lets Visual Studio's Open
# Folder know the sources as a project, with IntelliSense and a target to run.
add_executable(thermostat src/thermostat.cpp src/thermostat_test.cpp)

# What Microsoft's collector needs of a native binary: full debug information,
# and /PROFILE, without which it has nothing it may instrument. The generator
# script passes the same flags by hand.
if(MSVC)
  target_compile_options(thermostat PRIVATE /Zi /Od)
  target_link_options(thermostat PRIVATE /PROFILE /DEBUG:FULL)
endif()

enable_testing()
add_test(NAME thermostat COMMAND thermostat)
