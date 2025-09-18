cmake_minimum_required(VERSION 3.2)
project(mm_cam)

message(STATUS "Searching required modules")
find_package(PkgConfig REQUIRED)
# FFMPEG
pkg_check_modules(avcodec libavcodec REQUIRED)
pkg_check_modules(avutil libavutil REQUIRED)
pkg_check_modules(swscale libswscale REQUIRED)
pkg_check_modules(video4linux libv4l2 REQUIRED)
# OPENCV
find_package(OpenCV REQUIRED)

# Reporting
if(avcodec_FOUND)
  message(STATUS "Found libavcodec: ${avcodec_VERSION}")
endif()
if(avutil_FOUND)
  message(STATUS "Found libavutil: ${avutil_VERSION}")
endif()
if(swscale_FOUND)
  message(STATUS "Found libswscale: ${swscale_VERSION}")
endif()
if(OpenCV_FOUND)
  message(STATUS "Found OpenCV: ${OpenCV_VERSION}")
endif()
if(video4linux_FOUND)
  message(STATUS "Found Video4Linux kernel library: ${video4linux_VERSION}")
endif()

# Catkin
find_package(catkin REQUIRED COMPONENTS
  cv_bridge
  image_transport
  roscpp
  std_msgs
  std_srvs
  sensor_msgs
  camera_info_manager
)

catkin_package(
  INCLUDE_DIRS include
  LIBRARIES usb_cam
)

option(SUPPRESS_BIND_GLOBAL_PLACEHOLDERS
  "Suppresses Boost >= 1.68 deprecation warning message for global placeholders in boost::bind instantiation"
  ON
)

if("$ENV{ROS_DISTRO}" STRGREATER "melodic")
  if(SUPPRESS_BIND_GLOBAL_PLACEHOLDERS)
    add_compile_definitions(BOOST_BIND_GLOBAL_PLACEHOLDERS)
  endif()
endif()

include_directories(
  include
  ${catkin_INCLUDE_DIRS}
)

link_directories(
  ${video4linux_LIBRARY_DIRS}
  ${avcodec_LIBRARY_DIRS}
  ${avutil_LIBRARY_DIRS}
  ${swscale_LIBRARY_DIRS}
)

# V4L2 Driver Library
set(v4l_driver_SHARED_HEADERS
  include/usb_cam/types.h
  include/usb_cam/util.h
  include/usb_cam/converters.h
  include/usb_cam/camera_driver.h
)

add_library(v4l_driver
  ${v4l_driver_SHARED_HEADERS}
  src/util.cpp
  src/converters.cpp
  src/camera_driver.cpp
)

target_include_directories(v4l_driver PUBLIC
  ${video4linux_INCLUDE_DIRS}
  ${avcodec_INCLUDE_DIRS}
  ${swscale_INCLUDE_DIRS}
  ${avutil_INCLUDE_DIRS}
  ${OpenCV_INCLUDE_DIRS}
)

target_link_libraries(v4l_driver
  ${video4linux_LIBRARIES}
  ${avcodec_LIBRARIES}
  ${avutil_LIBRARIES}
  ${swscale_LIBRARIES}
  ${OpenCV_LIBS}
)

# usb_cam Library
set(usb_cam_SHARED_HEADERS
  include/usb_cam/usb_cam.h
)

add_library(usb_cam
  ${usb_cam_SHARED_HEADERS}
  src/usb_cam.cpp
)

target_link_libraries(usb_cam
  ${catkin_LIBRARIES}
  v4l_driver
)

# Executable
add_executable(mm_cam_node
  src/usb_cam_node.cpp
)

target_link_libraries(mm_cam_node
  usb_cam
  ${catkin_LIBRARIES}
)

# Install targets
install(TARGETS
  mm_cam_node
  usb_cam
  v4l_driver
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
  LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
)

# Install launch
install(DIRECTORY launch/
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/launch
  FILES_MATCHING PATTERN "*.launch"
)

# Install headers
install(DIRECTORY include/${PROJECT_NAME}/
  DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
  FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
)

