cmake_minimum_required(VERSION 3.20)

project(Lumen
    VERSION 0.1.0
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(lumen
    compositor/main.cpp
    compositor/input/InputSubsystem.cpp
    compositor/input/InputManager.cpp
    compositor/input/Keyboard.cpp
    compositor/input/Seat.cpp
)

find_package(Threads REQUIRED)

target_link_libraries(lumen PRIVATE input udev Threads::Threads)
