# CMakeLists.txt for Native EXIF Parser Module
# HarmonyOS NEXT API 20+

cmake_minimum_required(VERSION 3.16)
project(exif_parser)

# 设置C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置编译选项
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -O2")

# HarmonyOS NDK头文件路径
include_directories(${NATIVERENDER_ROOT_PATH}/include)

# 源文件列表（只包含C++源文件）
set(SOURCE_FILES
    exif_parser.cpp
    napi_init.cpp
)

# 添加动态库目标
add_library(exifparser SHARED ${SOURCE_FILES})

# 链接系统库
target_link_libraries(exifparser PUBLIC
    libace_napi.z.so
    libhilog_ndk.z.so
)

# 设置输出名称
set_target_properties(exifparser PROPERTIES
    OUTPUT_NAME "exifparser"
)
