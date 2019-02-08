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

include_directories(src/hipocpp3/include)
add_subdirectory(src/hipocpp3)

include_directories(src/hipocpp4/include)
add_subdirectory(src/hipocpp4)

find_package(PythonInterp)
find_package(PythonLibs)
find_package(PythonExtensions)
find_package(Cython REQUIRED)

set(CMAKE_CXX_FLAGS "${ROOT_CXX_FLAGS}")
find_package(LZ4 REQUIRED)
add_definitions(-D__LZ4__)

add_cython_target(hipopy3 hipopy3.pyx CXX PY3 OUTPUT_VAR _hipopy3)
include_directories(${PYTHON_INCLUDE_DIRS})
set(EXTRA_FLAGS "-D__LZ4__ -pthread -m64")
set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} ${EXTRA_FLAGS}" )
add_library(hipopy3 MODULE ${_hipopy3})
python_extension_module(hipopy3)
target_link_libraries(hipopy3 hipocpp3 ${LZ4_LIBRARY} ${PYTHON_LIBRARIES} ${ROOT_LIBRARIES})
install(TARGETS hipopy3
        LIBRARY DESTINATION lib)


add_cython_target(hipopy4 hipopy4.pyx CXX PY3 OUTPUT_VAR _hipopy4)
include_directories(${PYTHON_INCLUDE_DIRS})
set(EXTRA_FLAGS "-D__LZ4__ -pthread -m64")
set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} ${EXTRA_FLAGS}" )
add_library(hipopy4 MODULE ${_hipopy4})
python_extension_module(hipopy4)
target_link_libraries(hipopy4 hipocpp4 ${LZ4_LIBRARY} ${PYTHON_LIBRARIES} ${ROOT_LIBRARIES})
install(TARGETS hipopy4
        LIBRARY DESTINATION lib)
