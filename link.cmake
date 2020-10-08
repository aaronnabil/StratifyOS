
# Globs - these don't affect the build
file(GLOB_RECURSE CMAKE_SOURCES ${CMAKE_SOURCE_DIR}/cmake/*)

#Add sources to the project
sos_sdk_add_subdirectory(SOS_INTERFACE_SOURCELIST ${CMAKE_SOURCE_DIR}/include)
sos_sdk_add_subdirectory(SOS_SOURCELIST ${CMAKE_SOURCE_DIR}/src)


set(SOS_ARCH link)

sos_sdk_library_target(BUILD_RELEASE StratifyOS "" release link)

add_library(${BUILD_RELEASE_TARGET} STATIC)
target_sources(${BUILD_RELEASE_TARGET}
	PUBLIC
	${SOS_INTERFACE_SOURCELIST}
	PRIVATE
	${SOS_SOURCELIST}
	${CMAKE_SOURCES}
	)

target_include_directories(${BUILD_RELEASE_TARGET}
	PRIVATE
	${CMAKE_SOURCE_DIR}/include
	)

sos_sdk_library("${BUILD_RELEASE_OPTIONS}")

install(FILES include/mcu/types.h DESTINATION include/mcu)
install(FILES include/mcu/mcu.h DESTINATION include/mcu)
install(DIRECTORY include/sos DESTINATION include PATTERN CMakelists.txt EXCLUDE)

option(SOS_SKIP_CMAKE "Don't install the cmake files" OFF)

if(NOT SOS_SKIP_CMAKE)
	install(DIRECTORY cmake/ DESTINATION cmake)
endif()
