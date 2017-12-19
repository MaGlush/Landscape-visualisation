#!/bin/bash
# очистка проекта
mkdir build
cd build
# make clean
rm -rf CMakeFiles
rm -f CMakeCache.txt Makefile cmake cmake_install.cmake
cd ..
