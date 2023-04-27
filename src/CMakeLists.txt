cmake_minimum_required(VERSION 3.10)
project(riscv-verilog)

find_package(verilator HINTS $ENV{VERILATOR_ROOT})

add_executable(sim main.cpp)

verilate(sim SOURCES cpu.v VERILATOR_ARGS --trace)

target_include_directories(sim PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../CLI11)
target_include_directories(sim PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../ELFIO)
