# Optional: print out extra messages to see what is going on. Comment it to have less verbose messages
# can also make VERBOSE=1 as needed for the same output
#set(CMAKE_VERBOSE_MAKEFILE ON)

set(PI_BARE ${CMAKE_CURRENT_LIST_DIR})

# Apply the toolchain file for either 32bit or 64bit
include(CMakeForceCompiler)
if (CONFIG_AARCH STREQUAL "AARCH64")
  set(CMAKE_TOOLCHAIN_FILE ${PI_BARE}/config/toolchain-aarch64-elf-gcc.cmake CACHE STRING "Path to toolchain file" FORCE)
  set(ARCH_BOOT ${PI_BARE}/config/boot64.S)
  set(KERNEL_NAME kernel8.img)
else()
  set(CMAKE_TOOLCHAIN_FILE ${PI_BARE}/config/toolchain-arm-none-eabi-gcc.cmake CACHE STRING "Path to toolchain file" FORCE)
  set(ARCH_BOOT ${PI_BARE}/config/boot32.S)
  set(KERNEL_NAME kernel7.img)
endif()

add_library(rpibare STATIC
  ${PI_BARE}/uart.cpp
  ${PI_BARE}/printf.c
  ${PI_BARE}/kernel.cpp
  ${ARCH_BOOT}
)

add_link_options(-T${PI_BARE}/config/linker.ld)
