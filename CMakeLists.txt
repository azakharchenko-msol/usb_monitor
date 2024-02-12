cmake_minimum_required(VERSION  3.10) # Adjust the version according to your CMake installation
project(USBMonitor)

# Specify the C++ standard
#set(CMAKE_CXX_STANDARD  11)
#set(CMAKE_CXX_STANDARD_REQUIRED True)

# Add the executable target
add_executable(${PROJECT_NAME} usbmon.cpp)

# Link against libudev
find_library(LIBUDEV udev)
if(NOT LIBUDEV)
    message(FATAL_ERROR "libudev not found")
endif()
target_link_libraries(${PROJECT_NAME} ${LIBUDEV})
