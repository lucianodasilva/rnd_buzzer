macro (apply_arch)
    if (NOT ARCH)
        set (ARCH "X64")
    endif() 

    string (TOLOWER ${ARCH} ARCH)

    if (${ARCH} MATCHES "x86")

        add_compile_options(
            $<$<CXX_COMPILER_ID:GNU,CLANG>:-m32>)

        if (MSVC)
            set (CMAKE_GENERATOR_PLATFORM Win32)
        endif ()

        message (STATUS "x86 Build")
    elseif (${ARCH} MATCHES "x64")

        if (MSVC)
            set (CMAKE_GENERATOR_PLATFORM x64)
        endif ()

        message (STATUS "x64 Build")
    else()
        message (FATAL_ERROR "unsupported architecture '${ARCH}'")
    endif()    
endmacro()

macro (append_source path out)
    file (
            GLOB_RECURSE
            sources
            ${path}/*.h
            ${path}/*.hpp
            ${path}/*.c
            ${path}/*.cpp
            ${path}/*.s
    )

    list (APPEND ${out} ${sources})
endmacro()

macro (scan_folders path out)

    file (
        GLOB_RECURSE
        glob_all
        LIST_DIRECTORIES true
        ${path}/*
    )

    list (APPEND ${out} ${path})

    foreach(child ${glob_all})
        if (IS_DIRECTORY ${child})
            list (APPEND ${out} ${child})
        endif()
    endforeach()
endmacro()

function (find_git_version VERSION VERSION_STR)
    find_package (Git)

    if (NOT GIT_FOUND)
        message (FATAL_ERROR "Git executable not found!")
    endif()

    # check for latest tag
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --abbrev=0 --tags
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        OUTPUT_VARIABLE GIT_TAG
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_QUIET
        ERROR_QUIET
    )

    # if not tag found set default version
    if (NOT GIT_TAG)
        set (GIT_TAG "v0.0.0")
    else()
        message (STATUS "Latest Git Tag: ${GIT_TAG}")

        # check for commits since tag
        execute_process(
            COMMAND ${GIT_EXECUTABLE} log ${GIT_TAG}..HEAD --oneline
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
            OUTPUT_VARIABLE GIT_COMMITS
        )
    endif()

    # check if repo dirty
    execute_process(
        COMMAND ${GIT_EXECUTABLE} diff-index --quiet HEAD --
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        RESULT_VARIABLE GIT_DIRTY
    )
    
    # process tag into version
    # remove "v" prefix
    string (REPLACE "v" "" TMP_VERSION ${GIT_TAG})
    # split version numbers
    string (REPLACE "." "," TMP_VERSION ${TMP_VERSION})

    set (TMP_VERSION_STR ${GIT_TAG})

    # add modified flag
    if (NOT GIT_COMMITS AND ${GIT_DIRTY} EQUAL 0)
        string (APPEND TMP_VERSION ",false")
    else ()
        string (APPEND TMP_VERSION_STR ".*")
        string (APPEND TMP_VERSION ",true")
    endif()

    set (${VERSION} ${TMP_VERSION} PARENT_SCOPE)
    set (${VERSION_STR} ${TMP_VERSION_STR} PARENT_SCOPE)
endfunction()

function (add_catch2_test target_name path)

    set (source_code)
    append_source (${path} source_code)

    add_executable (${target_name} ${source_code})

    target_link_libraries (
        ${target_name} PUBLIC Catch2::Catch2
    )

    set_target_properties(
        ${target_name}
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/tests)

endfunction()

macro (add_hybrid_library LIB_NAME)
    if (IO_BUILD_FIRMWARE)
        add_arm_library (${LIB_NAME} ${ARGN})
        target_compile_definitions(
            ${LIB_NAME}
            INTERFACE
                IO_BUILD_FIRMWARE)
    elseif(IO_BUILD_DRIVER)
        add_library (${LIB_NAME} ${ARGN})
        target_compile_definitions(
            ${LIB_NAME}
            INTERFACE
                IO_BUILD_DRIVER)
    endif()
endmacro ()