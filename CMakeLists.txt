cmake_minimum_required(VERSION 3.30)
project(FFReadWriter VERSION 0.0.1)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
    message(WARNING "NOT SET CMAKE_BUILD_TYPE")
    set(CMAKE_BUILD_TYPE "Release")
endif()

# 添加你的源文件
aux_source_directory(./Sources/FFReadWriter SRC_LIST)

option(BUILD_SHARED_LIBS "Build using shared libraries" ON)
if(BUILD_SHARED_LIBS)
    add_library(FFReadWriter SHARED ${SRC_LIST})
else()
    add_library(FFReadWriter STATIC ${SRC_LIST})
endif()
message("Build using shared libraries: ${BUILD_SHARED_LIBS}")
# 设置库输出路径
set_target_properties(FFReadWriter PROPERTIES RUNTIME_OUTPUT_DIRECTORY ../lib)

target_link_libraries(FFReadWriter PRIVATE
    iconv
    z
    bz2
    "-framework AVFoundation"
    "-framework CoreVideo"
    "-framework CoreMedia"
    "-framework CoreAudio"
    "-framework VideoToolbox"
    "-framework AudioToolbox"
    "-framework VideoDecodeAcceleration"
    "-framework Security"
) 

target_compile_options(FFReadWriter PRIVATE -fobjc-arc)

# 设置库搜索路径
target_link_directories(FFReadWriter PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/Sources/FFReadWriter/ffmpeg-sdk-osx/lib
)

target_link_libraries(FFReadWriter PRIVATE 
    libavcodec.a
    libavdevice.a
    libavfilter.a
    libavformat.a
    libavutil.a
    libpostproc.a
    libswresample.a
    libswscale.a
    libx264.a
)

target_include_directories(FFReadWriter PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/Sources/FFReadWriter/ffmpeg-sdk-osx/include
    ${CMAKE_CURRENT_SOURCE_DIR}/Sources/include
    ${CMAKE_CURRENT_SOURCE_DIR}/Sources/FFReadWriter
)

# 设置动态库输出路径
set_target_properties(FFReadWriter PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lib
)

if(BUILD_SHARED_LIBS)
    # 添加一个构建后步骤，复制头文件
    add_custom_command(TARGET FFReadWriter POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_CURRENT_SOURCE_DIR}/Sources/include/
        ${CMAKE_CURRENT_SOURCE_DIR}/lib/FFReadWriter.framework/Headers)

    add_custom_command(TARGET FFReadWriter POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/Sources/Modules/module.modulemap
        ${CMAKE_CURRENT_SOURCE_DIR}/lib/FFReadWriter.framework/Modules/module.modulemap)

    #设置为Framework
    set_target_properties(FFReadWriter PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION A
        MACOSX_FRAMEWORK_IDENTIFIER com.liuxu.FFReadWriter
        MACOSX_FRAMEWORK_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
    )
endif()

# rm -rf ./build && rm -rf ./lib && cmake -S . -B ./build -GNinja -DCMAKE_BUILD_TYPE='Debug' &&  cmake --build ./build
