cmake_minimum_required(VERSION 3.5)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(clas12tool SHARED
  src/clas12event.cpp
  src/detector.cpp
  src/header.cpp
  src/particle.cpp
  src/vectors.cpp
  )

target_include_directories(clas12tool
  PRIVATE include)

target_link_libraries(clas12tool
  PUBLIC hipocpp
  )

install(TARGETS clas12tool
    EXPORT Clas12ToolsTargets
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include/clas12tool
    )


install(
    DIRECTORY
    include/clas12tool
    DESTINATION
    include
    FILES_MATCHING
    PATTERN "*.h"
)

configure_file(clas12tool.pc.in clas12tool.pc @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/src/clas12tool/clas12tool.pc DESTINATION share/pkgconfig)
