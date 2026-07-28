# pi-bare

pi-bare will boot any raspi from Pi Zero to Pi4, it will not yet boot Pi5. It will build the project in 32 or 64bit mode.

The MMIO address is computed at runtime so the exact same binaries can run on multiple PIs (you still have to be careful with supported instructions)

The `kernel_init` code runs first and setup up the UART at 115200 baud and configures printf to use the uart so print support is available as soon as
`kernel_main` runs.

`MMIO_BASE` is a global that holds the MMIO base address on the current machine

`get_platform()` will return an integer identifying the pi platform

`get_midr()` will return the ARM MIDR register, it is read once at boot

pi-bare.h has a bunch of helper functions that are useful for bare metal programming but kernel init doesn't configure anything other than the uart


# 32bit
To build in 32bit mode the arm-none-eabi toolchain has to be pathed on your system.

By default instruction set for 32bit code builds is `arm1176jzf-s` (armv6) as needed by rapi zero and raspi A,B etc.  As the lowest common denominator instruction, integer code will work on all 32bit machines. Instruction compatibility is still a big problem when it comes to floating point and depending on your app it might not be possible to have a single binary that works on all. 

The cpu architecture can be changed at build time via `-DCMAKE_SYSTEM_PROCESSOR=arm1176jzf-s` for any supported processor
that can be passed `-mcpu=` on the gcc compiler command line.


# 64bit
To build in 64bit mode the aarch64-elf tool chain needs to be installed and -DCONFIG_AARCH=AARCH64 needs passing on the cmake command line. CONFIG_AARCH64 is defined at compile time for 64bit builds. 

The default 64bit build generates generic ARMv8-a code which the instruction set supported by A53 (raspi 3 and raspi zero 2) and A72 (raspi 4) and will work on any 64bit pi (pi5 is A76/ARMv8.2-a with a few features from 8.3,8,4 and 8.5, this library doesn't support raspi5 yet). The instructions et can be overridden from the cmake command line with `-DCMAKE_SYSTEM_PROCESSOR=armv8-a`

A minimal application that can be built for all raspi hardware (this is also in the folder bare-test)

```c++
#include "pi-bare.h"

void kernel_main()
{
  uint32_t platform = get_platform();
  uint32_t midr = get_midr();

  printf("Platform = %d\n",platform);
  printf("MIDR = 0x%08x\n",midr);
}
```

The cmake file to go with it:

``` cmake
cmake_minimum_required(VERSION 3.20)

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)

#include pi-bare, it will create an arch specific rpibare lib
#it will set KERNEL_NAME to either kernel7.img or kernel8.img
#it will set PI_BARE to the folder where pi-bare.cmake was included from
include(${CMAKE_SOURCE_DIR}/../pi-bare/pi-bare.cmake)


project(kernel.elf C CXX ASM)

add_executable(${PROJECT_NAME}
     main.cpp
)

#include PI_BARE path in the target includes
target_include_directories(${PROJECT_NAME} PUBLIC 
  ${CMAKE_SOURCE_DIR}
  ${PI_BARE}
)

#link with rpibare and gcc
target_link_libraries(${PROJECT_NAME} rpibare gcc)

# Add post-build step to generate raw kernel binary file and show the size
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}> ${KERNEL_NAME}
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}>
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
```

Mixing toolchain files in the same cmake project is generally a bad idea, if you want both a 32bit and 64bit build simply
build twice in different build folders.

The resulting kernel7.img or kernel8.img can be run directly on pi hardware or can be run in QEMU for testing.

qemu-system-aarch64 -M raspi4b -serial stdio -kernel kernel.elf

qemu-system-arm -M raspi2b -serial stdio -kernel kernel.elf

