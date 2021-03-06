cmake_minimum_required(VERSION 3.14)
if(NOT ZITI_SDK_C_BRANCH)
    #allow using a different branch of the CSDK easily
    set(ZITI_SDK_C_BRANCH "0.20.21")
endif()

execute_process(
        COMMAND git describe --tags --dirty=-local
        OUTPUT_VARIABLE GIT_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REGEX MATCH "([0-9]+\\.[0-9]+\\.[0-9]+)" ver "${GIT_VERSION}")

project(ziti-tunnel-sdk-c
        VERSION "${ver}"
        LANGUAGES C CXX)
include(CPack)
set(CPACK_PACKAGE_VENDOR "NetFoundry")

add_compile_options(-g)

add_custom_target(bundle
        COMMENT "creates publishable artifacts")

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/bundle)

macro(BUNDLE_COMP comp)
    add_custom_target(${comp}-bundle
            BYPRODUCTS ${CMAKE_BINARY_DIR}/bundle/${comp}-${CPACK_SYSTEM_NAME}_${CMAKE_SYSTEM_PROCESSOR}.zip
            DEPENDS ${comp}
            COMMAND zip ${CMAKE_BINARY_DIR}/bundle/${comp}-${CPACK_SYSTEM_NAME}_${CMAKE_SYSTEM_PROCESSOR}.zip ${comp}
            )
    add_dependencies(bundle ${comp}-bundle)
endmacro()

message("project version: ${PROJECT_VERSION} (git version ${GIT_VERSION})")
message("cross-compiling: ${CMAKE_CROSSCOMPILING}")

link_directories(${CMAKE_BINARY_DIR}/lib)

add_subdirectory(deps)
add_subdirectory(lib)
add_subdirectory(programs)

if (WIN32)
set(CMAKE_INSTALL_LIBDIR lib)
set(CMAKE_INSTALL_INCLUDEDIR include)
endif()

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(TARGETS lwipcore ziti-tunnel-sdk-c ziti-tunnel-cbs-c
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        )

# lwip macro defaults. override on command line or in parent cmakelists.
set(LWIP_MEM_SIZE 524288 CACHE STRING "LWIP MEM_SIZE option")
set(LWIP_PBUF_POOL_SIZE 512 CACHE STRING "LWIP PBUF_POOL_SIZE option")
set(UDP_MAX_CONNECTIONS 64 CACHE STRING "LWIP MEMP_NUM_UDP_PCB option")
set(TCP_MAX_QUEUED_SEGMENTS 1024 CACHE STRING "LWIP MEMP_NUM_TCP_SEG option")
set(TCP_MAX_CONNECTIONS 256 CACHE STRING "LWIP MEMP_NUM_TCP_PCB option")

target_compile_definitions(lwipcore
    PUBLIC MEM_SIZE=${LWIP_MEM_SIZE}
    PUBLIC PBUF_POOL_SIZE=${LWIP_PBUF_POOL_SIZE}
    PUBLIC MEMP_NUM_TCP_PCB=${TCP_MAX_CONNECTIONS}
    PUBLIC MEMP_NUM_TCP_SEG=${TCP_MAX_QUEUED_SEGMENTS}
    PUBLIC MEMP_NUM_UDP_PCB=${UDP_MAX_CONNECTIONS}
)

if(CMAKE_SYSTEM_NAME STREQUAL Darwin OR CMAKE_SYSTEM_NAME STREQUAL Linux)
install(TARGETS ziti-edge-tunnel
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        )
endif()

if (WIN32)
install(TARGETS lwipwin32arch
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        )
endif()
