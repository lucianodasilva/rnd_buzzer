find_program(AVR_CC avr-gcc)
find_program(AVR_CXX avr-g++)
find_program(AVR_OBJCOPY avr-objcopy)
find_program(AVR_SIZE_TOOL avr-size)
find_program(AVR_OBJDUMP avr-objdump)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)
set(CMAKE_C_COMPILER ${AVR_CC})
set(CMAKE_CXX_COMPILER ${AVR_CXX})

if(NOT ((CMAKE_BUILD_TYPE MATCHES Release) OR
		(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo) OR
		(CMAKE_BUILD_TYPE MATCHES Debug) OR
		(CMAKE_BUILD_TYPE MATCHES MinSizeRel)))

	set(
		CMAKE_BUILD_TYPE Release
	  	CACHE STRING "Choose cmake build type: Debug Release RelWithDebInfo MinSizeRel"
	  	FORCE)

endif()

function(add_avr_executable EXECUTABLE_NAME AVR_MCU AVR_DFP_PATH)
	if(NOT ARGN)
		message(FATAL_ERROR "No source files given for ${EXECUTABLE_NAME}.")
	endif()

	# set file names
	set(elf_file "${EXECUTABLE_NAME}.${AVR_MCU}.elf")
	set(hex_file "${EXECUTABLE_NAME}.${AVR_MCU}.hex")
	set(map_file "${EXECUTABLE_NAME}.${AVR_MCU}.map")
	set(eeprom_image "${EXECUTABLE_NAME}-${AVR_MCU}.eeprom.hex")

	# elf file
	add_executable(${EXECUTABLE_NAME} ${ARGN})

	set_target_properties(
		${EXECUTABLE_NAME}
		PROPERTIES
			COMPILE_FLAGS "-mmcu=${AVR_MCU} -B ${AVR_DFP_PATH}/gcc/dev/${AVR_MCU} -I ${AVR_DFP_PATH}/include -Wall -Wextra -pedantic -fno-exceptions -fno-rtti -fno-unwind-tables -fno-threadsafe-statics --param=min-pagesize=0"
			LINK_FLAGS "-mmcu=${AVR_MCU} -B ${AVR_DFP_PATH}/gcc/dev/${AVR_MCU} -Wl,--gc-sections -mrelax -Wl,-Map,${map_file}"
			OUTPUT_NAME "${elf_file}")

	add_custom_command(
		TARGET ${EXECUTABLE_NAME}
		POST_BUILD
	  	COMMAND
			${AVR_OBJCOPY} -j .text -j .data -O ihex ${elf_file} ${hex_file}
	  	COMMAND
			${AVR_SIZE_TOOL} -A ${elf_file}
	)

   # eeprom
	add_custom_command(
		TARGET ${EXECUTABLE_NAME}
		POST_BUILD
		COMMAND
		${AVR_OBJCOPY} -j .eeprom --set-section-flags=.eeprom=alloc,load
			--change-section-lma .eeprom=0 --no-change-warnings
			-O ihex ${elf_file} ${eeprom_image}
   	)

	# disassemble
	add_custom_command(
		TARGET ${EXECUTABLE_NAME}
		POST_BUILD
		COMMAND
		${AVR_OBJDUMP} -S ${elf_file} > ${EXECUTABLE_NAME}.lst
	)

   # clean
   get_directory_property(clean_files ADDITIONAL_MAKE_CLEAN_FILES)
   set_directory_properties(
	  PROPERTIES
		 ADDITIONAL_MAKE_CLEAN_FILES "${map_file}"
   )

endfunction(add_avr_executable)

function(add_avr_library LIBRARY_NAME AVR_MCU)
   set(lib_file ${LIBRARY_NAME}${MCU_TYPE_FOR_FILENAME})

   add_library(${lib_file} STATIC ${ARGN})

   set_target_properties(
	  ${lib_file}
	  PROPERTIES
		 COMPILE_FLAGS "-mmcu=${AVR_MCU} --param=min-pagesize=0"
		 OUTPUT_NAME "${lib_file}"
   )

   if(NOT TARGET ${LIBRARY_NAME})
	  add_custom_target(
		 ${LIBRARY_NAME}
		 ALL
		 DEPENDS ${lib_file}
	  )

	  set_target_properties(
		 ${LIBRARY_NAME}
		 PROPERTIES
			OUTPUT_NAME "${lib_file}"
	  )
   endif()

endfunction()