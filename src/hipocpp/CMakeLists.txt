cmake_minimum_required(VERSION 3.5)

set(CMAKE_CXX_FLAGS "${ROOT_CXX_FLAGS}")

find_package(LZ4 REQUIRED)
add_definitions(-D__LZ4__)

add_library(hipocpp SHARED
  src/data.cpp
  src/dictionary.cpp
  src/event.cpp
  src/node.cpp
  src/reader.cpp
  src/record.cpp
  src/text.cpp
  src/utils.cpp
  src/wrapper.cpp
  src/writer.cpp
  )


target_link_libraries(hipocpp
  PUBLIC ${LZ4_LIBRARY}
  )

target_include_directories(hipocpp
  PRIVATE include)

install(TARGETS hipocpp
  EXPORT HipoToolsTargets
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include/hipocpp
    )


install(
    DIRECTORY
    include/hipo
    DESTINATION
    include
    FILES_MATCHING
    PATTERN "*.h"
)

configure_file(hipocpp.pc.in hipocpp.pc @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/src/hipocpp/hipocpp.pc DESTINATION share/pkgconfig)
