
macro(set_if_not_defined var defaultvalue)
# Macro allowing to set a variable to its default value if not already defined.
# The default value is set with:
#  (1) if set, the value environment variable <var>.
#  (2) if set, the value of local variable variable <var>.
#  (3) if none of the above, the value passed as a parameter.
# Setting the optional parameter 'OBFUSCATE' will display 'OBFUSCATED' instead of the real value.
  set(_obfuscate FALSE)
  foreach(arg ${ARGN})
    if(arg STREQUAL "OBFUSCATE")
      set(_obfuscate TRUE)
    endif()
  endforeach()
  if(DEFINED ENV{${var}} AND NOT DEFINED ${var})
    set(_value "$ENV{${var}}")
    if(_obfuscate)
      set(_value "OBFUSCATED")
    endif()
    message(STATUS "Setting '${var}' variable with environment variable value '${_value}'")
    set(${var} $ENV{${var}})
  endif()
  if(NOT DEFINED ${var})
    set(_value "${defaultvalue}")
    if(_obfuscate)
      set(_value "OBFUSCATED")
    endif()
    message(STATUS "Setting '${var}' variable with default value '${_value}'")
    set(${var} "${defaultvalue}")
  endif()
endmacro()

macro(get_gifti_rpath)
# Prepare RPATH
file(RELATIVE_PATH _rel ${CMAKE_INSTALL_PREFIX}/${GIFTI_INSTALL_BIN_DIR} ${CMAKE_INSTALL_PREFIX})
if(APPLE)
  set(_rpath "@loader_path/${_rel}")
else()
  set(_rpath "\$ORIGIN/${_rel}")
endif()
file(TO_NATIVE_PATH "${_rpath}/${GIFTI_INSTALL_LIB_DIR}" message_RPATH)
endmacro()

macro(add_gifti_target_properties target)
  # this macro sets some default properties for targets in this project
  get_gifti_rpath()
  # define installation prefix
  get_target_property(TARGET_TYPE ${target} TYPE)

  # Define prefix of exported target i.e. if a prefix is defined, all targets
  # will have the prefix appended and the export namespace will be changed.
  # So NIFTI::znz becomes prefixNIFTI::prefixznz
  set(TARGET_EXPORT_NAME ${NIFTI_PACKAGE_PREFIX}${target})

  if(TARGET_TYPE MATCHES "LIBRARY")
    # If a superbuild modifies the export name then an alias  should be
    #  created for use during build configure time. This alias will be
    #  identical to the exported targets of the project
    if(${target} STREQUAL fake_target)
      message("Based on project settings, NIFTI/GIFTI targets will look like ${PACKAGE_NAME}::${TARGET_EXPORT_NAME}")
    else()
      message("adding ${target} alias for superbuild  (${PACKAGE_NAME}::${TARGET_EXPORT_NAME})")
    endif()
      add_library(
        ${PACKAGE_NAME}::${TARGET_EXPORT_NAME}
         ALIAS
          ${target})
  endif()

  # Set the target properties
  # Currently this includes setting up post-install linking, prefixing target names with NIFTI_PACKAGE_PREFIX if requests
    set_target_properties(${target} PROPERTIES
    MACOSX_RPATH ON
    SKIP_BUILD_RPATH OFF
    BUILD_WITH_INSTALL_RPATH OFF
    INSTALL_RPATH "${message_RPATH}"
    INSTALL_RPATH_USE_LINK_PATH ON
    OUTPUT_NAME "${TARGET_EXPORT_NAME}" # filename base
    EXPORT_NAME "${TARGET_EXPORT_NAME}" # target exported
    )
endmacro()

