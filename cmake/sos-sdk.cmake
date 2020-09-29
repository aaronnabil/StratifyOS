
if( ${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows" )
	set(CMAKE_MAKE_PROGRAM "C:/StratifyLabs-SDK/Tools/gcc/bin/make.exe" CACHE INTERNAL "Mingw generator" FORCE)
endif()


if( ${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin" )
	set(SOS_SDK_EXEC_SUFFIX "")
	set(SOS_SDK_GENERATOR "")
elseif( ${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows" )
	set(SOS_SDK_PATH_TO_MAKE "C:/StratifyLabs-SDK/Tools/gcc/bin")
	set(SOS_SDK_GENERATOR -G "MinGW Makefiles")
	set(SOS_SDK_EXEC_SUFFIX ".exe")
endif()

if( SOS_SDK_PATH_TO_CMAKE )
	set(SOS_SDK_CMAKE_EXEC ${SOS_SDK_PATH_TO_CMAKE}/cmake${SOS_SDK_EXEC_SUFFIX})
else()
	set(SOS_SDK_CMAKE_EXEC cmake${SOS_SDK_EXEC_SUFFIX})
endif()

if( SOS_SDK_PATH_TO_MAKE )
	set(SOS_SDK_MAKE_EXEC ${SOS_SDK_PATH_TO_MAKE}/make${SOS_SDK_EXEC_SUFFIX})
else()
	set(SOS_SDK_MAKE_EXEC make${SOS_SDK_EXEC_SUFFIX})
endif()

if( SOS_SDK_PATH_TO_GIT )
	set(SOS_SDK_GIT_EXEC ${SOS_SDK_PATH_TO_GIT}/git${SOS_SDK_EXEC_SUFFIX})
else()
	set(SOS_SDK_GIT_EXEC git${SOS_SDK_EXEC_SUFFIX})
endif()

function(sos_sdk_pull PROJECT_PATH)
	execute_process(COMMAND ${SOS_SDK_GIT_EXEC} pull WORKING_DIRECTORY ${PROJECT_PATH} OUTPUT_VARIABLE OUTPUT RESULT_VARIABLE RESULT)
	message(STATUS "git pull " ${PROJECT_PATH} "\n" ${OUTPUT})
	if(RESULT)
		message(FATAL_ERROR " Failed to pull " ${PROJECT_PATH})
	endif()
endfunction()

function(sos_sdk_add_subdirectory INPUT_LIST DIRECTORY)
	add_subdirectory(${DIRECTORY})
	set(INPUT_SOURCES ${${INPUT_LIST}})
	set(TEMP_SOURCES "")
	foreach(entry ${SOURCES})
		list(APPEND TEMP_SOURCES ${DIRECTORY}/${entry})
	endforeach()
	list(APPEND TEMP_SOURCES ${INPUT_SOURCES})
	set(${INPUT_LIST} ${TEMP_SOURCES} PARENT_SCOPE)
endfunction()

function(sos_sdk_add_out_of_source_directory INPUT_LIST DIRECTORY BINARY_DIRECTORY)
	add_subdirectory(${DIRECTORY} ${BINARY_DIRECTORY})
	set(INPUT_SOURCES ${${INPUT_LIST}})
	set(TEMP_SOURCES "")
	foreach(entry ${SOURCES})
		list(APPEND TEMP_SOURCES ${DIRECTORY}/${entry})
	endforeach()
	list(APPEND TEMP_SOURCES ${INPUT_SOURCES})
	set(${INPUT_LIST} ${TEMP_SOURCES} PARENT_SCOPE)
endfunction()


function(sos_sdk_git_status PROJECT_PATH)
	message(STATUS "GIT STATUS OF " ${PROJECT_PATH})
	execute_process(COMMAND ${SOS_SDK_GIT_EXEC} status WORKING_DIRECTORY ${PROJECT_PATH} RESULT_VARIABLE RESULT)
endfunction()

function(sos_sdk_clone REPO_URL WORKSPACE_PATH)
	execute_process(COMMAND ${SOS_SDK_GIT_EXEC} clone ${REPO_URL} WORKING_DIRECTORY ${WORKSPACE_PATH} OUTPUT_VARIABLE OUTPUT RESULT_VARIABLE RESULT)
	message(STATUS "git clone " ${REPO_URL} to ${WORKSPACE_PATH} "\n" ${OUTPUT})
	if(RESULT)
		message(FATAL_ERROR " Failed to clone " ${PROJECT_PATH})
	endif()
endfunction()

function(sos_sdk_clone_or_pull PROJECT_PATH REPO_URL WORKSPACE_PATH)
	#if ${PROJECT_PATH} directory doesn't exist -- clone from the URL
	if(EXISTS ${PROJECT_PATH}/.git)
		message(STATUS ${PROJECT_PATH} " already exists: pulling")
		sos_sdk_pull(${PROJECT_PATH})
	else()
		file(REMOVE_RECURSE ${PROJECT_PATH})
		message(STATUS ${PROJECT_PATH} " does not exist: cloning")
		sos_sdk_clone(${REPO_URL} ${WORKSPACE_PATH})
	endif()
endfunction()

function(sos_sdk_checkout PROJECT_PATH GIT_PATH)
	execute_process(COMMAND ${SOS_SDK_GIT_EXEC} checkout ${GIT_PATH} WORKING_DIRECTORY ${PROJECT_PATH} OUTPUT_VARIABLE OUTPUT RESULT_VARIABLE RESULT)
	message(STATUS "git checkout " ${GIT_PATH} " in " ${PROJECT_PATH} "\n" ${OUTPUT})
	if(RESULT)
		message(FATAL_ERROR " Failed to checkout " ${PROJECT_PATH} ${GIT_PATH})
	endif()
endfunction()

function(sos_sdk_build_app PROJECT_PATH)
	set(BUILD_PATH ${PROJECT_PATH}/cmake_arm)
	file(MAKE_DIRECTORY ${BUILD_PATH})
	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} ${SOS_SDK_GENERATOR} ${SOS_SDK_TOOLCHAIN_SETTINGS} .. WORKING_DIRECTORY ${BUILD_PATH})
	if(RESULT)
		message(FATAL_ERROR " Failed to generate using " ${SOS_SDK_CMAKE_EXEC} ${SOS_SDK_GENERATOR} ${SOS_SDK_TOOLCHAIN_SETTINGS} ".. "  "	in " ${BUILD_PATH})
	endif()
	if(SOS_SDK_CLEAN_ALL)
		execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target clean WORKING_DIRECTORY ${BUILD_PATH})
		if(RESULT)
			message(FATAL_ERROR " Failed to clean using " ${SOS_SDK_CMAKE_EXEC} "--build . --target clean on " ${PROJECT_PATH})
		endif()
	endif()
	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target all -- -j 10 WORKING_DIRECTORY ${BUILD_PATH})
	if(RESULT)
		message(FATAL_ERROR " Failed to build all using " ${SOS_SDK_CMAKE_EXEC} "--build . --target all -- -j 10 on " ${PROJECT_PATH})
	endif()
endfunction()

function(sos_sdk_build_bsp PROJECT_PATH)
	set(BUILD_PATH ${PROJECT}/cmake_arm)
	file(MAKE_DIRECTORY ${BUILD_PATH})
	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} ${SOS_SDK_GENERATOR} ${SOS_SDK_TOOLCHAIN_SETTINGS} .. WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
	if(RESULT)
		message(FATAL_ERROR " Failed to generate using " ${SOS_SDK_CMAKE_EXEC} ".. " ${SOS_SDK_GENERATOR} ${SOS_SDK_TOOLCHAIN_SETTINGS} "	in " ${BUILD_PATH})
	endif()
	if(RESULT)
		message(FATAL ${SOS_SDK_CMAKE_EXEC} "Failed")
	endif()
	if(SOS_SDK_CLEAN_ALL)
		execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target clean WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
		if(RESULT)
			message(FATAL_ERROR " Failed to clean using " ${SOS_SDK_CMAKE_EXEC} "--build . --target clean on " ${PROJECT_PATH})
		endif()
	endif()
	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target all -- -j 10 WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
	if(RESULT)
		message(FATAL_ERROR " Failed to build all using " ${SOS_SDK_CMAKE_EXEC} "--build . --target all -- -j 10 on " ${PROJECT_PATH})
	endif()
endfunction()

function(sos_sdk_remove_build_directory PROJECT_PATH CONFIG)
	set(BUILD_PATH ${PROJECT_PATH}/cmake_${CONFIG})
	file(REMOVE_RECURSE ${PROJECT_PATH}/cmake_${CONFIG})
endfunction()

function(sos_sdk_build_lib PROJECT_PATH IS_INSTALL CONFIG)
	set(BUILD_PATH ${PROJECT_PATH}/cmake_${CONFIG})
	file(MAKE_DIRECTORY ${PROJECT_PATH}/cmake_${CONFIG})

	if(IS_INSTALL)
		set(TARGET install)
	elseif()
		set(TARGET all)
	endif()


	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} ${SOS_SDK_GENERATOR} ${SOS_SDK_TOOLCHAIN_SETTINGS} .. WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
	if(RESULT)
		message(FATAL_ERROR " Failed to generate using " ${SOS_SDK_CMAKE_EXEC} ${SOS_SDK_GENERATOR} ${SOS_SDK_TOOLCHAIN_SETTINGS} " .. " "	in " ${BUILD_PATH})
	endif()
	if(CONFIG STREQUAL "link")
		#Sometimes there is a problem building if cmake is only run once
		execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} ${SOS_SDK_GENERATOR} ${SOS_SDK_TOOLCHAIN_SETTINGS} .. WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
	endif()
	if(SOS_SDK_CLEAN_ALL)
		execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target clean WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
		if(RESULT)
			message(FATAL_ERROR " Failed to clean using " ${SOS_SDK_CMAKE_EXEC} "--build . --target clean on " ${PROJECT_PATH})
		endif()
	endif()
	execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target ${TARGET} -- -j 10 WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
	if(RESULT)
		#try again -- sometimes windows fails for no reason
		execute_process(COMMAND ${SOS_SDK_CMAKE_EXEC} --build . --target ${TARGET} -- -j 10 WORKING_DIRECTORY ${BUILD_PATH} RESULT_VARIABLE RESULT)
		if(RESULT)
			message(FATAL_ERROR " Failed to build all using " ${SOS_SDK_CMAKE_EXEC} "--build . --target all -- -j 10 on " ${PROJECT_PATH})
		endif()
	endif()
endfunction()

function(sos_sdk_add_format_target CLANG_COMMAND SOURCE_LIST)
	add_custom_target(
		format
		COMMAND ${CLANG_COMMAND}
		-i
		--verbose
		${SOURCE_LIST}
		)
endfunction()

function(sos_get_git_hash)
	execute_process(
		COMMAND git log -1 --format=%h
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
		OUTPUT_VARIABLE GIT_HASH_OUTPUT_VARIABLE
		OUTPUT_STRIP_TRAILING_WHITESPACE
		RESULT_VARIABLE RESULT
		)

	if(RESULT)
		set(SOS_GIT_HASH "0000000" PARENT_SCOPE)
	else()
		set(SOS_GIT_HASH ${GIT_HASH_OUTPUT_VARIABLE} PARENT_SCOPE)
	endif()
endfunction()


