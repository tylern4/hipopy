cmake_minimum_required(VERSION 3.5)

set(CMAKE_CXX_FLAGS "${ROOT_CXX_FLAGS}")

find_package(LZ4 REQUIRED)
add_definitions(-D__LZ4__)

add_library(hipocpp4 SHARED
  src/bank.cpp
  src/dictionary.cpp
  src/event.cpp
  src/reader.cpp
  src/record.cpp
  src/recordbuilder.cpp
  src/utils.cpp
  )


target_link_libraries(hipocpp4
  PUBLIC ${LZ4_LIBRARY}
  )

target_include_directories(hipocpp4
  PRIVATE include)

install(TARGETS hipocpp4
  EXPORT HipoToolsTargets
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include/hipocpp4
    )


install(
    DIRECTORY
    include/hipo
    DESTINATION
    include
    FILES_MATCHING
    PATTERN "*.h"
)

configure_file(hipocpp.pc.in hipocpp4.pc @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/src/hipocpp4/hipocpp4.pc DESTINATION share/pkgconfig)
