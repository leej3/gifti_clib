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

function(add_gifti_library target_in)
    add_library(${ARGV})
    add_library(GIFTI::${target_in} ALIAS ${target_in})
    if(NOT GIFTI_INSTALL_NO_LIBRARIES)
      get_property(tmp GLOBAL PROPERTY installed_targets)
      list(APPEND tmp "${target_in}")
      set_property(GLOBAL PROPERTY installed_targets "${tmp}")
    endif()
endfunction()

function(add_gifti_executable target_in)
  add_executable(${ARGV})
  if(NOT GIFTI_INSTALL_NO_APPLICATIONS)
    get_property(tmp GLOBAL PROPERTY installed_targets)
    list(APPEND tmp "${target_in}")
    set_property(GLOBAL PROPERTY installed_targets "${tmp}")
  endif()
endfunction()
