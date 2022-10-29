cmake_minimum_required(VERSION 3.20)

# set the project name 
project(libcutils) 
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_STANDARD 17)
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/../lib)

# aux_source_directory(. ALL_SRCS)
# add the executable 
ADD_LIBRARY(cutils STATIC 
    android_get_control_file.cpp
        config_utils.cpp
        canned_fs_config.cpp
        iosched_policy.cpp
        native_handle.cpp
        record_stream.cpp
        ashmem-host.cpp
        trace-host.cpp
        socket_inaddr_any_server_unix.cpp
        socket_local_client_unix.cpp
        socket_local_server_unix.cpp
        socket_network_client_unix.cpp
        sockets_unix.cpp
        sockets.cpp
        fs_config.cpp
)


include_directories(
        include
        ../libbase/include
        ../liblog/include
)
