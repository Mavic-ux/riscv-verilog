cmake_minimum_required(VERSION 3.10)
project(riscv-verilog)

find_package(verilator HINTS $ENV{VERILATOR_ROOT})

set(TARGET sim)
add_executable(${TARGET} main.cpp)

verilate(${TARGET} SOURCES top.v VERILATOR_ARGS --trace) 

message(CMAKE_CURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

target_include_directories(${TARGET} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../ELFIO)
