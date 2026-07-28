#
# Toolchain file for 32bit kernel code on Rpi0-4 (Rpi5 doesn't allow 32bit kernel code so has to be 64bit)
# This is a pretty generic gcc toolchain file other than the RP specific compiler and link flags
# arm-none-eabi toolchain needs to be pathed
#
set(CMAKE_SYSTEM_NAME Generic)

if(NOT CMAKE_SYSTEM_PROCESSOR)
set(CMAKE_SYSTEM_PROCESSOR arm1176jzf-s)
endif()

set(TOOLCHAIN_PREFIX arm-none-eabi-)

# Without that flag CMake is not able to pass test compilation check (this needs cmake version >3.6)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

find_program(BINUTILS_PATH ${TOOLCHAIN_PREFIX}gcc NO_CACHE)

if (NOT BINUTILS_PATH)
    message(FATAL_ERROR "ARM GCC toolchain not found on path")
endif ()

get_filename_component(ARM_TOOLCHAIN_DIR ${BINUTILS_PATH} DIRECTORY)

set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_AR ${TOOLCHAIN_PREFIX}gcc-ar)
set(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}gcc-ranlib)
set(CMAKE_LINKER ${TOOLCHAIN_PREFIX}ld)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size)

execute_process(COMMAND ${CMAKE_C_COMPILER} -print-sysroot
    OUTPUT_VARIABLE ARM_GCC_SYSROOT OUTPUT_STRIP_TRAILING_WHITESPACE)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  #message("-- Build configuration is Debug")
  set(CMAKE_C_FLAGS "-mcpu=${CMAKE_SYSTEM_PROCESSOR} -fpic -ffreestanding -Wall -Wextra -fno-exceptions -fno-unwind-tables -O0 -DDEBUG")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
  #message("-- Build configuration is Release compiling for size")
  set(CMAKE_C_FLAGS "-mcpu=${CMAKE_SYSTEM_PROCESSOR} -fpic -ffreestanding -Wall -Wextra -fno-exceptions -fno-unwind-tables -O2")
else()
  #message("-- WARNING CMAKE_BUILD_TYPE is a custom type: '${CMAKE_BUILD_TYPE}' defaulting to debug")
  set(CMAKE_C_FLAGS "-mcpu=${CMAKE_SYSTEM_PROCESSOR} -fpic -ffreestanding -Wall -Wextra -fno-exceptions -fno-unwind-tables -O0 -DDEBUG")
endif()

#some debug prints
#message("-- BUILD TYPE: ${CMAKE_BUILD_TYPE}")
#message("-- CFLAGS: ${CMAKE_C_FLAGS}")

# C++ flags and asm flags are derived from the C flags
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -std=c++17")
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS} -x assembler-with-cpp")

# set flags for the linker (move above if they change based on debug/release)
# do not add the linker script here, it is added in the CMakeLists.txt
set(CMAKE_EXE_LINKER_FLAGS "-nostdlib -Wl,--defsym=LOADER_ADDRESS=0x8000 -lgcc")

set(CMAKE_SYSROOT ${ARM_GCC_SYSROOT})
set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_DIR})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)