cmake_minimum_required(VERSION 3.5)
project(hipoio)
set(VERSION 0.0.1)

list(APPEND CMAKE_PREFIX_PATH $ENV{ROOTSYS})
message(STATUS "ROOTSYS: " $ENV{ROOTSYS})
find_package(ROOT REQUIRED COMPONENTS RIO Net)
include(${ROOT_USE_FILE})

set(CMAKE_MODULE_PATH
   ${CMAKE_MODULE_PATH}
   ${PROJECT_SOURCE_DIR}/cmake
   ${PROJECT_SOURCE_DIR}/cmake/modules)

include_directories(src/hipocpp/include)
add_subdirectory(src/hipocpp)

find_package(PythonInterp)
find_package(PythonLibs)
find_package(PythonExtensions)
find_package(Cython REQUIRED)

set(CMAKE_CXX_FLAGS "${ROOT_CXX_FLAGS}")
find_package(LZ4 REQUIRED)
add_definitions(-D__LZ4__)

add_cython_target(hipopy hipopy.pyx CXX PY3 OUTPUT_VAR _hipopy)
include_directories(${PYTHON_INCLUDE_DIRS})


set(EXTRA_FLAGS "-D__LZ4__ -pthread -m64")
set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} ${EXTRA_FLAGS}" )

add_library(hipopy MODULE ${_hipopy})
python_extension_module(hipopy)

target_link_libraries(hipopy hipocpp ${LZ4_LIBRARY} ${PYTHON_LIBRARIES} ${ROOT_LIBRARIES})

install(TARGETS hipopy
        LIBRARY DESTINATION lib)
