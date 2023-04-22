cmake_minimum_required(VERSION 3.20)

# load cmake tools
include (cmake/tools.cmake)

# set DFP definition pack path
set (AVR_MCU "attiny104" CACHE STRING "AVR MicroController")
set (AVR_DFP_ARCHIVE_PATH "${CMAKE_CURRENT_LIST_DIR}/dfp/Atmel.ATtiny_DFP.2.0.368.atpack" CACHE PATH "Path to DFP pack archive" FORCE)
set (AVR_DFP_PATH "${CMAKE_BINARY_DIR}/DFP")

if (EXISTS ${AVR_DFP_ARCHIVE_PATH})
    message (STATUS "Loading DFP Pack at: ${AVR_DFP_ARCHIVE_PATH}" )
else()
    message (FATAL_ERROR "AVR_DFP_ARCHIVE_PATH option must be set to a valid DFP Pack path")
endif()

# if user defined dfp not missing, try to download default dfp file
if (NOT EXISTS ${CMAKE_BINARY_DIR}/DFP)
    file (ARCHIVE_EXTRACT
            INPUT ${AVR_DFP_ARCHIVE_PATH}
            DESTINATION ${AVR_DFP_PATH})
endif ()

# load avr toolchain
include (cmake/avr.toolchain.cmake)

project (rnd_buzzer CXX ASM)

append_source(src/ RND_BUZZER_SOURCE_FILES)

add_avr_executable(
        rnd_buzzer
        ${AVR_MCU}
        ${AVR_DFP_PATH}
        ${RND_BUZZER_SOURCE_FILES})

target_include_directories(
        rnd_buzzer PUBLIC
        src/)

target_compile_features(
        rnd_buzzer
        PUBLIC
        cxx_std_20)