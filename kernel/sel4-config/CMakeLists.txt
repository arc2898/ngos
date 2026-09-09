cmake_minimum_required(VERSION 3.28)
project(ngos_sel4_kernel LANGUAGES C ASM)

# seL4 configuration for NGOS
set(KERNEL_PLATFORM "pc99")
set(ARCH "x86_64")
set(PLATFORM "pc99")
set(KERNEL_MAX_PRIORITY 255)
set(MAX_NUM_NODES 1)
set(ENABLE_SMP ON)
set(KERNEL_MCS ON)  # Mixed Criticality Systems scheduler

# Build type
set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type")

# Compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffreestanding -nostdlib -fno-stack-protector -mno-red-zone -mcmodel=kernel")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -fno-pie")

# seL4 source directory (vendored)
set(SEL4_SOURCE_DIR "${CMAKE_SOURCE_DIR}/../../../vendor/seL4")

# Include seL4 build system
if(EXISTS "${SEL4_SOURCE_DIR}/kernel/cmake/Toolchain.cmake")
    include("${SEL4_SOURCE_DIR}/kernel/cmake/Toolchain.cmake")
else()
    message(WARNING "seL4 source not found at ${SEL4_SOURCE_DIR}. Please vendor seL4.")
endif()

# Kernel configuration
add_definitions(
    -DCONFIG_KERNEL_MCS=1
    -DCONFIG_MAX_NUM_NODES=1
    -DCONFIG_KERNEL_MAX_PRIORITY=255
    -DCONFIG_ENABLE_SMP=1
    -DCONFIG_ARCH_X86_64=1
    -DCONFIG_PLAT_PC99=1
)

# Build seL4 kernel
add_subdirectory("${SEL4_SOURCE_DIR}/kernel" "${CMAKE_BINARY_DIR}/sel4_kernel")

# Copy kernel.elf to build directory
add_custom_command(
    OUTPUT "${CMAKE_BINARY_DIR}/kernel.elf"
    COMMAND ${CMAKE_COMMAND} -E copy
        "${CMAKE_BINARY_DIR}/sel4_kernel/kernel.elf"
        "${CMAKE_BINARY_DIR}/kernel.elf"
    DEPENDS sel4_kernel
    COMMENT "Copying seL4 kernel.elf"
)

add_custom_target(kernel_image ALL DEPENDS "${CMAKE_BINARY_DIR}/kernel.elf")