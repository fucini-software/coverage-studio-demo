# C++ coverage sample: build file.
# Author: Mario Fucini
# Copyright (c) 2026 Fucini Consulting. Released under the MIT License; see the
# LICENSE file in the repository root.

cmake_minimum_required(VERSION 3.16)
project(coverage_studio_demo_cpp CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build the tiny test binary. Coverage flags are added by the gen-coverage
# scripts rather than hard-coded here, as in the C sample: this file is what
# lets an IDE that reads CMake (Visual Studio's Open Folder, CLion) know the
# sources as a project, with IntelliSense and a target to run.
add_executable(gearbox src/gearbox.cpp src/gearbox_test.cpp)
enable_testing()
add_test(NAME gearbox COMMAND gearbox)