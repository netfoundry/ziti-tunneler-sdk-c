if (NOT DEFINED ENV{TOOLCHAIN})
    message(FATAL_ERROR "TOOLCHAIN environment variable is not set")
endif ()

set(triple mips-openwrt-linux)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR mips)

set(CMAKE_SYSROOT $ENV{TOOLCHAIN}/)
set(CMAKE_C_COMPILER $ENV{TOOLCHAIN}/bin/${triple}-gcc)
set(CMAKE_CXX_COMPILER $ENV{TOOLCHAIN}/bin/${triple}-g++)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)