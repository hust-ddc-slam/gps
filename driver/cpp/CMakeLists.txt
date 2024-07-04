
project(gps)
cmake_minimum_required(VERSION 3.0)

set(CMAKE_CXX_STANDARD 11)


include_directories(
    include
    /usr/local/include
)

add_executable(gps_node
    main.cpp
    gps.cpp
)

target_link_libraries(gps_node boost_system pthread)