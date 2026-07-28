cmake_minimum_required(VERSION 3.20)

#include pi-bare, it will create an arch specific rpibare lib, link with it
include(${CMAKE_SOURCE_DIR}/../pi-bare/pi-bare.cmake)

project(kernel.elf C CXX ASM)

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)

add_executable(${PROJECT_NAME}
     main.cpp
)

target_include_directories(${PROJECT_NAME} PUBLIC 
  ${CMAKE_SOURCE_DIR}
  ${PI_BARE}
)

target_link_libraries(${PROJECT_NAME} rpibare gcc)

# Add post-build step to generate raw kernel binary file and show the size
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}> ${KERNEL_NAME}
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}>
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
