
if(TOOLCHAIN_DIR)
	message(STATUS "User provided toolchain directory: " ${TOOLCHAIN_DIR})
else()
	if(DEFINED SOS_SDK_PATH)
		set(TOOLCHAIN_DIR ${SOS_SDK_PATH}/Tools/gcc)
		message(STATUS "Using SOS_SDK_PATH defined toolchain directory " ${TOOLCHAIN_DIR})
	elseif(DEFINED ENV{SOS_SDK_PATH})
		set(TOOLCHAIN_DIR $ENV{SOS_SDK_PATH}/Tools/gcc)
		set(SOS_SDK_PATH $ENV{SOS_SDK_PATH})
		message(STATUS "Using environment defined toolchain directory " ${TOOLCHAIN_DIR})
	else()
		set(TOOLCHAIN_DIR "/Applications/StratifyLabs-SDK/Tools/gcc")
		message(STATUS "MacOS provided toolchain directory " ${TOOLCHAIN_DIR})
		set(TOOLCHAIN_EXEC_SUFFIX "")
	endif()
endif()

set(TOOLCHAIN_LIB_DIR "${TOOLCHAIN_DIR}/lib" CACHE INTERNAL "GCC TOOLCHAIN LIBRARY DIR")
set(SOS_SDK_LIB_DIR "${TOOLCHAIN_DIR}/lib")

message(STATUS "Use Clang toolchain install dir: " ${TOOLCHAIN_DIR})
set(CMAKE_INSTALL_PREFIX ${TOOLCHAIN_DIR} CACHE INTERNAL "CLANG INSTALL PREFIX")
include_directories(SYSTEM ${TOOLCHAIN_DIR}/include)

set(TOOLCHAIN_C_FLAGS "-m64 -arch x86_64 -mmacosx-version-min=10.9 -D__macosx -D__processor_${CMAKE_HOST_SYSTEM_PROCESSOR}" CACHE INTERNAL "CLANG C FLAGS")
set(TOOLCHAIN_CXX_FLAGS "${TOOLCHAIN_C_FLAGS} -std=c++11" CACHE INTERNAL "CLANG CXX FLAGS")

set(CMAKE_C_FLAGS "${TOOLCHAIN_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${TOOLCHAIN_CXX_FLAGS}")

set(CMAKE_C_COMPILER clang CACHE INTERNAL "CLANG TOOLCHAIN C COMPILER")
set(CMAKE_CXX_COMPILER clang++ CACHE INTERNAL "CLANG TOOLCHAIN C++ COMPILER")
